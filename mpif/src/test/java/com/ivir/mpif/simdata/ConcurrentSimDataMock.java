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

package com.ivir.mpif.simdata;

public class ConcurrentSimDataMock extends ConcurrentSimData<ConcurrentSimDataMock.ConcurrentSimDataEnumMock>{
    private static final long serialVersionUID = -6433557882352073835L;

    public ConcurrentSimDataMock() {
        super(ConcurrentSimDataEnumMock.class, ConcurrentSimDataEnumMock.FIELD3_LON, true);
    }

    public ConcurrentSimDataMock(ConcurrentSimDataEnumMock indexField, boolean autoIncrement){
        super(ConcurrentSimDataEnumMock.class, indexField, autoIncrement);
    }

    public enum ConcurrentSimDataEnumMock{
        FIELD1_INT,
        FIELD2_STR,
        FIELD3_LON
    }

}
