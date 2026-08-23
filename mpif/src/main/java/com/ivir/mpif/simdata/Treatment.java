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

import com.ivir.mpif.common.PatientId;

public class Treatment extends ConcurrentSimData<Treatment.Attributes> {

	public enum Attributes{
		AUTO_ID,
		INSTANCE_NAME,
		LOCAL_BOOL,
		CLASS_TYPE,
		TREATMENT_ID,
		TREATMENT_LOCATION,
		PATIENT_ID_OBJ,
		INJURY_ID,
		TREATMENT_TIME,
		TREATMENT_ACTIVE,
		// Physical specific items
		TREATMENT,
		DEVICE_USED,
		// medication specific items
		ADMINISTRATION_ROUTE,
		MEDICATION_ENUM,
		DOSAGE_VALUE,
		DOSAGE_TIME_PERIOD,
	}// Attributes

	public Treatment() {
		super(Attributes.class, Attributes.AUTO_ID, true);
	}

	public Long getAutoId(){
		return (Long)this.getValue(Attributes.AUTO_ID);
	}

	public Treatment setAutoId(Long id) {
		this.setValue(Attributes.AUTO_ID, id);
		return this;
	}

	public String getInstanceName() {
		return (String) this.getValue(Attributes.INSTANCE_NAME);
	}

	public Treatment setInstanceName(String instanceName) {
		this.setValue(Attributes.INSTANCE_NAME, instanceName);
		return this;
	}

	public Boolean isLocal() {
		return (Boolean) this.getValue(Attributes.LOCAL_BOOL);
	}

	public Treatment setLocal(Boolean local) {
		this.setValue(Attributes.LOCAL_BOOL, local);
		return this;
	}

	public TreatmentClassType getClassType() {
		return (TreatmentClassType) this.getValue(Attributes.CLASS_TYPE);
	}

	public Treatment setClassType(TreatmentClassType type) {
		this.setValue(Attributes.CLASS_TYPE, type);
		return this;
	}

	/**
	 * treatmentId (FOM name: <code>treatmentId</code>). <br>
	 * Description from the FOM: <i>The treatmentId is a unique value which
	 * associates a treatment to an injury and a patient. Once a treatmentId is
	 * created, it cannot be reused during an execution. Naming Convention:
	 * Treatment_uniquevalue</i>
	 */
	public String getTreatmentId() {
		return (String) this.getValue(Attributes.TREATMENT_ID);
	}

	/**
	 * treatmentId (FOM name: <code>treatmentId</code>). <br>
	 * Description from the FOM: <i>The treatmentId is a unique value which
	 * associates a treatment to an injury and a patient. Once a treatmentId is
	 * created, it cannot be reused during an execution. Naming Convention:
	 * Treatment_uniquevalue</i>
	 */
	public Treatment setTreatmentId(String id) {
		this.setValue(Attributes.TREATMENT_ID, id);
		return this;
	}

	/**
	 * Gets the value of the <code>treatmentLocation</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>May be null. Used to specify what part of the
	 * body a treatment is applied to IF a treatment is applied to a specific body
	 * location.</i> <br>
	 * Description of the data type from the FOM: <i>A dynamic length array of
	 * Coarse Body Locations to designate an "area"</i>
	 *
	 * @return the <code>treatmentLocation</code> attribute.
	 */
	public BodyLocation getTreatmentLocation() {
		return getValue(Attributes.TREATMENT_LOCATION, BodyLocation.class);
	}

	/**
	 * Sets the value of the <code>treatmentLocation</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>May be null. Used to specify what part of the
	 * body a treatment is applied to IF a treatment is applied to a specific body
	 * location.</i> <br>
	 * Description of the data type from the FOM: <i>A dynamic length array of
	 * Coarse Body Locations to designate an "area"</i>
	 *
	 */
	public Treatment setTreatmentLocation(BodyLocation location) {
		this.setValue(Attributes.TREATMENT_LOCATION, location);
		return this;
	}

	/**
	 * Gets the value of the <code>patientId</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>patientId associates a particular patient to a
	 * particular injuryId. Once a Patient object is created, the ID is static and
	 * cannot be changed or reused during an execution.</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 *
	 * @return the <code>patientId</code> attribute.
	 *
	 */
	public PatientId getPatientId() {
		return (PatientId) this.getValue(Attributes.PATIENT_ID_OBJ);
	}

