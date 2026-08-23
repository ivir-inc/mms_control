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

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.EvacuationCategory;
import com.ivir.mpif.simdata.Gender;
import com.ivir.mpif.simdata.TcccSimDataService;
import com.ivir.mpif.simdata.Tccc;
import devstudio.generatedcode.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.Set;

@Component
public class TcccAdapter implements MmsFederateInitializationListener, HlaTacticalCombatCasualtyCareCardListener, HlaTacticalCombatCasualtyCareCardManagerListener {
    private static final Logger logger = LoggerFactory.getLogger(TcccAdapter.class);

    @Autowired
    private TcccSimDataService tcccSimDataService;

    public TcccAdapter(){
    }

    //*********************************************************************************************
    // MmsFederateInitializationListener
    //*********************************************************************************************
    @Override
    public void initializing(MmsFederate mmsFederate) {
        HlaTacticalCombatCasualtyCareCardManager hlaManager = mmsFederate.getHlaWorld().getHlaTacticalCombatCasualtyCareCardManager();
        hlaManager.addHlaTacticalCombatCasualtyCareCardDefaultInstanceListener(this);
        hlaManager.addHlaTacticalCombatCasualtyCareCardManagerListener(this);
    }

    //*********************************************************************************************
    // HlaTacticalCombatCasualtyCareCardListener
    //*********************************************************************************************
    @Override
    public void attributesUpdated(HlaTacticalCombatCasualtyCareCard hlaTccc, Set<HlaTacticalCombatCasualtyCareCardAttributes.Attribute> attributes, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(hlaTccc.isLocal()){
            logger.debug("skipping for local TCCC entity");
        }

        Optional<Tccc> optTccc = tcccSimDataService.getByInstanceName(hlaTccc.getHlaInstanceName());
        Tccc tccc = optTccc.orElse(new Tccc()
                .setInstanceName(hlaTccc.getHlaInstanceName())
                .setLocal(false));

        for(HlaTacticalCombatCasualtyCareCardAttributes.Attribute attribute : attributes) {
            switch (attribute) {
                case ALLERGIES -> tccc.setAllergies(hlaTccc.getAllergies());
                case BATTLE_ROSTER_NUMBER -> tccc.setBattleRosterNumber(hlaTccc.getBattleRosterNumber());
                case DATE -> tccc.setDate(hlaTccc.getDate());
                case EVACUATION_LEVEL_REQUEST ->
                        tccc.setEvacuationLevelRequest(EvacuationCategory.valueOf(hlaTccc.getEvacuationLevelRequest().toString()));
                case FIRST_NAME -> tccc.setFirstName(hlaTccc.getFirstName());
                case GENDER -> tccc.setGender(Gender.valueOf(hlaTccc.getGender().toString()));
                case INJURY_ANNOTATION ->
                        tccc.setInjuryAnnotation(TcccHlaMapper.fromHla(hlaTccc.getInjuryAnnotation()));
                case LAST_NAME -> tccc.setLastName(hlaTccc.getLastName());
                case MECHANISM_OF_INJURY ->
                        tccc.setMechanismOfInjury(TcccHlaMapper.fromHla(hlaTccc.getMechanismOfInjury()));
                case PATIENT_ID -> tccc.setPatientId(hlaTccc.getPatientId());
                case RESPONDER -> tccc.setResponder(TcccHlaMapper.fromHla(hlaTccc.getResponder()));
                case SERVICE -> tccc.setService(hlaTccc.getService());
                case SIGNS_SYMPTOMS -> tccc.setSignsSymptoms(TcccHlaMapper.fromHla(hlaTccc.getSignsSymptoms()));
                case SOCIAL_SECURITY_ACCOUNT_NUMBER ->
                        tccc.setSocialSecurityAccountNumber(hlaTccc.getSocialSecurityAccountNumber());
                case TIME -> tccc.setTime(hlaTccc.getTime());
                case TREATMENT_AIRWAY -> tccc.setTreatmentAirway(TcccHlaMapper.fromHla(hlaTccc.getTreatmentAirway()));
                case TREATMENT_BLOOD_PRODUCTS ->
                        tccc.setTreatmentBloodProducts(TcccHlaMapper.fromHla(hlaTccc.getTreatmentBloodProducts()));
                case TREATMENT_BREATHING ->
                        tccc.setTreatmentBreathing(TcccHlaMapper.fromHla(hlaTccc.getTreatmentBreathing()));
                case TREATMENT_CIRCULATORY_DRESSING ->
                        tccc.setTreatmentCirculatoryDressing(TcccHlaMapper.fromHla(hlaTccc.getTreatmentCirculatoryDressing()));
                case TREATMENT_FLUIDS -> tccc.setTreatmentFluids(TcccHlaMapper.fromHla(hlaTccc.getTreatmentFluids()));
                case TREATMENT_CIRCULATORY_TOURNIQUET ->
                        tccc.setTreatmentCirculatoryTourniquet(TcccHlaMapper.fromHla(hlaTccc.getTreatmentCirculatoryTourniquet()));
                case TREATMENT_MEDICATIONS_ANALGESIC ->
                        tccc.setTreatmentMedicationsAnalgesic(TcccHlaMapper.fromHla(hlaTccc.getTreatmentMedicationsAnalgesic()));
                case TREATMENT_MEDICATIONS_ANTIBIOTIC ->
                        tccc.setTreatmentMedicationsAntibiotic(TcccHlaMapper.fromHla(hlaTccc.getTreatmentMedicationsAntibiotic()));
                case TREATMENT_MEDICATIONS_OTHER ->
                        tccc.setTreatmentMedicationsOther(TcccHlaMapper.fromHla(hlaTccc.getTreatmentMedicationsOther()));
                case TREATMENT_NOTES -> tccc.setTreatmentNotes(hlaTccc.getTreatmentNotes());
                case TREATMENT_OTHER -> tccc.setTreatmentOther(TcccHlaMapper.fromHla(hlaTccc.getTreatmentOther()));
                case UNIT -> tccc.setUnit(hlaTccc.getUnit());
            }
        }
        tcccSimDataService.put(tccc);
    }

    //*********************************************************************************************
    // HlaTacticalCombatCasualtyCareCardManagerListener
    //*********************************************************************************************

    @Override
    public void hlaTacticalCombatCasualtyCareCardDiscovered(HlaTacticalCombatCasualtyCareCard hlaTacticalCombatCasualtyCareCard, HlaTimeStamp hlaTimeStamp) {
        //ignore
    }

    @Override
    public void hlaTacticalCombatCasualtyCareCardInitialized(HlaTacticalCombatCasualtyCareCard hlaTacticalCombatCasualtyCareCard, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        //ignore
    }

    @Override
    public void hlaTacticalCombatCasualtyCareCardInInterest(HlaTacticalCombatCasualtyCareCard hlaTacticalCombatCasualtyCareCard, HlaTimeStamp hlaTimeStamp) {
        //ignore
    }

    @Override
    public void hlaTacticalCombatCasualtyCareCardOutOfInterest(HlaTacticalCombatCasualtyCareCard hlaTacticalCombatCasualtyCareCard, HlaTimeStamp hlaTimeStamp) {
        //ignore
    }

    @Override
    public void hlaTacticalCombatCasualtyCareCardDeleted(HlaTacticalCombatCasualtyCareCard hlaTccc, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        tcccSimDataService.getByInstanceName(hlaTccc.getHlaInstanceName()).ifPresent(tccc -> {
            tcccSimDataService.delete(tccc.getId());
        });
    }
}
