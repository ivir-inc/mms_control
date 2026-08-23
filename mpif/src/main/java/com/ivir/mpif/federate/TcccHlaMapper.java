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

import com.ivir.mpif.simdata.*;
import devstudio.generatedcode.datatypes.*;

import java.util.Arrays;
import java.util.stream.Collectors;

public class TcccHlaMapper {
    public static InjuryAnnotation fromHla(InjuryAnnotationRecord record){
        return new InjuryAnnotation()
                .setAnnotationList(fromHla(record.getAnnotationList()))
                .setLeftArmTourniquet(fromHla(record.getLeftArmTourniquet()))
                .setRightArmTourniquet(fromHla(record.getRightArmTourniquet()))
                .setLeftLegTourniquet(fromHla(record.getLeftLegTourniquet()))
                .setRightLegTourniquet(fromHla(record.getRightLegTourniquet()));
    }

    public static MechanismOfInjuryComms fromHla(MechanismOfInjuryCommsRecord record){
        return new MechanismOfInjuryComms()
                .setArtillery(record.getArtillery())
                .setBlunt(record.getBlunt())
                .setBurn(record.getBurn())
                .setFall(record.getFall())
                .setGrenade(record.getGrenade())
                .setGunShotWound(record.getGunShotWound())
                .setImprovisedExplosiveDevice(record.getImprovisedExplosiveDevice())
                .setLandMine(record.getLandMine())
                .setMotorVehicleCollision(record.getMotorVehicleCollision())
                .setOther(record.getOther())
                .setOtherCause(record.getOtherCause())
                .setRocketPropelledGrenade(record.getRocketPropelledGrenade());
    }

    public static Responder fromHla(ResponderRecord record){
        return new Responder()
                .setFirstName(record.getFirstName())
                .setLastName(record.getLastName())
                .setSocialSecurityAccountNumber(record.getSocialSecurityAccountNumber())
                .setTrainingLevel(record.getTrainingLevel());
    }

    public static ComparableList<SignsSymptoms> fromHla(SignsSymptomsRecord[] records){
        if(records == null) return new ComparableList<>();
        return new ComparableList<>(Arrays.stream(records).map(TcccHlaMapper::fromHla).collect(Collectors.toList()));
    }

    public static TreatmentAirway fromHla(TreatmentAirwayRecord record){
        return new TreatmentAirway()
                .setCricothyroidotomy(record.getCricothyroidotomy())
                .setEndotrachealTube(record.getEndotrachealTube())
                .setIntact(record.getIntact())
                .setNasopharyngealAirway(record.getNasopharyngealAirway())
                .setSupraglotticAirway(record.getSupraglotticAirway())
                .setType(record.getType());
    }

    public static ComparableList<TreatmentFluid> fromHla(TreatmentFluidRecord[] records) {
        if (records == null) return new ComparableList<>();
        return new ComparableList<>(Arrays.stream(records).map(TcccHlaMapper::fromHla).collect(Collectors.toList()));
    }

    public static TreatmentBreathing fromHla(TreatmentBreathingRecord record){
        return new TreatmentBreathing()
                .setChestSeal(record.getChestSeal())
                .setChestTube(record.getChestTube())
                .setNeedleDecompression(record.getNeedleDecompression())
                .setType(record.getType())
                .setOxygenAdministered(record.getOxygenAdministered());
    }

    public static TreatmentCirculatoryDressing fromHla(TreatmentCirculatoryDressingRecord record){
        return new TreatmentCirculatoryDressing()
                .setOther(record.getOther())
                .setHemostatic(record.getHemostatic())
                .setOtherType(record.getOtherType())
                .setPressure(record.getPressure());
    }

    public static TreatmentCirculatoryTourniquet fromHla(TreatmentCirculatoryTourniquetRecord record){
        return new TreatmentCirculatoryTourniquet()
                .setExtremity(record.getExtremity())
                .setExtremityType(record.getExtremityType())
                .setJunctional(record.getJunctional())
                .setJunctionalType(record.getJunctionalType())
                .setTruncal(record.getTruncal())
                .setTruncalType(record.getTruncalType());
    }

    public static ComparableList<TreatmentMedications> fromHla(TreatmentMedicationsRecord[] records){
        if(records == null) return new ComparableList<>();
        return new ComparableList<>(Arrays.stream(records).map(TcccHlaMapper::fromHla).collect(Collectors.toList()));
    }

    public static TreatmentOther fromHla(TreatmentOtherRecord record){
        return new TreatmentOther()
                .setCombatPill(record.getCombatPill())
                .setType(record.getType())
                .setEyeShieldLeft(record.getEyeShieldLeft())
                .setEyeShieldRight(record.getEyeShieldRight())
                .setSplint(record.getSplint())
                .setHypothermiaBlanket(record.getHypothermiaBlanket());
    }

    private static TreatmentMedications fromHla(TreatmentMedicationsRecord record){
        return new TreatmentMedications()
                .setDosage(record.getDosage())
                .setName(record.getName())
                .setRoute(record.getRoute())
                .setTime(record.getTime());
    }

    private static TreatmentFluid fromHla(TreatmentFluidRecord record){
        return new TreatmentFluid()
                .setVolume(record.getVolume())
                .setName(record.getName())
                .setTime(record.getTime())
                .setRoute(record.getRoute());
    }

    private static SignsSymptoms fromHla(SignsSymptomsRecord record){
        return new SignsSymptoms()
                .setAlertnessLevel(record.getAlertnessLevel())
                .setDiastolicBloodPressure(record.getDiastolicBloodPressure())
                .setPainScale(record.getPainScale())
                .setPulse(record.getPulse())
                .setPulseOxO2Saturation(record.getPulseOxO2aturation())
                .setRespiratoryRate(record.getRespiratoryRate())
                .setSystolicBloodPressure(record.getSystolicBloodPressure())
                .setTime(record.getTime());
    }

    private static ComparableList<InjuryLocation> fromHla(InjuryLocationRecord[] records){
        if(records == null) return new ComparableList<>();
        return new ComparableList<>(Arrays.stream(records).map(TcccHlaMapper::fromHla).collect(Collectors.toList()));
    }

    private static InjuryLocation fromHla(InjuryLocationRecord record){
        return new InjuryLocation()
                .setInjuryLocation(fromHla(record.getInjuryLocation()))
                .setInjuryType(record.getInjuryType());
    }

    private static ComparableList<BodyLocationCoarse> fromHla(BodyLocationCoarseEnum[] locations){
        if(locations == null) return new ComparableList<>();
        return new ComparableList<>(Arrays.stream(locations).map(loc -> BodyLocationCoarse.valueOf(loc.toString())).collect(Collectors.toList()));
    }

    private static Tourniquet fromHla(TourniquetRecord record){
        return new Tourniquet()
                .setTime(record.getTime())
                .setType(record.getType());
    }

}
