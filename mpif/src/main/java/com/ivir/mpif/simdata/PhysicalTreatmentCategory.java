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

public enum PhysicalTreatmentCategory {
    AIRWAY(1),
    CIRCULATION(3),
    HYPOTHERMIA(4),
    GENERAL(5),
    MASSIVE_HEMORRHAGE(0),
    RESPIRATION(2);

    private int order;
    private PhysicalTreatmentCategory(int order){
        this.order = order;
    }

    public int getOrder(){
        return this.order;
    }
}
