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

import com.ivir.mpif.simdata.PatientControl;
import com.ivir.mpif.simdata.PatientControlCommandEnum;
import com.ivir.mpif.simdata.PatientControlSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

@ShellComponent
public class PatientControlCommands {
    @Autowired
    PatientControlSimDataService patientControlSimDataService;

    @ShellMethod(key = "listPatientControl", value = "interact with patient controls")
    public void patientControl(){
        patientControlSimDataService.getAll().forEach(System.out::println);
    }

    @ShellMethod(key = "startPatient", value = "send start patient control")
    public void startPatient(
            @ShellOption(value="patient", defaultValue = "nopatient", help = "patientId of patient to control.  Not needed for list command")
            String patientId
    ){
            updateControl(PatientControlCommandEnum.START, patientId);
    }


    @ShellMethod(key = "stopPatient", value = "send stop patient control")
    public void stopPatient(
            @ShellOption(value="patient", defaultValue = "nopatient", help = "patientId of patient to control.  Not needed for list command")
            String patientId
    ){
        updateControl(PatientControlCommandEnum.STOP, patientId);
    }

    @ShellMethod(key = "pausePatient", value = "send pause patient control")
    public void pausePatient(
            @ShellOption(value="patient", defaultValue = "nopatient", help = "patientId of patient to control.  Not needed for list command")
            String patientId
    ){
        updateControl(PatientControlCommandEnum.PAUSE, patientId);
    }

    @ShellMethod(key = "resumePatient", value = "send resume patient control")
    public void resumePatient(
            @ShellOption(value="patient", defaultValue = "nopatient", help = "patientId of patient to control.  Not needed for list command")
            String patientId
    ){
        updateControl(PatientControlCommandEnum.RESUME, patientId);
    }

    private void updateControl(PatientControlCommandEnum command, String patientId){
        if(patientId == "nopatient"){
            System.out.println("You must include patientId for this command");
        }else{
            PatientControl patientControl = new PatientControl();
            patientControl.setPatientId(patientId);
            patientControl.setCommand(command);
            patientControl.setLocal(true);
            patientControlSimDataService.add(patientControl);
            System.out.println("Control added");
        }
    }

}
