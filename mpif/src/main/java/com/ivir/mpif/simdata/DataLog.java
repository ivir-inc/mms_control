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

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.ivir.mpif.simdata;

/**
 *
 * @author blewa
 */
public class DataLog extends SimData {

    public enum Attributes implements SimDataAttribute {

        INSTANCE_NAME("instanceName", 0),
        GHOSTED("ghosted", 1),
        TIME("time", 2),
        SOURCE("source", 3),
        DATA("data", 4);

        String attributeName = null;
        int attributeIndex = 0;

        private Attributes(String name, int index) {
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
    }// Attributes

    public DataLog() {
        super(Attributes.values().length, Attributes.INSTANCE_NAME);
    }

    public String getInstanceName() {
        return (String) this.getValue(Attributes.INSTANCE_NAME);
    }

    public void setInstanceName(String name) {
        this.setValue(Attributes.INSTANCE_NAME, name);
    }

    public Boolean getGhosted() {
        return (Boolean) this.getValue(Attributes.GHOSTED);
    }

    public void setGhosted(Boolean ghost) {
        this.setValue(Attributes.GHOSTED, ghost);
    }

    /**
     * Gets the value of the <code>time</code> attribute.
     *
     * <br>Description from the FOM: <i>Time the data was logged in system
     * time</i>
     * <br>Description of the data type from the FOM: <i>Standardized 64 bit
     * integer time [unit: NA, resolution: 1, accuracy: NA]</i>
     *
     * @return time in ms
     */
    public Long getTime() {
        return (Long) this.getValue(Attributes.TIME);
    }

    /**
     * Sets the value of the <code>time</code> attribute.
     *
     * <br>Description from the FOM: <i>Time the data was logged in system
     * time</i>
     * <br>Description of the data type from the FOM: <i>Standardized 64 bit
     * integer time [unit: NA, resolution: 1, accuracy: NA]</i>
     */
    public void setTime(Long time) {
        this.setValue(Attributes.TIME, time);
    }

    /**
     * Gets the value of the <code>source</code> attribute.
     *
     * <br>Description from the FOM: <i>Name of the federate doing the
     * logging</i>
     * <br>Description of the data type from the FOM: <i></i>
     *
     * @return the <code>source</code> attribute.
     */
    public String getSource() {
        return (String) this.getValue(Attributes.SOURCE);
    }

    /**
     * Sets the value of the <code>source</code> attribute.
     *
     * <br>Description from the FOM: <i>Name of the federate doing the
     * logging</i>
     * <br>Description of the data type from the FOM: <i></i>
     *
     *
     */
    public void setSource(String source) {
        this.setValue(Attributes.SOURCE, source);
    }

    /**
     * Gets the value of the <code>data</code> attribute.
     *
     * <br>Description from the FOM: <i>A string representing the logged data.
     * Sender and receiver will be responsible for parsing the string to produce
     * data.</i>
     * <br>Description of the data type from the FOM: <i></i>
     *
     * @return the <code>data</code> attribute.
     */
    public String getData() {
        return (String) this.getValue(Attributes.DATA);
    }

    /**
     * Gets the value of the <code>data</code> attribute.
     *
     * <br>Description from the FOM: <i>A string representing the logged data.
     * Sender and receiver will be responsible for parsing the string to produce
     * data.</i>
     * <br>Description of the data type from the FOM: <i></i>
     *
     */
    public void setData(String data) {
        this.setValue(Attributes.DATA, data);
    }
}