	/**
	 * Sets the value of the <code>patientId</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>patientId associates a particular patient to a
	 * particular injuryId. Once a Patient object is created, the ID is static and
	 * cannot be changed or reused during an execution.</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 *
	 */
	public Treatment setPatientId(String id) {
		this.setValue(Attributes.PATIENT_ID_OBJ, new PatientId(id));
		return this;
	}

	public Treatment setPatientId(PatientId id) {
		this.setValue(Attributes.PATIENT_ID_OBJ, id);
		return this;
	}

	/**
	 * Gets the value of the <code>injuryId</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>May be null. Associates a treatment with a
	 * unique injury or symptom. If null, indicates that the treatment is not
	 * associated with a specific injury... for example, a treatment (oxygen
	 * administered to a patient at high altitude) may not be associated with a
	 * specific injury but rather to make the patient more comfortable.</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 *
	 * @return the <code>injuryId</code> attribute.
	 */
	public String getInjuryId() {
		return (String) this.getValue(Attributes.INJURY_ID);
	}

	/**
	 * Sets the value of the <code>injuryId</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>May be null. Associates a treatment with a
	 * unique injury or symptom. If null, indicates that the treatment is not
	 * associated with a specific injury... for example, a treatment (oxygen
	 * administered to a patient at high altitude) may not be associated with a
	 * specific injury but rather to make the patient more comfortable.</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 */
	public Treatment setInjuryId(String id) {
		this.setValue(Attributes.INJURY_ID, id);
		return this;
	}

	/**
	 * Gets the value of the <code>treatmentTime</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>This attribute indicates the time the treatment
	 * in simulation elapsed time</i> <br>
	 * Description of the data type from the FOM: <i>Standardized 64 bit integer
	 * time [unit: NA, resolution: 1, accuracy: NA]</i>
	 *
	 * @return the <code>treatmentTime</code> attribute.
	 *
	 */
	public Long getTreatmentTime() {
		return (Long) this.getValue(Attributes.TREATMENT_TIME);
	}

	/**
	 * Sets the value of the <code>treatmentTime</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>This attribute indicates the time the treatment
	 * in simulation elapsed time</i> <br>
	 * Description of the data type from the FOM: <i>Standardized 64 bit integer
	 * time [unit: NA, resolution: 1, accuracy: NA]</i>
	 *
	 */
	public Treatment setTreatmentTime(Long timeMs) {
		this.setValue(Attributes.TREATMENT_TIME, timeMs);
		return this;
	}

	/**
	 * Gets the value of the <code>treatment</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Enumeration of the types of physical treatment
	 * administered to a patient.</i> <br>
	 * Description of the data type from the FOM: <i>Types of physical treatments
	 * that can be administered to a patient.</i>
	 *
	 * @return the <code>treatment</code> attribute.
	 */
	public PhysicalTreatmentType getTreatment() {
		return (PhysicalTreatmentType) this.getValue(Attributes.TREATMENT);
	}

	/**
	 * Sets the value of the <code>treatment</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Enumeration of the types of physical treatment
	 * administered to a patient.</i> <br>
	 * Description of the data type from the FOM: <i>Types of physical treatments
	 * that can be administered to a patient.</i>
	 *
	 */
	public Treatment setTreatment(PhysicalTreatmentType type) {
		this.setValue(Attributes.TREATMENT, type);
		return this;
	}

	/**
	 * Gets the value of the <code>deviceUsed</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>What device was used to administer the
	 * treatment</i> <br>
	 * Description of the data type from the FOM: <i>Type of medical device that can
	 * be used in physical treatments administration.</i>
	 *
	 * @return the <code>deviceUsed</code> attribute.
	 *
	 */
	public TreatmentDevice getDeviceUsed() {
		return (TreatmentDevice) this.getValue(Attributes.DEVICE_USED);
	}

	/**
	 * sets the value of the <code>deviceUsed</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>What device was used to administer the
	 * treatment</i> <br>
	 * Description of the data type from the FOM: <i>Type of medical device that can
	 * be used in physical treatments administration.</i>
	 *
	 */
	public Treatment setDeviceUsed(TreatmentDevice device) {
		this.setValue(Attributes.DEVICE_USED, device);
		return this;
	}

