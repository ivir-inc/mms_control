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

package com.ivir.mpif.treatment.impl;

import com.ivir.mpif.common.GlobalVariables;
import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import com.ivir.mpif.simdata.*;
import com.ivir.mpif.treatment.TreatmentService;
import com.ivir.mpif.treatment.data.*;
import com.ivir.mpif.treatment.impl.file.FileManager;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;
import java.util.List;

@Service
public class TreatmentServiceImpl implements TreatmentService {
    private Logger logger = LoggerFactory.getLogger(this.getClass());
    private ScenarioStorage scenarioStorage;
    private FileManager fileManager;
    private TreatmentLayout treatmentLayout;
    private HashMap<PatientId,Integer> patientToActiveScenarioMap;
    private int treatmentIdCounter = 0;

    @Autowired
    private MpifConfigService mpifConfigService;
    @Autowired
    private TreatmentSimDataService treatmentSimDataService;

    @PostConstruct
    public void initializeService(){
        fileManager = new FileManager();
        scenarioStorage = new ScenarioStorage();
        patientToActiveScenarioMap = new HashMap<>();

        mpifConfigService.getProperty(MpifConfigKey.SCENARIO_FOLDER).ifPresent((folderName)->{
            logger.info("Scenario folder specified: {}.  Loading treatment scenarios", folderName);
            treatmentLayout = fileManager.loadLayoutFile();

            ArrayList<String> nameList = fileManager.listScenarios();
            for(String fileName : nameList){
                Scenario scenario = fileManager.loadScenario(fileName);
                scenarioStorage.putScenario(scenario);
            }
            logger.info("Loaded {} treatment scenarios.",scenarioStorage.size());
        });
    }

    /**
     * gets the current layout for the Treatment UI
     */
    @Override
    public TreatmentLayout getTreatmentLayout(){
        if(treatmentLayout == null){
            throw new RuntimeException("TreatmentLayout not initialized");
        }
        return treatmentLayout;
    }

    @Override
    public void updateTreatmentLayout(TreatmentLayout treatmentLayout) {
        if(treatmentLayout == null){
            throw new IllegalArgumentException("TreatmentLayout is required");
        }
        fileManager.saveLayoutFile(treatmentLayout);
        this.treatmentLayout = treatmentLayout;
    }

    @Override
    public TreatmentLayout resetTreatmentLayout() {
        this.fileManager.resetLayout();
        this.treatmentLayout = this.fileManager.loadLayoutFile();
        return this.treatmentLayout;
    }

    private String newTreatmentId(String patientId){
        return GlobalVariables.getFederateName() + "-" + patientId + "-" + treatmentIdCounter ++;
    }

    @Override
    public void addTreatment(Treatment treatment) {
        if(treatment != null){
            treatmentSimDataService.add(treatment);
        }
    }

    @Override
    public void addMedicationTreatment(PatientId patientId, String injuryId, Medication medication,
                                       MedicationAdministrationRoute route, Float dosageValue, Integer dosageInterval) {
        Treatment simDataTreatment = new Treatment();
        simDataTreatment.setClassType(TreatmentClassType.MEDICATION_TREATMENT);
        simDataTreatment.setPatientId(patientId);
        simDataTreatment.setTreatmentId(newTreatmentId(patientId.getIdAsString()));
        simDataTreatment.setTreatmentActive(true);
        simDataTreatment.setAdministrationRoute(route);
        simDataTreatment.setMedication(medication);
        simDataTreatment.setDosageValue(dosageValue);
        simDataTreatment.setDosageTimePeriod(dosageInterval);
        simDataTreatment.setLocal(true);
        treatmentSimDataService.add(simDataTreatment);
        logger.debug("New treatment added: {}", simDataTreatment);
    }

    @Override
    public void addPhysicalTreatment(PatientId patientId, PhysicalTreatmentType treatment, String injuryId,
                                     TreatmentDevice deviceUsed, BodyLocation treatmentLocation) {
        Treatment simDataTreatment = new Treatment();
        simDataTreatment.setClassType(TreatmentClassType.PHYSICAL_TREATMENT);
        simDataTreatment.setPatientId(patientId);
        simDataTreatment.setTreatmentId(newTreatmentId(patientId.getIdAsString()));
        simDataTreatment.setTreatmentActive(true);
        simDataTreatment.setTreatment(treatment);
        simDataTreatment.setDeviceUsed(deviceUsed);
        simDataTreatment.setTreatmentLocation(treatmentLocation);
        simDataTreatment.setLocal(true);
        treatmentSimDataService.add(simDataTreatment);
        logger.debug("New treatment added: {}", simDataTreatment);
    }

    @Override
    public Treatment getTreatmentById(long id) {
        return treatmentSimDataService.getTreatment(id);
    }

    @Override
    public Treatment getTreatmentByInstanceName(String instanceName) {
        return treatmentSimDataService.getFirstTreatmentByInstanceName(instanceName);
    }

    @Override
    public void addTreatmentListener(ConcurrentDataStorageListener<Treatment> treatmentDataStorageListener) {
        treatmentSimDataService.addDataStorageListener(treatmentDataStorageListener);
    }

    /**
     * sets the layout for the Treatment UI
     * @param layout
     */
    public void setTreatmentLayout(TreatmentLayout layout){
        this.treatmentLayout = layout;
    }

    /**
     * gets the active scenario.
     * @return id of active scenario or null if not scenario is active
     */
    @Override
    public Optional<Integer> getActiveScenarioId(PatientId patientId){
        return Optional.ofNullable(patientToActiveScenarioMap.get(patientId));
    }

    @Override
    public Optional<Scenario> getActiveScenarioByPatientId(PatientId patientId) {
        Optional<Integer> activeScenarioId = getActiveScenarioId(patientId);
        if(activeScenarioId.isEmpty()){
            return Optional.empty();
        }
        return Optional.ofNullable(scenarioStorage.getScenario(activeScenarioId.get()));
    }

    @Override
    public boolean setActiveScenario(PatientId patientId, Integer scenId){
        if(scenId == null){
            this.patientToActiveScenarioMap.remove(patientId);
            logger.info("clearing active scenario for patient {}", patientId);
            return true;
        }else{
            Scenario scenario = scenarioStorage.getScenario(scenId);
            if(scenario != null){
                this.patientToActiveScenarioMap.put(patientId, scenId);
                logger.info("setting active scenario to id {} for patient {}", scenId, patientId);
                return true;
            }
            return false;
        }
    }

    public boolean setActiveScenarioByName(PatientId patientId, String scenarioName){
        if(scenarioName == null){
            return setActiveScenario(patientId, null);
        }
        Optional<Integer> idOptional = scenarioStorage.getScenarioId(scenarioName);
        if(idOptional.isEmpty()){
            return false;
        }
        return setActiveScenario(patientId, idOptional.get());
    }

    @Override
    public List<Scenario> getAllScenarios(){
        return this.scenarioStorage.getAllScenarios();
    }



}
