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
import com.ivir.mpif.mconfig.MpifConfigService;
import com.ivir.mpif.pcb.PCVitals;
import com.ivir.mpif.pcb.PatientCase;
import com.ivir.mpif.pcb.PatientCaseService;
import com.ivir.mpif.sceneng.ScenarioEngineService;
import com.ivir.mpif.sceneng.rules.ReservedFacts;
import com.ivir.mpif.sceneng.rules.manual.ManualRules;
import com.ivir.mpif.sceneng.rules.model.ManualControl;
import com.ivir.mpif.simdata.OwnershipState;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import org.jeasy.rules.api.Facts;
import org.jeasy.rules.api.Rules;
import org.jeasy.rules.api.RulesEngine;
import org.jeasy.rules.core.DefaultRulesEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.ivir.mpif.common.Utilities.useDefaultIfNull;

@Service
public class ScenarioEngineServiceImpl implements ScenarioEngineService {
    Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private VitalSignsSimDataService vitalSignsSimDataService;

    @Autowired
    private MpifConfigService mpifConfigService;

    @Autowired
    PatientCaseService patientCaseService;

    private boolean useFederationTime = false;
    private long lastElapsed = 0;
    private HashMap<PatientId, ScenarioData> patientToScenarioDataMap = new HashMap<>();
    RulesEngine rulesEngine = new DefaultRulesEngine();

    @Override
    public void registerPatient(PatientId patientId){
        if(patientToScenarioDataMap.containsKey(patientId)){
            throw new IllegalArgumentException("Scenario Engine already exists for this patient");
        }
        //right, we are hard-coding for the Manual Rule set, this should be changed in the future to support
        //more rule sets
        ScenarioData scenarioData = new ScenarioData(patientId, ManualRules.createRules());
        scenarioData.getFacts().put("diastolic_pressure_control", ManualControl.instantaneousUpdate(80));
        scenarioData.getFacts().put("etco2_control", ManualControl.instantaneousUpdate(90f));
        scenarioData.getFacts().put("o2_saturation_control", ManualControl.instantaneousUpdate(99f));
        scenarioData.getFacts().put("heart_rate_control", ManualControl.instantaneousUpdate(60));
        scenarioData.getFacts().put("respiratory_rate_control", ManualControl.instantaneousUpdate(20f));
        scenarioData.getFacts().put("systolic_pressure_control", ManualControl.instantaneousUpdate(100));
        scenarioData.getFacts().put("temperature_control", ManualControl.instantaneousUpdate(98f));
        patientToScenarioDataMap.put(patientId, scenarioData);
        logger.info("Patient {} registered in Scenario Engine", patientId);
    }

    @Override
    public void unregisterPatient(PatientId patientId){
        patientToScenarioDataMap.remove(patientId);
        logger.info("Patient {} unregistered in Scenario Engine", patientId);
    }

    @Override
    public void startScenario(PatientId patientId) {
        ScenarioData scenarioData = patientToScenarioDataMap.get(patientId);
        if(scenarioData != null){
            patientCaseService.getPatientAssignment(patientId)
                .ifPresent((patientCase)->
                        updateDefaultScenarioFromPatientCase(patientId, patientCase, scenarioData));
            scenarioData.setRunning(true);
            logger.debug("Scenario for patient {} started", patientId);
        }
    }

    private void updateDefaultScenarioFromPatientCase(PatientId patientId, PatientCase patientCase, ScenarioData scenarioData){
        PCVitals pcVitals = patientCase.getVitals();
        if(pcVitals != null){
            useDefaultIfNull(pcVitals.getDiastolicBp(),0,
                    (value)->scenarioData.getFacts().put("diastolic_pressure_control", (ManualControl.instantaneousUpdate(value))));
            useDefaultIfNull(pcVitals.getEtco2(),0f,
                    (value)->scenarioData.getFacts().put("etco2_control", ManualControl.instantaneousUpdate(value)));
            useDefaultIfNull(pcVitals.getSpO2(),0f,
                    (value)->scenarioData.getFacts().put("o2_saturation_control", ManualControl.instantaneousUpdate(value)));
            useDefaultIfNull(pcVitals.getHeartRate(),0,
                    (value)->scenarioData.getFacts().put("heart_rate_control", ManualControl.instantaneousUpdate(value)));
            useDefaultIfNull(pcVitals.getRespiratoryRate(),0f,
                    (value)->scenarioData.getFacts().put("respiratory_rate_control", ManualControl.instantaneousUpdate(value)));
            useDefaultIfNull(pcVitals.getSystolicBp(),0,
                    (value)->scenarioData.getFacts().put("systolic_pressure_control", ManualControl.instantaneousUpdate(value)));
            useDefaultIfNull(pcVitals.getTemp(),0f,
                    (value)->scenarioData.getFacts().put("temperature_control", ManualControl.instantaneousUpdate(value)));
            patientToScenarioDataMap.put(patientId, scenarioData);
            logger.info("Scenario engine is using patient case '{}' for patient {}", patientCase.getName(), patientId);
        }
    }

