#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

""" Support for mapping python types to proto Schemas and back again.

Imposes a mapping between common Python types and Beam portable schemas
(https://s.apache.org/beam-schemas)::

  Python              Schema
  np.int8     <-----> BYTE
  np.int16    <-----> INT16
  np.int32    <-----> INT32
  np.int64    <-----> INT64
  int         ------> INT64
  np.float32  <-----> FLOAT
  np.float64  <-----> DOUBLE
  float       ------> DOUBLE
  bool        <-----> BOOLEAN
  str         <-----> STRING
  bytes       <-----> BYTES
  ByteString  ------> BYTES
  Timestamp   <-----> LogicalType(urn="beam:logical_type:micros_instant:v1")
  Mapping     <-----> MapType
  Sequence    <-----> ArrayType
  NamedTuple  <-----> RowType
  beam.Row    ------> RowType

Note that some of these mappings are provided as conveniences,
but they are lossy and will not survive a roundtrip from python to Beam schemas
and back. For example, the Python type :code:`int` will map to :code:`INT64` in
Beam schemas but converting that back to a Python type will yield
:code:`np.int64`.

:code:`nullable=True` on a Beam :code:`FieldType` is represented in Python by
wrapping the type in :code:`Optional`.

This module is intended for internal use only. Nothing defined here provides
any backwards-compatibility guarantee.
"""

# pytype: skip-file

from typing import Any
from typing import ByteString
from typing import Dict
from typing import Generic
from typing import List
from typing import Mapping
from typing import NamedTuple
from typing import Optional
from typing import Sequence
from typing import Tuple
from typing import TypeVar
from typing import Union

import numpy as np
from google.protobuf import text_format

from apache_beam.portability import common_urns
from apache_beam.portability.api import schema_pb2
from apache_beam.typehints import row_type
from apache_beam.typehints.native_type_compatibility import _get_args
from apache_beam.typehints.native_type_compatibility import _match_is_exactly_mapping
from apache_beam.typehints.native_type_compatibility import _match_is_optional
from apache_beam.typehints.native_type_compatibility import _safe_issubclass
from apache_beam.typehints.native_type_compatibility import extract_optional_type
from apache_beam.typehints.native_type_compatibility import match_is_named_tuple
from apache_beam.typehints.schema_registry import SCHEMA_REGISTRY
from apache_beam.typehints.schema_registry import SchemaTypeRegistry
from apache_beam.utils import proto_utils
from apache_beam.utils.python_callable import PythonCallableWithSource
from apache_beam.utils.timestamp import Timestamp

PYTHON_ANY_URN = "beam:logical:pythonsdk_any:v1"

# Bi-directional mappings
_PRIMITIVES = (
    (np.int8, schema_pb2.BYTE),
    (np.int16, schema_pb2.INT16),
    (np.int32, schema_pb2.INT32),
    (np.int64, schema_pb2.INT64),
    (np.float32, schema_pb2.FLOAT),
    (np.float64, schema_pb2.DOUBLE),
    (str, schema_pb2.STRING),
    (bool, schema_pb2.BOOLEAN),
    (bytes, schema_pb2.BYTES),
)

PRIMITIVE_TO_ATOMIC_TYPE = dict((typ, atomic) for typ, atomic in _PRIMITIVES)
ATOMIC_TYPE_TO_PRIMITIVE = dict((atomic, typ) for typ, atomic in _PRIMITIVES)

# One-way mappings
PRIMITIVE_TO_ATOMIC_TYPE.update({
    ByteString: schema_pb2.BYTES,
    # Allow users to specify a native int, and use INT64 as the cross-language
    # representation. Technically ints have unlimited precision, but RowCoder
    # should throw an error if it sees one with a bit width > 64 when encoding.
    int: schema_pb2.INT64,
    float: schema_pb2.DOUBLE,
})


