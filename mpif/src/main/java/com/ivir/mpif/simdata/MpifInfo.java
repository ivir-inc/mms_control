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

public class MpifInfo extends SimData{

    public static String localInstanceName = "MPIF_Local_Instance";

    public enum Attributes implements SimDataAttribute{
        INSTANCE_NAME("instanceName",0),
        GHOSTED("ghosted",1),
        FEDERATE_NAME("federateName",2),
        PATIENT_ID("patientId",3),
        CONNECTORS_STR("connectors",4);

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

    public MpifInfo() {
        super(Attributes.values().length, Attributes.INSTANCE_NAME);
    }

    public String getInstanceName() {
        return (String) this.getValue(Attributes.INSTANCE_NAME);
    }

    public MpifInfo setInstanceName(String instanceName) {
        this.setValue(Attributes.INSTANCE_NAME, instanceName);
        return this;
    }

    public Boolean isGhosted() {
        return (Boolean) this.getValue(Attributes.GHOSTED);
    }

    public MpifInfo setGhosted(Boolean ghosted) {
        this.setValue(Attributes.GHOSTED, ghosted);
        return this;
    }

    public String getFederateName(){
        return (String) this.getValue(Attributes.FEDERATE_NAME);
    }

    public MpifInfo setFederateName(String name){
        this.setValue(Attributes.FEDERATE_NAME, name);
        return this;
    }

    public String getPatientId(){
        return (String) this.getValue(Attributes.PATIENT_ID);
    }

    public MpifInfo setPatientId(String patientId){
        this.setValue(Attributes.PATIENT_ID, patientId);
        return this;
    }
    
    public String getConnectors() {
    	return (String) this.getValue(Attributes.CONNECTORS_STR);
    }
    
    public MpifInfo setConnectors(String pipeStr) {
    	this.setValue(Attributes.CONNECTORS_STR, pipeStr);
    	return this;
    }

    @Override
    public String toString(){
        StringBuffer stringBuffer = new StringBuffer("MpifInfo{");
        for(Attributes attribute : Attributes.values()){
            stringBuffer.append(attribute).append(" : ").append(getValue(attribute)).append(",\n");
        }
        stringBuffer.append("}");
        return stringBuffer.toString();
    }
}
