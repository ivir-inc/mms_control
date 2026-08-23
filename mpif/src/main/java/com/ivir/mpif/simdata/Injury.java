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

public class Injury extends ConcurrentSimData<Injury.Attributes>{

	private static final long serialVersionUID = 23542315278278004L;
	    
	public enum Attributes{
        AUTO_ID,
        INSTANCE_NAME_STR,
        LOCAL_BOOL,
        PATIENT_ID_STR,
        INJURY_ID_STR,
        TIME_LON,
        LOCATION_OBJ,
        INJURY_TYPE_ENUM,
        DESCRIPTION_ENUM,
        DETAIL_STR,
        SEVERITY_INT,
        MECHANISM_OF_INJURY_OBJ,
        HEMORRHAGE_RATE_FLT,
        TOTAL_BODY_SURFACE_AREA_FLT,
        NAME_STR

    }//Attributes

    public Injury(){
        super(Attributes.class, Attributes.AUTO_ID, true);
    }

    public String getInstanceName() {
        return this.getValue(Attributes.INSTANCE_NAME_STR, String.class);
    }

    public Injury setInstanceName(String instanceName) {
        this.setValue(Attributes.INSTANCE_NAME_STR, instanceName);
        return this;
    }

    public Boolean isLocal(){
        return this.getValue(Attributes.LOCAL_BOOL, Boolean.class);
    }

    public Injury setLocal(Boolean isLocal){
        this.setValue(Attributes.LOCAL_BOOL, isLocal);
        return this;
    }

    public String getPatientId() {
        return this.getValue(Attributes.PATIENT_ID_STR, String.class);
    }

    public Injury setPatientId(String patientId) {
    	this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getInjuryId() {
        return this.getValue(Attributes.INJURY_ID_STR, String.class);
    }

    public Injury setInjuryId(String injuryId) {
        this.setValue(Attributes.INJURY_ID_STR, injuryId);
        return this;
    }

    public BodyLocation getLocation() {
        return this.getValue(Attributes.LOCATION_OBJ, BodyLocation.class);
    }

    public Injury setLocation(BodyLocation location) {
        this.setValue(Attributes.LOCATION_OBJ, location);
        return this;
    }

    public Long getTime() {
    	return this.getValue(Attributes.TIME_LON, Long.class);
    }

    public Injury setTime(Long time) {
        this.setValue(Attributes.TIME_LON, time);
        return this;
    }

    public InjuryDescription getDescription() {
        return this.getValue(Attributes.DESCRIPTION_ENUM, InjuryDescription.class);
    }

    public Injury setDescription(InjuryDescription description) {
    	this.setValue(Attributes.DESCRIPTION_ENUM, description);
        return this;
    }

    public InjuryType getInjuryType() {
        return this.getValue(Attributes.INJURY_TYPE_ENUM, InjuryType.class);
    }

    public Injury setInjuryType(InjuryType injuryType) {
    	this.setValue(Attributes.INJURY_TYPE_ENUM, injuryType);
        return this;
    }

    public String getDetail(){
        return this.getValue(Attributes.DETAIL_STR, String.class);
    }

    public Injury setDetail(String detail){
        this.setValue(Attributes.DETAIL_STR, detail);
        return this;
    }

    public InjuryObjectType getInjuryObjectType(){
        return (InjuryObjectType) this.getValue(Attributes.INJURY_TYPE_ENUM);
    }

    public Injury setInjuryObjectType(InjuryObjectType objectType){
        this.setValue(Attributes.INJURY_TYPE_ENUM, objectType);
        return this;
    }

    public Integer getSeverity() {
        return this.getValue(Attributes.SEVERITY_INT, Integer.class);
    }

    public Injury setSeverity(Integer severity) {
    	this.setValue(Attributes.SEVERITY_INT, severity);
        return this;
    }

    public MechanismOfInjury getMechanismOfInjury(){
        return this.getValue(Attributes.MECHANISM_OF_INJURY_OBJ, MechanismOfInjury.class);
    }

    public Injury setMechanismOfInjury(MechanismOfInjury moi){
        this.setValue(Attributes.MECHANISM_OF_INJURY_OBJ, moi);
        return this;
    }

    public Float getHemorrhageRate(){
        return this.getValue(Attributes.HEMORRHAGE_RATE_FLT, Float.class);
    }

    public Injury setHemorrhageRate(Float rate){
        this.setValue(Attributes.HEMORRHAGE_RATE_FLT, rate);
        return this;
    }

    public Float getTotalBodySurfaceArea(){
        return getValue(Attributes.TOTAL_BODY_SURFACE_AREA_FLT, Float.class);
    }

    public Injury setTotalBodySurfaceArea(Float tbsa){
        this.setValue(Attributes.TOTAL_BODY_SURFACE_AREA_FLT, tbsa);
        return this;
    }

    public String getName(){
        return getValue(Attributes.NAME_STR, String.class);
    }

    public Injury setName(String name){
        setValue(Attributes.NAME_STR, name);
        return this;
    }
}