def named_fields_to_schema(
    names_and_types: Union[Dict[str, type], Sequence[Tuple[str, type]]],
    schema_id: Optional[str] = None,
    schema_options: Optional[Sequence[Tuple[str, Any]]] = None,
    field_options: Optional[Dict[str, Sequence[Tuple[str, Any]]]] = None,
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY,
):
  schema_options = schema_options or []
  field_options = field_options or {}

  if isinstance(names_and_types, dict):
    names_and_types = names_and_types.items()

  if schema_id is None:
    schema_id = schema_registry.generate_new_id()

  return schema_pb2.Schema(
      fields=[
          schema_pb2.Field(
              name=name,
              type=typing_to_runner_api(type),
              options=[
                  option_to_runner_api(option_tuple)
                  for option_tuple in field_options.get(name, [])
              ],
          ) for (name, type) in names_and_types
      ],
      options=[
          option_to_runner_api(option_tuple) for option_tuple in schema_options
      ],
      id=schema_id)


def named_fields_from_schema(
    schema):  # (schema_pb2.Schema) -> typing.List[typing.Tuple[str, type]]
  return [(field.name, typing_from_runner_api(field.type))
          for field in schema.fields]


def typing_to_runner_api(
    type_: type,
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY
) -> schema_pb2.FieldType:
  return SchemaTranslation(
      schema_registry=schema_registry).typing_to_runner_api(type_)


def typing_from_runner_api(
    fieldtype_proto: schema_pb2.FieldType,
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY) -> type:
  return SchemaTranslation(
      schema_registry=schema_registry).typing_from_runner_api(fieldtype_proto)


def option_to_runner_api(
    option: Tuple[str, Any],
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY) -> schema_pb2.Option:
  return SchemaTranslation(
      schema_registry=schema_registry).option_to_runner_api(option)


def option_from_runner_api(
    option_proto: schema_pb2.Option,
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY) -> type:
  return SchemaTranslation(
      schema_registry=schema_registry).option_from_runner_api(option_proto)


