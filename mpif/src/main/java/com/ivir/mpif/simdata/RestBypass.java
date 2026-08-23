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

public class RestBypass extends ConcurrentSimData<RestBypass.Attributes>{
	private static final long serialVersionUID = 6302870363193832639L;

    public enum Attributes{
        AUTO_ID,
        MESSAGE_ID,
        REQUESTOR,
        RESPONDER,
        STATUS,
        CALL_METHOD,
        PATH,
        REQUEST_PAYLOAD,
        RESULT_CODE,
        RESULT_PAYLOAD
    }

    public RestBypass(){
        super(Attributes.class, Attributes.AUTO_ID, true);
    }

    public String getAutoId(){
        return (String) this.getValue(Attributes.AUTO_ID);
    }

    public RestBypass setAutoId(String id){
        this.setValue(Attributes.AUTO_ID, id);
        return this;
    }

    public String getMessageId(){
        return (String) this.getValue(Attributes.MESSAGE_ID);
    }

    public RestBypass setMessageId(String messageId){
        this.setValue(Attributes.MESSAGE_ID, messageId);
        return this;
    }

    public String getRequestor(){
        return (String) this.getValue(Attributes.REQUESTOR);
    }

    public RestBypass setRequestor(String requestor){
        this.setValue(Attributes.REQUESTOR, requestor);
        return this;
    }

    public String getResponder(){
        return (String) this.getValue(Attributes.RESPONDER);
    }

    public RestBypass setResponder(String responder){
        this.setValue(Attributes.RESPONDER, responder);
        return this;
    }

    public RestBypassStatusEnum getStatus(){
        return (RestBypassStatusEnum) this.getValue(Attributes.STATUS);
    }

    public RestBypass setStatus(RestBypassStatusEnum statusEnum){
        this.setValue(Attributes.STATUS, statusEnum);
        return this;
    }

    public String getCallMethod(){
        return (String) this.getValue(Attributes.CALL_METHOD);
    }

    public RestBypass setCallMethod(String method){
        this.setValue(Attributes.CALL_METHOD, method);
        return this;
    }

    public String getPath(){
        return (String) this.getValue(Attributes.PATH);
    }

    public RestBypass setPath(String path){
        this.setValue(Attributes.PATH, path);
        return this;
    }

    public String getRequestPayload(){
        return (String) this.getValue(Attributes.REQUEST_PAYLOAD);
    }

    public RestBypass setRequestPayload(String payload){
        this.setValue(Attributes.REQUEST_PAYLOAD, payload);
        return this;
    }

    public Integer getResultCode(){
        return (Integer) this.getValue(Attributes.RESULT_CODE);
    }

    public RestBypass setResultCode(Integer code){
        this.setValue(Attributes.RESULT_CODE, code);
        return this;
    }

    public String getResultPayload(){
        return (String) this.getValue(Attributes.RESULT_PAYLOAD);
    }

    public RestBypass setResultPayload(String payload){
        this.setValue(Attributes.RESULT_PAYLOAD, payload);
        return this;
    }
    
    @Override
    public RestBypass clone() throws CloneNotSupportedException {
        return (RestBypass) super.clone();
    }
    
}