	/**
	 * Gets the value of the <code>treatmentActive</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Used to identify whether the treatment is active
	 * or inactive. True/1 = Active, False/0 = inactive</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 *
	 * @return the <code>treatmentActive</code> attribute.
	 */
	public Boolean getTreatmentActive() {
		return (Boolean) this.getValue(Attributes.TREATMENT_ACTIVE);
	}

	/**
	 * sets the value of the <code>treatmentActive</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Used to identify whether the treatment is active
	 * or inactive. True/1 = Active, False/0 = inactive</i> <br>
	 * Description of the data type from the FOM: <i></i>
	 *
	 */
	public Treatment setTreatmentActive(Boolean active) {
		this.setValue(Attributes.TREATMENT_ACTIVE, active);
		return this;
	}
	
	/**
	 * Gets the value of the <code>administrationRoute</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Route by which the medication is
	 * administered.</i> <br>
	 * Description of the data type from the FOM: <i>Administration routes for
	 * administering medication</i>
	 *
	 * @return the <code>administrationRoute</code> attribute.
	 *
	 */
	public MedicationAdministrationRoute getAdministrationRoute() {
		return (MedicationAdministrationRoute) this.getValue(Attributes.ADMINISTRATION_ROUTE);
	}
	
	/**
	 * sets the value of the <code>administrationRoute</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Route by which the medication is
	 * administered.</i> <br>
	 * Description of the data type from the FOM: <i>Administration routes for
	 * administering medication</i>
	 *
	 */
	public Treatment setAdministrationRoute(MedicationAdministrationRoute route) {
		this.setValue(Attributes.ADMINISTRATION_ROUTE, route);
		return this;
	}

	/**
	 * Gets the value of the <code>dosageValue</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Amount of medication administered. The base
	 * units are ml or mg depending on the medication.</i> <br>
	 * Description of the data type from the FOM: <i>Basic Data Types (e.g.
	 * HLAfloat32BE) cannot be used directly. FloatType32BE is a Simple data type
	 * that can be used directly. [unit: NA, resolution: NA, accuracy: NA]</i>
	 *
	 * @return the <code>dosageValue</code> attribute.
	 *
	 */
	public Float getDosageValue() {
		return (Float) this.getValue(Attributes.DOSAGE_VALUE);
	}

	/**
	 * Sets the value of the <code>dosageValue</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>Amount of medication administered. The base
	 * units are ml or mg depending on the medication.</i> <br>
	 * Description of the data type from the FOM: <i>Basic Data Types (e.g.
	 * HLAfloat32BE) cannot be used directly. FloatType32BE is a Simple data type
	 * that can be used directly. [unit: NA, resolution: NA, accuracy: NA]</i>
	 *
	 */
	public Treatment setDosageValue(Float value) {
		this.setValue(Attributes.DOSAGE_VALUE, value);
		return this;
	}
	
	/**
	 * Gets the value of the <code>dosageTimePeriod</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>The time period over which the medication is
	 * administered. If the value is 0, the medication is administered as a bolus.
	 * The base time period is minutes.</i> <br>
	 * Description of the data type from the FOM: <i>Basic Data Types (e.g.
	 * HLAinteger32BE) cannot be used directly. Integer32BE is a Simple data type
	 * that can be used directly. [unit: NA, resolution: NA, accuracy: NA]</i>
	 *
	 * @return the <code>dosageTimePeriod</code> attribute.
	 *
	 */
	public Integer getDosageTimePeriod() {
		return (Integer) this.getValue(Attributes.DOSAGE_TIME_PERIOD);
	}

	/**
	 * Sets the value of the <code>dosageTimePeriod</code> attribute.
	 *
	 * <br>
	 * Description from the FOM: <i>The time period over which the medication is
	 * administered. If the value is 0, the medication is administered as a bolus.
	 * The base time period is minutes.</i> <br>
	 * Description of the data type from the FOM: <i>Basic Data Types (e.g.
	 * HLAinteger32BE) cannot be used directly. Integer32BE is a Simple data type
	 * that can be used directly. [unit: NA, resolution: NA, accuracy: NA]</i>
	 *
	 */
	public Treatment setDosageTimePeriod(Integer period) {
		this.setValue(Attributes.DOSAGE_TIME_PERIOD, period);
		return this;
	}

	public Medication getMedication(){
		return this.getValue(Attributes.MEDICATION_ENUM,Medication.class);
	}

	public Treatment setMedication(Medication medication){
		this.setValue(Attributes.MEDICATION_ENUM, medication);
		return this;
	}
}