class SchemaTranslation(object):
  def __init__(self, schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY):
    self.schema_registry = schema_registry

  def typing_to_runner_api(self, type_: type) -> schema_pb2.FieldType:
    if isinstance(type_, schema_pb2.Schema):
      return schema_pb2.FieldType(row_type=schema_pb2.RowType(schema=type_))

    if isinstance(type_, row_type.RowTypeConstraint):
      if type_.schema_id is None:
        schema_id = SCHEMA_REGISTRY.generate_new_id()
        type_.set_schema_id(schema_id)
        schema = None
      else:
        schema_id = type_.schema_id
        schema = self.schema_registry.get_schema_by_id(schema_id)

      if schema is None:
        # Either user_type was not annotated with a schema id, or there was
        # no schema in the registry with the id. The latter should only happen
        # in tests.
        # Either way, we need to generate a new schema proto.
        schema = schema_pb2.Schema(
            fields=[
                schema_pb2.Field(
                    name=field_name,
                    type=self.typing_to_runner_api(field_type),
                    options=[
                        self.option_to_runner_api(option_tuple)
                        for option_tuple in type_.field_options(field_name)
                    ],
                ) for (field_name, field_type) in type_._fields
            ],
            id=schema_id,
            options=[
                self.option_to_runner_api(option_tuple)
                for option_tuple in type_.schema_options
            ],
        )
        self.schema_registry.add(type_.user_type, schema)
      return schema_pb2.FieldType(row_type=schema_pb2.RowType(schema=schema))
    else:
      # See if this is coercible to a RowTypeConstraint (e.g. a NamedTuple or
      # dataclass)
      row_type_constraint = row_type.RowTypeConstraint.from_user_type(type_)
      if row_type_constraint is not None:
        return self.typing_to_runner_api(row_type_constraint)

    # All concrete types (other than NamedTuple sub-classes) should map to
    # a supported primitive type.
    if type_ in PRIMITIVE_TO_ATOMIC_TYPE:
      return schema_pb2.FieldType(atomic_type=PRIMITIVE_TO_ATOMIC_TYPE[type_])

    elif _match_is_exactly_mapping(type_):
      key_type, value_type = map(self.typing_to_runner_api, _get_args(type_))
      return schema_pb2.FieldType(
          map_type=schema_pb2.MapType(key_type=key_type, value_type=value_type))

    elif _match_is_optional(type_):
      # It's possible that a user passes us Optional[Optional[T]], but in python
      # typing this is indistinguishable from Optional[T] - both resolve to
      # Union[T, None] - so there's no need to check for that case here.
      result = self.typing_to_runner_api(extract_optional_type(type_))
      result.nullable = True
      return result

    elif _safe_issubclass(type_, Sequence):
      element_type = self.typing_to_runner_api(_get_args(type_)[0])
      return schema_pb2.FieldType(
          array_type=schema_pb2.ArrayType(element_type=element_type))

    elif _safe_issubclass(type_, Mapping):
      key_type, value_type = map(self.typing_to_runner_api, _get_args(type_))
      return schema_pb2.FieldType(
          map_type=schema_pb2.MapType(key_type=key_type, value_type=value_type))

    try:
      logical_type = LogicalType.from_typing(type_)
    except ValueError:
      # Unknown type, just treat it like Any
      return schema_pb2.FieldType(
          logical_type=schema_pb2.LogicalType(urn=PYTHON_ANY_URN),
          nullable=True)
    else:
      # TODO(bhulette): Add support for logical types that require arguments
      return schema_pb2.FieldType(
          logical_type=schema_pb2.LogicalType(
              urn=logical_type.urn(),
              representation=self.typing_to_runner_api(
                  logical_type.representation_type())))

  def option_from_runner_api(
      self, option_proto: schema_pb2.Option) -> Tuple[str, Any]:
    if not option_proto.HasField('type'):
      return option_proto.name, None

    fieldtype_proto = option_proto.type
    if fieldtype_proto.WhichOneof("type_info") != "atomic_type":
      raise ValueError(
          "Encounterd option with unsupported type. Only "
          f"atomic_type options are supported: {option_proto}")

    if fieldtype_proto.atomic_type == schema_pb2.BYTE:
      value = np.int8(option_proto.value.atomic_value.byte)
    elif fieldtype_proto.atomic_type == schema_pb2.INT16:
      value = np.int16(option_proto.value.atomic_value.int16)
    elif fieldtype_proto.atomic_type == schema_pb2.INT32:
      value = np.int32(option_proto.value.atomic_value.int32)
    elif fieldtype_proto.atomic_type == schema_pb2.INT64:
      value = np.int64(option_proto.value.atomic_value.int64)
    elif fieldtype_proto.atomic_type == schema_pb2.FLOAT:
      value = np.float32(option_proto.value.atomic_value.float)
    elif fieldtype_proto.atomic_type == schema_pb2.DOUBLE:
      value = np.float64(option_proto.value.atomic_value.double)
    elif fieldtype_proto.atomic_type == schema_pb2.STRING:
      value = option_proto.value.atomic_value.string
    elif fieldtype_proto.atomic_type == schema_pb2.BOOLEAN:
      value = option_proto.value.atomic_value.boolean
    elif fieldtype_proto.atomic_type == schema_pb2.BYTES:
      value = option_proto.value.atomic_value.bytes
    else:
      raise ValueError(
          f"Unrecognized atomic_type ({fieldtype_proto.atomic_type}) "
          f"when decoding option {option_proto!r}")

    return option_proto.name, value

  def option_to_runner_api(self, option: Tuple[str, Any]) -> schema_pb2.Option:
    name, value = option

    if value is None:
      # a value of None indicates the option is just a flag.
      # Don't set type, value
      return schema_pb2.Option(name=name)

    fieldtype_proto = self.typing_to_runner_api(type(value))
    if fieldtype_proto.WhichOneof("type_info") != "atomic_type":
      # TODO: Allow other value types
      raise ValueError(
          "Only atomic_type option values are currently supported in Python. "
          f"Got {value!r}, which maps to fieldtype {fieldtype_proto!r}.")

    if fieldtype_proto.atomic_type == schema_pb2.BYTE:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(byte=value)
    elif fieldtype_proto.atomic_type == schema_pb2.INT16:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(int16=value)
    elif fieldtype_proto.atomic_type == schema_pb2.INT32:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(int32=value)
    elif fieldtype_proto.atomic_type == schema_pb2.INT64:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(int64=value)
    elif fieldtype_proto.atomic_type == schema_pb2.FLOAT:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(float=value)
    elif fieldtype_proto.atomic_type == schema_pb2.DOUBLE:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(double=value)
    elif fieldtype_proto.atomic_type == schema_pb2.STRING:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(string=value)
    elif fieldtype_proto.atomic_type == schema_pb2.BOOLEAN:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(boolean=value)
    elif fieldtype_proto.atomic_type == schema_pb2.BYTES:
      atomictypevalue_proto = schema_pb2.AtomicTypeValue(bytes=value)
    else:
      raise ValueError(
          "Unrecognized atomic_type in fieldtype_proto="
          f"{fieldtype_proto!r} when encoding option {option!r}")

    return schema_pb2.Option(
        name=name,
        type=fieldtype_proto,
        value=schema_pb2.FieldValue(atomic_value=atomictypevalue_proto),
    )

  def typing_from_runner_api(
      self, fieldtype_proto: schema_pb2.FieldType) -> type:
    if fieldtype_proto.nullable:
      # In order to determine the inner type, create a copy of fieldtype_proto
      # with nullable=False and pass back to typing_from_runner_api
      base_type = schema_pb2.FieldType()
      base_type.CopyFrom(fieldtype_proto)
      base_type.nullable = False
      base = self.typing_from_runner_api(base_type)
      if base == Any:
        return base
      else:
        return Optional[base]

    type_info = fieldtype_proto.WhichOneof("type_info")
    if type_info == "atomic_type":
      try:
        return ATOMIC_TYPE_TO_PRIMITIVE[fieldtype_proto.atomic_type]
      except KeyError:
        raise ValueError(
            "Unsupported atomic type: {0}".format(fieldtype_proto.atomic_type))
    elif type_info == "array_type":
      return Sequence[self.typing_from_runner_api(
          fieldtype_proto.array_type.element_type)]
    elif type_info == "map_type":
      return Mapping[
          self.typing_from_runner_api(fieldtype_proto.map_type.key_type),
          self.typing_from_runner_api(fieldtype_proto.map_type.value_type)]
    elif type_info == "row_type":
      schema = fieldtype_proto.row_type.schema
      schema_options = [
          self.option_from_runner_api(option_proto)
          for option_proto in schema.options
      ]
      field_options = {
          field.name: [
              self.option_from_runner_api(option_proto)
              for option_proto in field.options
          ]
          for field in schema.fields if field.options
      }
      # First look for user type in the registry
      user_type = self.schema_registry.get_typing_by_id(schema.id)

      if user_type is None:
        # If not in SDK options (the coder likely came from another SDK),
        # generate a NamedTuple type to use.

        fields = named_fields_from_schema(schema)
        result = row_type.RowTypeConstraint.from_fields(
            fields=fields,
            schema_id=schema.id,
            schema_options=schema_options,
            field_options=field_options,
            schema_registry=self.schema_registry,
        )
        return result
      else:
        return row_type.RowTypeConstraint.from_user_type(
            user_type,
            schema_options=schema_options,
            field_options=field_options)

    elif type_info == "logical_type":
      if fieldtype_proto.logical_type.urn == PYTHON_ANY_URN:
        return Any
      else:
        return LogicalType.from_runner_api(
            fieldtype_proto.logical_type).language_type()

    else:
      raise ValueError(f"Unrecognized type_info: {type_info!r}")

  def named_tuple_from_schema(self, schema: schema_pb2.Schema) -> type:
    from apache_beam import coders

    type_name = 'BeamSchema_{}'.format(schema.id.replace('-', '_'))

    subfields = []
    for field in schema.fields:
      try:
        field_py_type = self.typing_from_runner_api(field.type)
        if isinstance(field_py_type, row_type.RowTypeConstraint):
          field_py_type = field_py_type.user_type
      except ValueError as e:
        raise ValueError(
            "Failed to decode schema due to an issue with Field proto:\n\n"
            f"{text_format.MessageToString(field)}") from e

      subfields.append((field.name, field_py_type))

    user_type = NamedTuple(type_name, subfields)

    # Define a reduce function, otherwise these types can't be pickled
    # (See BEAM-9574)
    def __reduce__(self):
      return (
          _hydrate_namedtuple_instance,
          (schema.SerializeToString(), tuple(self)))

    setattr(user_type, '__reduce__', __reduce__)

    self.schema_registry.add(user_type, schema)
    coders.registry.register_coder(user_type, coders.RowCoder)

    return user_type


