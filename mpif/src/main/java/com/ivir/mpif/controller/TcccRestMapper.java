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

package com.ivir.mpif.controller;

import com.ivir.mpif.common.Utilities;
import com.ivir.mpif.controller.model.RestInjuryAnnotation;
import com.ivir.mpif.controller.model.RestInjuryLocation;
import com.ivir.mpif.controller.model.RestTccc;
import com.ivir.mpif.simdata.ComparableList;
import com.ivir.mpif.simdata.InjuryAnnotation;
import com.ivir.mpif.simdata.InjuryLocation;
import com.ivir.mpif.simdata.Tccc;

import java.util.List;

import static com.ivir.mpif.common.Utilities.doIfNotNull;


public class TcccRestMapper {
    public static RestTccc toRest(Tccc tccc){
        RestTccc restTccc = new RestTccc();
        restTccc.setAllergies(tccc.getAllergies());
        restTccc.setBattleRosterNumber(tccc.getBattleRosterNumber());
        restTccc.setDate(tccc.getDate());
        restTccc.setEvacuationLevelRequest(tccc.getEvacuationLevelRequest());
        restTccc.setFirstName(tccc.getFirstName());
        restTccc.setGender(tccc.getGender());
        restTccc.setInjuryAnnotation(toRest(tccc.getInjuryAnnotation()));
        restTccc.setInstanceName(tccc.getInstanceName());
        restTccc.setLastName(tccc.getLastName());
        restTccc.setLocal(tccc.isLocal());
        restTccc.setMechanismOfInjury(tccc.getMechanismOfInjury());
        restTccc.setPatientId(tccc.getPatientId());
        restTccc.setResponder(tccc.getResponder());
        restTccc.setService(tccc.getService());
        doIfNotNull(tccc.getSignsSymptoms(), (ss) ->restTccc.setSignsSymptoms(ss.getList()));
        restTccc.setSocialSecurityAccountNumber(tccc.getSocialSecurityAccountNumber());
        restTccc.setTime(tccc.getTime());
        restTccc.setTreatmentAirway(tccc.getTreatmentAirway());
        doIfNotNull(tccc.getTreatmentBloodProducts(),(comp)->restTccc.setTreatmentBloodProducts(comp.getList()));
        restTccc.setTreatmentBreathing(tccc.getTreatmentBreathing());
        restTccc.setTreatmentCirculatoryDressing(tccc.getTreatmentCirculatoryDressing());
        restTccc.setTreatmentCirculatoryTourniquet(tccc.getTreatmentCirculatoryTourniquet());
        doIfNotNull(tccc.getTreatmentFluids(),(comp)->restTccc.setTreatmentFluids(comp.getList()));
        doIfNotNull(tccc.getTreatmentMedicationsAnalgesic(),(comp)->restTccc.setTreatmentMedicationsAnalgesic(comp.getList()));
        doIfNotNull(tccc.getTreatmentMedicationsAntibiotic(),(comp)->restTccc.setTreatmentMedicationsAntibiotic(comp.getList()));
        restTccc.setTreatmentNotes(tccc.getTreatmentNotes());
        restTccc.setTreatmentOther(tccc.getTreatmentOther());
        restTccc.setUnit(tccc.getUnit());
        return restTccc;
    }

    private static RestInjuryAnnotation toRest(InjuryAnnotation record){
        if (record == null) return null;
        return new RestInjuryAnnotation()
                .setAnnotationList(toRest(record.getAnnotationList()))
                .setLeftArmTourniquet(record.getLeftArmTourniquet())
                .setLeftLegTourniquet(record.getLeftLegTourniquet())
                .setRightArmTourniquet(record.getRightArmTourniquet())
                .setRightLegTourniquet(record.getRightLegTourniquet());
    }

    private static List<RestInjuryLocation> toRest(ComparableList<InjuryLocation> list){
        if(list == null) return List.of();
        return list.getList().stream().map(TcccRestMapper::toRest).toList();
    }

    private static RestInjuryLocation toRest(InjuryLocation location){
        if(location == null) return null;
        return new RestInjuryLocation()
                .setInjuryType(location.getInjuryType())
                .setInjuryLocation(location.getInjuryLocation().getList());
    }
}
