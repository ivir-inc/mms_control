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

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class LabEntries implements Comparable, Serializable {
    private HashMap<String,Float> nameToValueMap = new HashMap<>();

    public LabEntries putValue(String name, Float value){
        this.nameToValueMap.put(name, value);
        return this;
    }

    public Float getValue(String name){
        return this.nameToValueMap.get(name);
    }

    public int size(){
        return this.nameToValueMap.size();
    }

    public Map<String,Float> getValueMap(){
        return this.nameToValueMap;
    }

    @Override
    public int compareTo(Object o) {
        if(o instanceof LabEntries) {
            LabEntries target = (LabEntries) o;
            if(this.nameToValueMap.size() != target.size()){
                return -1;
            }
            for (String name : this.nameToValueMap.keySet()) {
                Float value = this.nameToValueMap.get(name);
                if(value != null) {
                    if(value.compareTo(((LabEntries) o).getValue(name)) != 0){
                        return -1;
                    }
                }
            }
            return 0;
        }
        return -1;
    }
}
