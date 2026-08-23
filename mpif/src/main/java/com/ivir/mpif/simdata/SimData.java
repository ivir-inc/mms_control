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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;

public class SimData{
    
    private Comparable[] values;
    private long[] version;
    private SimDataAttribute indexAttribute = null;
    private final ArrayList<EntityUpdateListener> updateListener = new ArrayList<>();

    public SimData(int numOfAttributes, SimDataAttribute indexAttribute){
        values = new Comparable[numOfAttributes];
        version = new long[numOfAttributes];
        this.indexAttribute = indexAttribute;
    }

    protected synchronized void setValue(SimDataAttribute att, Comparable<?> value){
        this.values[att.getAttributeIndex()] = value;
        this.version[att.getAttributeIndex()] ++;
        fireEntityUpdateListener(att);
    }
    
    protected Comparable<?> getValue(SimDataAttribute att){
        return this.values[att.getAttributeIndex()];
    }
    
    public long getVersionNumber(SimDataAttribute att){
        return this.version[att.getAttributeIndex()] ++;
    }
    
    public String getIndex(){
        return values[this.indexAttribute.getAttributeIndex()].toString();
    }
    
    public int compareValue(SimDataAttribute att, Comparable testValue) {
    	if(values[att.getAttributeIndex()] ==  null) {
    		if(testValue == null) {
    			return 0;
    		}else {
    			return -1;
    		}
    	}
    	return values[att.getAttributeIndex()].compareTo(testValue);
    }
    
    private synchronized void fireEntityUpdateListener(SimDataAttribute attributeChanged){
        if(updateListener.size() > 0){
            new Thread(() -> updateListener.forEach((listener)->listener.entityUpdated(this, attributeChanged))).start();
        }    
    }
    
    public void addEntityUpdateListener(EntityUpdateListener listener){
        this.updateListener.add(listener);
    }
    
    public void removeEntityUpdateListener(EntityUpdateListener listener) {
    	this.updateListener.remove(listener);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SimData simData)) return false;
        return Objects.deepEquals(values, simData.values) && Objects.deepEquals(version, simData.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(Arrays.hashCode(values), Arrays.hashCode(version));
    }

    @Override
    public String toString(){
        StringBuffer buffer = new StringBuffer();
        for(Comparable value : values){
            buffer.append(value).append(",");
        }
        return buffer.toString();
    }
}