def _hydrate_namedtuple_instance(encoded_schema, values):
  return named_tuple_from_schema(
      proto_utils.parse_Bytes(encoded_schema, schema_pb2.Schema))(*values)


def named_tuple_from_schema(
    schema, schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY) -> type:
  return SchemaTranslation(
      schema_registry=schema_registry).named_tuple_from_schema(schema)


def named_tuple_to_schema(
    named_tuple,
    schema_registry: SchemaTypeRegistry = SCHEMA_REGISTRY) -> schema_pb2.Schema:
  return typing_to_runner_api(named_tuple, schema_registry).row_type.schema


def schema_from_element_type(element_type: type) -> schema_pb2.Schema:
  """Get a schema for the given PCollection element_type.

  Returns schema as a list of (name, python_type) tuples"""
  if isinstance(element_type, row_type.RowTypeConstraint):
    # TODO(BEAM-10722): Make sure beam.Row generated schemas are registered and
    # de-duped
    return named_fields_to_schema(element_type._fields)
  elif match_is_named_tuple(element_type):
    return named_tuple_to_schema(element_type)
  else:
    raise TypeError(
        f"Could not determine schema for type hint {element_type!r}. Did you "
        "mean to create a schema-aware PCollection? See "
        "https://s.apache.org/beam-python-schemas")


