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

package com.ivir.mpif.shell;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import com.ivir.mpif.patient.PatientSource;
import com.ivir.mpif.sceneng.ScenarioEngineService;
import com.ivir.mpif.sceneng.rules.model.ManualControl;
import org.jline.reader.LineReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

import java.util.List;

@ShellComponent
public class ScenarioEngineCommands {
    @Autowired
    private ScenarioEngineService scenarioEngineService;

    @Autowired
    private PatientService patientService;

    @Autowired
    @Lazy
    private LineReader lineReader;


    @ShellMethod(key = "engineDataDump", value = "List the data values for the specified patient")
    public void scenarioEngineDataDump(
            @ShellOption(value="patientId", help = "patient ID")
            String patientId
    ){
        List<String> dataDump = scenarioEngineService.getDataDump(new PatientId(patientId));
        if(dataDump.isEmpty()){
            System.out.println("<empty list");
        }else{
            dataDump.forEach(System.out::println);
        }
    }

    @ShellMethod(key = "enginePatients", value = "List the data values for the specified patient")
    public void scenarioEngineDataDump(){
        List<PatientId> patients = scenarioEngineService.listRegisteredPatients();

        if(patients.isEmpty()){
            System.out.println("Empty list");
        }
        patients.stream().forEach(System.out::println);
    }

    @ShellMethod(key="setInstant", value="Inject manual change")
    public void manualChange(@ShellOption(value="patient") String patientId){
        System.out.println(patientId);

        CmdUtils.promptForNumber(lineReader, "Vitals",
                "Heart Rate", "Respiratory Rate", "O2 Saturation", "EtCO2", "Diastolic", "Systolic", "Temp"
        ).ifPresent((selection)->{
            switch (selection){
                case 0 -> CmdUtils.promptToEnterInt(lineReader,"BPM").ifPresent((newValue)->
                    scenarioEngineService.updatePatientData(new PatientId(patientId), "heart_rate_control", ManualControl.instantaneousUpdate(newValue)));
                case 1 -> CmdUtils.promptToEnterFloat(lineReader,"BPM").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "respiratory_rate_control", ManualControl.instantaneousUpdate(newValue)));
                case 2 -> CmdUtils.promptToEnterFloat(lineReader,"%").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "o2_saturation_control", ManualControl.instantaneousUpdate(newValue)));
                case 3 -> CmdUtils.promptToEnterFloat(lineReader,"%").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "etco2_control", ManualControl.instantaneousUpdate(newValue)));
                case 4 -> CmdUtils.promptToEnterInt(lineReader,"mmHg").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "diastolic_pressure_control", ManualControl.instantaneousUpdate(newValue)));
                case 5 -> CmdUtils.promptToEnterInt(lineReader,"mmHg").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "systolic_pressure_control", ManualControl.instantaneousUpdate(newValue)));
                case 6 -> CmdUtils.promptToEnterFloat(lineReader,"%").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "temperature_control", ManualControl.instantaneousUpdate(newValue)));
            }
            System.out.println("Sent");
        });
    }

    @ShellMethod(key="setInterval", value="Inject manual change")
    public void manualIntervalChange(@ShellOption(value="patient") String patientId){
        System.out.println(patientId);

        CmdUtils.promptForNumber(lineReader, "Vitals",
                "Heart Rate", "Respiratory Rate", "O2 Saturation", "EtCO2", "Diastolic", "Systolic", "Temp"
        ).ifPresent((selection)->{
            switch (selection){
                case 0 -> CmdUtils.promptToEnterFloat(lineReader,"beats per minute").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "heart_rate_control",
                                ManualControl.gradualUpdate(newValue,Integer.valueOf(0), Integer.valueOf(600))));
                case 1 -> CmdUtils.promptToEnterFloat(lineReader,"breaths per minute").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "respiratory_rate_control",
                                ManualControl.gradualUpdate(newValue,Float.valueOf(0), Float.valueOf(900))));
                case 2 -> CmdUtils.promptToEnterFloat(lineReader,"%").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "o2_saturation_control",
                                ManualControl.gradualUpdate(newValue,Float.valueOf(0), Float.valueOf(100))));
                case 3 -> CmdUtils.promptToEnterFloat(lineReader,"%").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "etco2_control",
                                ManualControl.gradualUpdate(newValue,Float.valueOf(0), Float.valueOf(100))));
                case 4 -> CmdUtils.promptToEnterFloat(lineReader,"mmHg").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "diastolic_pressure_control",
                                ManualControl.gradualUpdate(newValue,Integer.valueOf(0), Integer.valueOf(380))));
                case 5 -> CmdUtils.promptToEnterFloat(lineReader,"mmHg").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "systolic_pressure_control",
                                ManualControl.gradualUpdate(newValue,Integer.valueOf(0), Integer.valueOf(380))));
                case 6 -> CmdUtils.promptToEnterFloat(lineReader,"Fahrenheit").ifPresent((newValue)->
                        scenarioEngineService.updatePatientData(new PatientId(patientId), "temperature_control",
                                ManualControl.gradualUpdate(newValue,Float.valueOf(0), Float.valueOf(120))));
            }
            System.out.println("Sent");
        });
    }

    @ShellMethod(key = "changeHeartRateInterval", value = "Change heart rate interval")
    public void changeHeartRateInterval(
            @ShellOption(value="patient")
            String patientId,
            @ShellOption(value="newRate")
            Float newRate
    ){
        scenarioEngineService.updatePatientData(new PatientId(patientId), "heart_rate_control", ManualControl.gradualUpdate(newRate, 0, 200));
    }

    @ShellMethod(key = "syncScenarioEnginePatients", value = "Register any missing internal patients")
    public void syncScenarioEngineWithPatients(){
        List<Patient> patients = patientService.getPatients();
        System.out.println("Start number of registered patients: " + scenarioEngineService.listRegisteredPatients().size());
        System.out.println("Number of patients: " + patients.size());
        patients.stream()
                .filter((curPatient)->curPatient.getPhysiologySource() == PatientSource.INTERNAL)
                .filter((curPatient)->!scenarioEngineService.hasPatient(curPatient.getId()))
                .forEach((curPatient)->scenarioEngineService.registerPatient(curPatient.getId()));
        System.out.println("End number of registered patients: " + scenarioEngineService.listRegisteredPatients().size());
    }
}
