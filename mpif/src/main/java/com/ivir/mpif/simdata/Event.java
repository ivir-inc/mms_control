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

public class Event extends ConcurrentSimData<Event.Attributes> {
    public enum Attributes {

        ID,
        INSTANCE_NAME,
        LOCAL,
        TIME,
        SIM_TIME,
        TYPE,
        SOURCE,
        PATIENT_ID,
        LEARNER_ID,
        INSTRUCTOR_ID,
        TEAM_ID,
        NOTES,
        DESCRIPTION,
        TRAINING_FACILITY_ID_STR,
        LEARNER_ACTION_ENUM

    }// Attributes

    public Event() {
        super(Attributes.class, Attributes.ID, true);
    }

    public String getId(){
        return this.getIndex();
    }

    public String getInstanceName() {
        return this.getValue(Attributes.INSTANCE_NAME, String.class);
    }

    public void setInstanceName(String instanceName) {
        this.setValue(Attributes.INSTANCE_NAME, instanceName);
    }

    public Boolean isLocal() {
        return this.getValue(Attributes.LOCAL, Boolean.class);
    }

    public void setLocal(Boolean local) {
        this.setValue(Attributes.LOCAL, local);
    }

    /**
     * time (FOM name: <code>time</code>).
     * Description from the FOM: Wallclock (epoch) time of the event.
     * Allows determination of when the event took place in epoch time.  Might be useful for looking back at when a learner had training.</i>
     */
    public Long getTime() {
        return this.getValue(Attributes.TIME, Long.class);
    }

    public void setTime(Long time) {
        this.setValue(Attributes.TIME, time);
    }

    /**
     * simTime (FOM name: <code>simTime</code>).
     * <br>Description from the FOM: <i>simulation elapsed time the event pertains to.
     * allows the assessment tool to place the event in the time sequence of events for a particular training event.</i>
     */
    public Long getSimTime() {
        return this.getValue(Attributes.SIM_TIME, Long.class);
    }

    public void setSimTime(Long time) {
        this.setValue(Attributes.SIM_TIME, time);
    }

    /**
     * type (FOM name: <code>type</code>).
     * <br>Description from the FOM: <i>Type provides a basic description of how the event was created or its importance.  Allows a system to better organize and categorize events.</i>
     */
    public EventTypeEnum getType() {
        return this.getValue(Attributes.TYPE, EventTypeEnum.class);
    }

    public void setType(EventTypeEnum type) {
        this.setValue(Attributes.TYPE, type);
    }

    /**
     * source (FOM name: <code>source</code>).
     * <br>Description from the FOM: <i>Who created the event (Federate Name)</i>
     */
    public String getSource() {
        return this.getValue(Attributes.SOURCE, String.class);
    }

    public void setSource(String name) {
        this.setValue(Attributes.SOURCE, name);
    }

    /**
     * patientId (FOM name: <code>patientId</code>).
     * <br>Description from the FOM: <i>patient the event applies to (may be null)</i>
     */
    public String getPatientId() {
        return (String) this.getValue(Attributes.PATIENT_ID);
    }

    public void setPatientId(String id) {
        this.setValue(Attributes.PATIENT_ID, id);
    }


    /**
     * learnerId (FOM name: <code>learnerId</code>).
     * <br>Description from the FOM: <i>learner the event applies to (may be null)</i>
     */
    public String getLearnerId() {
        return this.getValue(Attributes.LEARNER_ID, String.class);

    }

    public void setLearnerId(String id) {
        this.setValue(Attributes.LEARNER_ID, id);
    }

    /**
     * instructorId (FOM name: <code>instructorId</code>).
     * <br>Description from the FOM: <i>Execution unique identifier</i>
     */
    public String getInstructorId() {
        return (String) this.getValue(Attributes.INSTRUCTOR_ID);
    }

    public void setInstructorId(String id) {
        this.setValue(Attributes.INSTRUCTOR_ID, id);
    }


    /**
     * teamId (FOM name: <code>teamId</code>).
     * <br>Description from the FOM: <i>May be null.  Team the event applies to.</i>
     */
    public String getTeamId() {
        return (String) this.getValue(Attributes.TEAM_ID);
    }

    public void setTeamId(String id) {
        this.setValue(Attributes.TEAM_ID, id);
    }

    public LearnerActionEnum getLearnerAction() {
        return (LearnerActionEnum) this.getValue(Attributes.LEARNER_ACTION_ENUM);
    }

    public Event setLearnerAction(LearnerActionEnum value) {
        this.setValue(Attributes.LEARNER_ACTION_ENUM, value);
        return this;
    }

    /**
     * notes (FOM name: <code>notes</code>).
     * <br>Description from the FOM: <i>text associated with the event to provide a more detailed description of the event (may be null)</i>
     */
    public String getNotes() {
        return (String) this.getValue(Attributes.NOTES);
    }

    public void setNotes(String notes) {
        this.setValue(Attributes.NOTES, notes);
    }

    /**
     * description (FOM name: <code>description</code>).
     * <br>Description from the FOM: <i>A longer description of the contents of the notes attribute</i>
     */
    public String getDescription() {
        return (String) this.getValue(Attributes.DESCRIPTION);
    }

    public void setDescription(String description) {
        this.setValue(Attributes.DESCRIPTION, description);
    }

    public String getTrainingFacilityId() {
        return this.getValue(Attributes.TRAINING_FACILITY_ID_STR, String.class);
    }

    public void setTrainingFacilityId(String facilityId) {
        this.setValue(Attributes.TRAINING_FACILITY_ID_STR, facilityId);
    }

}
