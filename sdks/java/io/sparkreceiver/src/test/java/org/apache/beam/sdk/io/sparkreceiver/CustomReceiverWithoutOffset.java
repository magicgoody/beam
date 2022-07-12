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
package org.apache.beam.sdk.io.sparkreceiver;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import org.apache.beam.vendor.guava.v26_0_jre.com.google.common.util.concurrent.ThreadFactoryBuilder;
import org.apache.spark.storage.StorageLevel;
import org.apache.spark.streaming.receiver.Receiver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Imitation of Spark {@link Receiver} that doesn't implement {@link HasOffset} interface. Used to
 * test {@link SparkReceiverIO#read()}.
 */
public class CustomReceiverWithoutOffset extends Receiver<String> {

  private static final Logger LOG = LoggerFactory.getLogger(CustomReceiverWithoutOffset.class);
  private static final int TIMEOUT_MS = 500;
  private static final List<String> records = new ArrayList<>();

  CustomReceiverWithoutOffset() {
    super(StorageLevel.MEMORY_AND_DISK_2());
  }

  @Override
  @SuppressWarnings("FutureReturnValueIgnored")
  public void onStart() {
    Executors.newSingleThreadExecutor(new ThreadFactoryBuilder().build()).submit(this::receive);
  }

  @Override
  public void onStop() {}

  private void receive() {
    Long currentOffset = 0L;
    while (!isStopped()) {
      records.add(currentOffset.toString());
      store((currentOffset++).toString());
      try {
        TimeUnit.MILLISECONDS.sleep(TIMEOUT_MS);
      } catch (InterruptedException e) {
        LOG.error("Interrupted", e);
      }
    }
  }

  public static List<String> getRecords() {
    return records;
  }
}
