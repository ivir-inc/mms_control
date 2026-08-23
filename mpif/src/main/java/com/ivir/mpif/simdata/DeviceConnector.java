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
 * @author lewanw
 */
public class DeviceConnector extends SimData{
    public enum Attributes implements SimDataAttribute{

    	ID("id", 0),
        NAME("name",1),
        HOST("host",2),
        PORT("port",3),
        STATUS("status",4),
        MESSAGE("message",5);

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
 
    public DeviceConnector(){
         super(Attributes.values().length, Attributes.ID);
    }

    public String getId(){
        return (String)this.getValue(Attributes.ID);
    }
    
    public void setId(String id){
        this.setValue(Attributes.ID, id);
    }
    
    public String getName(){
        return (String)this.getValue(Attributes.NAME);
    }
    
    public void setName(String name){
        this.setValue(Attributes.NAME, name);
    }

    public String getHost(){
        return (String)this.getValue(Attributes.HOST);
    }
    
    public void setHost(String host){
        this.setValue(Attributes.HOST, host);
    }

    public Integer getPort(){
        return (Integer) this.getValue(Attributes.PORT);
    }
    
    public void setPort(Integer port){
        this.setValue(Attributes.PORT, port);
    }

    public String getStatus(){
        return (String)this.getValue(Attributes.STATUS);
    }
    
    public void setStatus(String status){
        this.setValue(Attributes.STATUS, status);
    }    

    public String getMessage(){
        return (String)this.getValue(Attributes.MESSAGE);
    }
    
    public void setMessage(String message){
        this.setValue(Attributes.MESSAGE, message);
    }    
}
