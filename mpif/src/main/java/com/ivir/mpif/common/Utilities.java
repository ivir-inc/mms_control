/*
 * Copyright 2026 IVIR Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ivir.mpif.common;

import java.util.function.Consumer;

public class Utilities {
    public static String cleanPatientId(String patientId){
        if(patientId == null){
            return null;
        }
        return patientId.trim().toUpperCase();
    }

    public static <T> void doIfNotNull(T value, Consumer<T> doFun){
        if(value != null){
            doFun.accept(value);
        }
    }

    public static <T> void useDefaultIfNull(T value, T defaultVal, Consumer<T> doFun) {
        if (value != null) {
            doFun.accept(value);
        }else{
            doFun.accept(defaultVal);
        }
    }
}
