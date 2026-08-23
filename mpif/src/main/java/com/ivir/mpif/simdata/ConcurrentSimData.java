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
import java.util.EnumMap;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class ConcurrentSimData<E extends Enum<E>> implements Cloneable, Serializable{

    private EnumMap<E, Comparable> values;
    private Set<E> updatedAttributes;
    private E indexAttribute = null;
    private boolean autoIndex = false;

    public ConcurrentSimData(Class<E> enumType, E indexAttribute){
        this(enumType, indexAttribute, false);
    }

    public ConcurrentSimData(Class<E> enumType, E indexAttribute, boolean autoIdIndex) {
        this.values = new EnumMap<>(enumType);
        this.indexAttribute = indexAttribute;
        this.autoIndex = autoIdIndex;
        this.updatedAttributes = new HashSet<>();
    }

    protected boolean hasAutoIndex(){
        return this.autoIndex;
    }

    protected synchronized void setValue(E att, Comparable<?> value){
        boolean updateValue = false;
        if(this.values.get(att) != null){
            if(!this.values.get(att).equals(value)){
                updateValue = true;
            }
        }else{
            if(value != null){
                updateValue = true;
            }
        }

        if(updateValue){
            this.values.put(att, value);
            this.updatedAttributes.add(att);
        }
    }

    protected synchronized void resetUpdateSet(){
        this.updatedAttributes.clear();
    }

    public Set<E> getUpdatedAttributes(){
        return this.updatedAttributes;
    }
    
    protected Comparable<?> getValue(E att){
        return this.values.get(att);
    }

    protected <T> T getValue(E att,  Class<T> castType){
        return castType.cast(this.getValue(att));
    }

    protected void setIndex(Comparable value){
        setValue(this.indexAttribute, value);
    }

    protected String getIndex(){
        Comparable<?> value = getValue(this.indexAttribute);
        if(value == null){
            return null;
        }
        return value.toString();
    }

    public int compareValue(E attribute, Comparable testValue) {
        if (values.get(attribute) == null) {
            if (testValue == null) {
                return 0;
            } else {
                return -1;
            }
        }
        return values.get(attribute).compareTo(testValue);
    }  
    
    @Override
    public String toString(){
        StringBuffer buffer = new StringBuffer();
        values.forEach((key, value)->{
            buffer.append(key).append(": ").append(value).append(",");
        });
        return buffer.toString();
    }

    @Override
    public ConcurrentSimData clone() throws CloneNotSupportedException {
        return (ConcurrentSimData) super.clone();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ConcurrentSimData<?> simData)) return false;
        return autoIndex == simData.autoIndex && Objects.equals(values, simData.values) && Objects.equals(updatedAttributes, simData.updatedAttributes) && Objects.equals(indexAttribute, simData.indexAttribute);
    }

    @Override
    public int hashCode() {
        return Objects.hash(values, updatedAttributes, indexAttribute, autoIndex);
    }
}
