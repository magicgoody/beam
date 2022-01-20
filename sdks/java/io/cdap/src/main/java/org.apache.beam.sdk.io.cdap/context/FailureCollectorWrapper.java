/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.beam.sdk.io.cdap.context;

import io.cdap.cdap.etl.api.FailureCollector;
import io.cdap.cdap.etl.api.validation.ValidationException;
import io.cdap.cdap.etl.api.validation.ValidationFailure;

import javax.annotation.Nullable;
import java.util.ArrayList;

/**
 * Class FailureCollectorWrapper is a class for collecting ValidationFailure.
 */
public class FailureCollectorWrapper implements FailureCollector {
    private ArrayList<ValidationFailure> failuresCollection;

    public FailureCollectorWrapper() {
        this.failuresCollection = new ArrayList<>();
    }

    @Override
    public ValidationFailure addFailure(String message, @Nullable String correctiveAction) {
        ValidationFailure validationFailure = new ValidationFailure(message, correctiveAction);
        failuresCollection.add(validationFailure);

        return validationFailure;
    }

    @Override
    public ValidationException getOrThrowException() throws ValidationException {
        if (failuresCollection.isEmpty()) {
            return new ValidationException(this.failuresCollection);
        }

        throw new ValidationException(this.failuresCollection);
    }

    @Override
    public ArrayList<ValidationFailure> getValidationFailures() {
        return this.failuresCollection;
    }
}
