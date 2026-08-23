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

package com.ivir.mpif.sceneng.impl;
import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.sceneng.rules.ReservedFacts;
import org.jeasy.rules.api.Facts;
import org.jeasy.rules.api.Rules;

public class ScenarioData {
    private Rules rules;
    private Facts facts;
    private PatientId patientId;
    private long startTime;
    private boolean running;

    public ScenarioData(PatientId patientId, Rules rules){
       this.rules = rules;
       this.facts = new Facts();
       this.startTime = 0;
       this.running = false;
       this.patientId = patientId;
       initializeFacts();
    }

    private void initializeFacts(){
        this.facts.put(ReservedFacts.HEART_RATE_INT.getFactId(), 0);
    }

    public Rules getRules(){
        return this.rules;
    }

    public Facts getFacts(){
        return this.facts;
    }

    public long getStartTime() {
        return startTime;
    }

    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }

    public boolean isRunning() {
        return running;
    }

    public void setRunning(boolean running) {
        this.running = running;
    }

    public PatientId getPatientId(){
        return patientId;
    }
}
