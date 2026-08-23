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

public class SimDataMock extends SimData {

    public enum TestAttributes implements SimDataAttribute {
        ATT0_INT("att0Int",0),
        ATT1_STR("att1Str",1);

        String attributeName;
        int attributeIndex = 0;

        TestAttributes(String name, int index) {
            this.attributeIndex = index;
            this.attributeName = name;
        }

        @Override
        public int getAttributeIndex() {
            return this.attributeIndex;
        }

        @Override
        public String getAttributeName() {
            return this.attributeName;
        }
    }

    public SimDataMock(){
        super(TestAttributes.values().length, TestAttributes.ATT0_INT);
    }

    public void setValueTest(TestAttributes attribute, Comparable<?> value){
        this.setValue(attribute, value);
    }

}