    @Override
    public void resumeScenario(PatientId patientId) {
        ScenarioData scenarioData = patientToScenarioDataMap.get(patientId);
        if(scenarioData != null){
            scenarioData.setRunning(true);
        }
    }

    @Override
    public void stopScenario(PatientId patientId) {
        ScenarioData scenarioData = patientToScenarioDataMap.get(patientId);
        if(scenarioData != null){
            scenarioData.setRunning(false);
        }
    }

    @Override
    public boolean usingFederationTime(){
        return this.useFederationTime;
    }

    @Override
    public boolean hasPatient(PatientId patientId) {
        return this.patientToScenarioDataMap.containsKey(patientId);
    }

    @Override
    public List<PatientId> listRegisteredPatients() {
        return this.patientToScenarioDataMap.keySet().stream().toList();
    }

    @Override
    public List<String> getDataDump(PatientId patientId) {
        ArrayList<String> dataList = new ArrayList<>();
        if(this.patientToScenarioDataMap.containsKey(patientId)){
            this.patientToScenarioDataMap.get(patientId).getFacts().forEach((facts)->{
                dataList.add(facts.getName() + ":" + facts.getValue().toString());
            });
            return dataList;
        }
        return List.of();
    }

    @Override
    public <T> void updatePatientData(PatientId patientId, String factId, T value) {
        logger.debug("Update patient {}, {}, {}", patientId, factId, value);
        this.patientToScenarioDataMap.get(patientId).getFacts().put(factId, value);
    }

    @Override
    public void engineTick(Long elapsedTime) {
        if(lastElapsed == 0){
            lastElapsed = elapsedTime;
        }
        patientToScenarioDataMap.values()
                .stream()
                .filter((scenData)->{return scenData.isRunning();})
                .forEach((scenData)->{
                    tickEngine(scenData.getRules(), scenData.getFacts(),elapsedTime - lastElapsed);
                    updateVitals(scenData.getPatientId(),scenData.getFacts());
                });
        lastElapsed = elapsedTime;
    }

    private void tickEngine(Rules rules, Facts facts, long tick){
        facts.put(ReservedFacts.CLOCK_CHANGE_LONG.getFactId(), tick);
        rulesEngine.fire(rules, facts);
    }

    private void updateVitals(PatientId patientId, Facts facts) {
        VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(patientId.getIdAsString());
        if (vitalSigns == null) {
            vitalSigns = new VitalSigns().setId(patientId.getIdAsString()).setLocal(true).setOwnershipState(OwnershipState.CREATED);
        }
        Integer diastolicPressure = facts.get(ReservedFacts.DIASTOLIC_PRESSURE_INT.getFactId());
        if (diastolicPressure != null) {
            vitalSigns.setDiastolicBloodPressure(diastolicPressure);
        }
        Float etco2 = facts.get(ReservedFacts.ETCO2_FLT.getFactId());
        if (etco2 != null) {
            vitalSigns.setRespirationETco2(etco2);
        }
        Integer heartRate = facts.get(ReservedFacts.HEART_RATE_INT.getFactId());
        if (heartRate != null) {
            vitalSigns.setHeartRate(heartRate);
        }
        Float o2Sat = facts.get(ReservedFacts.O2_SATURATION_FLT.getFactId());
        if (o2Sat != null) {
            vitalSigns.setOxygenSaturation(o2Sat);
        }
        Float respRate = facts.get(ReservedFacts.RESPIRATORY_RATE_FLT.getFactId());
        if (respRate != null) {
            vitalSigns.setRespirationRate(respRate);
        }
        Integer systolicPressure = facts.get(ReservedFacts.SYSTOLIC_PRESSURE_INT.getFactId());
        if (systolicPressure != null) {
            vitalSigns.setSystolicBloodPressure(systolicPressure);
        }
        Float temp = facts.get(ReservedFacts.TEMPERATURE_FLT.getFactId());
        if (temp != null) {
            vitalSigns.setTemperatureFahrenheit(temp);
        }
        vitalSignsSimDataService.put(vitalSigns);
    }

    private <T extends Comparable> void updateIfDiff(T newValue, Facts facts, ReservedFacts fact, VitalSigns vitalSigns, VitalSigns.Attributes attribute){
        if(newValue == null){
            return;
        }
        Comparable<?> oldValue = vitalSigns.getByAttribute(attribute);
        if(oldValue == null){
            vitalSigns.setByAttribute(attribute, newValue);
            return;
        }
        if(!oldValue.equals(newValue)){
            vitalSigns.setByAttribute(attribute, newValue);
        }
    }
}
