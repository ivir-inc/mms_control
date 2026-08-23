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

import java.util.Base64;
import java.util.StringJoiner;

public class MedicalDocument extends ConcurrentSimData<MedicalDocument.Attributes>{
	private static final long serialVersionUID = -7695141078620301454L;

    public enum Attributes{
        AUTO_ID_LON,
        PATIENT_ID_STR,
        FACILITY_ID_STR,
        PAGE_NUM_INT,
        PAGE_TOTAL_INT,
        PAGE_NAME_STR,
        DOC_EXTENSION_STR,
        DOC_BASE64_STR,
        GHOSTED_BOL,
        SOURCE_ENUM
    }
    
    public MedicalDocument() {
        super(Attributes.class, Attributes.AUTO_ID_LON, true);
    }
    
    public Long getAutoId(){
        return  this.getValue(Attributes.AUTO_ID_LON, Long.class);
    }

    public MedicalDocument setAutoId(Long id){
        this.setValue(Attributes.AUTO_ID_LON, id);
        return this;
    }    
    
    public String getPatientId() {
    	return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }
    
    public MedicalDocument setPatientId(String patientId) {
    	this.setValue(Attributes.PATIENT_ID_STR, patientId);
    	return this;
    }
    
    public String getFacilityId() {
    	return (String) this.getValue(Attributes.FACILITY_ID_STR);
    }
    
    public MedicalDocument setFacilityId(String facilityId) {
    	this.setValue(Attributes.FACILITY_ID_STR, facilityId);
    	return this;
    }
    
    public Integer getPageNum() {
    	return (Integer) this.getValue(Attributes.PAGE_NUM_INT);
    }
    
    public MedicalDocument setPageNum(Integer pageNum) {
    	this.setValue(Attributes.PAGE_NUM_INT, pageNum);
    	return this;
    }
    
    public Integer getPageTotal() {
    	return (Integer) this.getValue(Attributes.PAGE_TOTAL_INT);
    }
    
    public MedicalDocument setPageTotal(Integer pageTotal) {
    	this.setValue(Attributes.PAGE_TOTAL_INT, pageTotal);
    	return this;
    }
    
    public String getPageName() {
    	return (String) this.getValue(Attributes.PAGE_NAME_STR);
    }
    
    public MedicalDocument setPageName(String name) {
    	this.setValue(Attributes.PAGE_NAME_STR, name);
    	return this;
    }

    public String getDocExtension() {
    	return (String) this.getValue(Attributes.DOC_EXTENSION_STR);
    }
    
    public MedicalDocument setDocExtension(String docExt) {
    	this.setValue(Attributes.DOC_EXTENSION_STR, docExt);
    	return this;
    }
    
    public String getDocBase64() {
    	return (String)this.getValue(Attributes.DOC_BASE64_STR);
    }
    
    public MedicalDocument setDocBase64(String docBaseStr) {
    	this.setValue(Attributes.DOC_BASE64_STR, docBaseStr);
    	return this;
    }
    
    public byte[] getDocBytes() {
    	String docBase64 = getDocBase64();
    	if(docBase64 == null) {
    		return new byte[0];
    	}
    	if(docBase64.isEmpty()) {
    		return new byte[0];
    	}
    	return Base64.getDecoder().decode(docBase64);
    }
    
    public MedicalDocument setDocBytes(byte[] byteData) {
    	if((byteData == null) || (byteData.length == 0)) {
    		setDocBase64(null);
    		return this;
    	}
    	setDocBase64(Base64.getEncoder().encodeToString(byteData));
    	return this;
    }
    
    public Boolean getGhosted() {
    	return (Boolean) this.getValue(Attributes.GHOSTED_BOL);
    }
    
    public MedicalDocument setGhosted(Boolean ghosted) {
    	this.setValue(Attributes.GHOSTED_BOL, ghosted);
    	return this;
    }
    
    public MedDocSourceEnum getSource() {
    	return (MedDocSourceEnum) this.getValue(Attributes.SOURCE_ENUM);
    }
    
    public MedicalDocument setSource(MedDocSourceEnum source) {
    	this.setValue(Attributes.SOURCE_ENUM, source);
    	return this;
    }
    
    /**
     * Using the attributes in this MedicalDocument, create a full file by combining them.
     * @return "full" file name
     */
    public String buildFullFileName() {
    	StringJoiner stringJoiner = new StringJoiner("_");
    	
    	if(this.getFacilityId() != null) {
    		stringJoiner.add(this.getFacilityId());
    	}
    	
    	if(this.getPatientId() != null) {
    		stringJoiner.add(this.getPatientId());
       	}
    	
    	String fileWithPage = buildFileNameWithPage();
    	if(fileWithPage.isEmpty()) {
    		return stringJoiner.toString();
    	}
    	
    	return stringJoiner.toString() + "_" + fileWithPage;
    }
    
    /**
     * Build a file name including the page number.  It does NOT include patient ID or facility ID
     * @return file name with page number
     */
    public String buildFileNameWithPage() {
    	StringJoiner stringJoiner = new StringJoiner("_");
	    	
    	if(this.getPageName() != null) {
    		stringJoiner.add(this.getPageName());
    	}else {
    		stringJoiner.add("anon");
    	}
    	
    	stringJoiner.add(createPageKey());
    	
    	if(this.getDocExtension() != null) {
    		return stringJoiner.toString() + "." + this.getDocExtension().toLowerCase();
    	}
    	return stringJoiner.toString();
    }
    
    public String createPageKey() {
    	Integer currentPg = this.getPageNum();
    	Integer totalPg = this.getPageTotal();
    	if(currentPg == null) {
    		currentPg = 0;
    	}
    	if(totalPg == null) {
    		totalPg = 0;
    	}
    	return "cp"+currentPg.toString()+"tp"+totalPg.toString()+"x";
    }
    
}