def named_fields_from_element_type(
    element_type: type) -> List[Tuple[str, type]]:
  return named_fields_from_schema(schema_from_element_type(element_type))


# Registry of typings for a schema by UUID
class LogicalTypeRegistry(object):
  def __init__(self):
    self.by_urn = {}
    self.by_logical_type = {}
    self.by_language_type = {}

  def add(self, urn, logical_type):
    self.by_urn[urn] = logical_type
    self.by_logical_type[logical_type] = urn
    self.by_language_type[logical_type.language_type()] = logical_type

  def get_logical_type_by_urn(self, urn):
    return self.by_urn.get(urn, None)

  def get_urn_by_logial_type(self, logical_type):
    return self.by_logical_type.get(logical_type, None)

  def get_logical_type_by_language_type(self, representation_type):
    return self.by_language_type.get(representation_type, None)


LanguageT = TypeVar('LanguageT')
RepresentationT = TypeVar('RepresentationT')
ArgT = TypeVar('ArgT')


class LogicalType(Generic[LanguageT, RepresentationT, ArgT]):
  _known_logical_types = LogicalTypeRegistry()

  @classmethod
  def urn(cls):
    # type: () -> str

    """Return the URN used to identify this logical type"""
    raise NotImplementedError()

  @classmethod
  def language_type(cls):
    # type: () -> type

    """Return the language type this LogicalType encodes.

    The returned type should match LanguageT"""
    raise NotImplementedError()

  @classmethod
  def representation_type(cls):
    # type: () -> type

    """Return the type of the representation this LogicalType uses to encode the
    language type.

    The returned type should match RepresentationT"""
    raise NotImplementedError()

  @classmethod
  def argument_type(cls):
    # type: () -> type

    """Return the type of the argument used for variations of this LogicalType.

    The returned type should match ArgT"""
    raise NotImplementedError(cls)

  def argument(self):
    # type: () -> ArgT

    """Return the argument for this instance of the LogicalType."""
    raise NotImplementedError()

  def to_representation_type(value):
    # type: (LanguageT) -> RepresentationT

    """Convert an instance of LanguageT to RepresentationT."""
    raise NotImplementedError()

  def to_language_type(value):
    # type: (RepresentationT) -> LanguageT

    """Convert an instance of RepresentationT to LanguageT."""
    raise NotImplementedError()

  @classmethod
  def register_logical_type(cls, logical_type_cls):
    """Register an implementation of LogicalType."""
    cls._known_logical_types.add(logical_type_cls.urn(), logical_type_cls)

  @classmethod
  def from_typing(cls, typ):
    # type: (type) -> LogicalType

    """Construct an instance of a registered LogicalType implementation given a
    typing.

    Raises ValueError if no registered LogicalType implementation can encode the
    given typing."""

    logical_type = cls._known_logical_types.get_logical_type_by_language_type(
        typ)
    if logical_type is None:
      raise ValueError("No logical type registered for typing '%s'" % typ)

    return logical_type._from_typing(typ)

  @classmethod
  def _from_typing(cls, typ):
    # type: (type) -> LogicalType

    """Construct an instance of this LogicalType implementation given a typing.
    """
    raise NotImplementedError()

  @classmethod
  def from_runner_api(cls, logical_type_proto):
    # type: (schema_pb2.LogicalType) -> LogicalType

    """Construct an instance of a registered LogicalType implementation given a
    proto LogicalType.

    Raises ValueError if no LogicalType registered for the given URN.
    """
    logical_type = cls._known_logical_types.get_logical_type_by_urn(
        logical_type_proto.urn)
    if logical_type is None:
      raise ValueError(
          "No logical type registered for URN '%s'" % logical_type_proto.urn)
    # TODO(bhulette): Use argument
    return logical_type()


class NoArgumentLogicalType(LogicalType[LanguageT, RepresentationT, None]):
  @classmethod
  def argument_type(cls):
    # type: () -> type
    return None

  def argument(self):
    # type: () -> ArgT
    return None

  @classmethod
  def _from_typing(cls, typ):
    # type: (type) -> LogicalType

    # Since there's no argument, there can be no additional information encoded
    # in the typing. Just construct an instance.
    return cls()


MicrosInstantRepresentation = NamedTuple(
    'MicrosInstantRepresentation', [('seconds', np.int64),
                                    ('micros', np.int64)])


@LogicalType.register_logical_type
class MicrosInstant(NoArgumentLogicalType[Timestamp,
                                          MicrosInstantRepresentation]):
  @classmethod
  def urn(cls):
    return common_urns.micros_instant.urn

  @classmethod
  def representation_type(cls):
    # type: () -> type
    return MicrosInstantRepresentation

  @classmethod
  def language_type(cls):
    return Timestamp

  def to_representation_type(self, value):
    # type: (Timestamp) -> MicrosInstantRepresentation
    return MicrosInstantRepresentation(
        value.micros // 1000000, value.micros % 1000000)

  def to_language_type(self, value):
    # type: (MicrosInstantRepresentation) -> Timestamp
    return Timestamp(seconds=int(value.seconds), micros=int(value.micros))


@LogicalType.register_logical_type
class PythonCallable(NoArgumentLogicalType[PythonCallableWithSource, str]):
  @classmethod
  def urn(cls):
    return common_urns.python_callable.urn

  @classmethod
  def representation_type(cls):
    # type: () -> type
    return str

  @classmethod
  def language_type(cls):
    return PythonCallableWithSource

  def to_representation_type(self, value):
    # type: (PythonCallableWithSource) -> str
    return value.get_source()

  def to_language_type(self, value):
    # type: (str) -> PythonCallableWithSource
    return PythonCallableWithSource(value)
