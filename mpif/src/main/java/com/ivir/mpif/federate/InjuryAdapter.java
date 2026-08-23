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
import devstudio.generatedcode.*;
import devstudio.generatedcode.datatypes.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.function.Consumer;

import static com.ivir.mpif.simdata.BodyLocationConversionUtil.toBodyLocation;
import static com.ivir.mpif.simdata.BodyLocationConversionUtil.toBodyLocationRecord;

@Component
public class InjuryAdapter implements MmsFederateInitializationListener, HlaInjuryListener, ConcurrentDataStorageListener<Injury> {
    private final static Logger logger = LoggerFactory.getLogger(InjuryAdapter.class);
    private MmsFederate mmsFederate;

    @Autowired
    private InjurySimDataService injurySimDataService;


    //---------------------------------------------------------------------------------------------
    //          MmsFederateInitializationListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        mmsFederate.getHlaWorld().getHlaInjuryManager().addHlaInjuryDefaultInstanceListener(this);
        injurySimDataService.addDataStorageListener(this);
        logger.info("InjuryAdapter ready");
    }


    //---------------------------------------------------------------------------------------------
    //          HlaInjuryListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaInjury hlaInjury, Set<HlaInjuryAttributes.Attribute> updateSet, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!hlaInjury.isLocal()){
            Injury injury = injurySimDataService.getByInstanceName(hlaInjury.getHlaInstanceName());
            if(injury == null){
                injury = new Injury()
                        .setInstanceName(hlaInjury.getHlaInstanceName())
                        .setLocal(false);
            }
            for(HlaInjuryAttributes.Attribute attribute : updateSet){
                switch(attribute){
                    case HEMORRHAGE_RATE -> injury.setHemorrhageRate(hlaInjury.getHemorrhageRate());
                    case INJURY_ID -> injury.setInjuryId(hlaInjury.getInjuryId());
                    case INJURY_DESCRIPTION -> injury.setDescription(
                            InjuryDescription.valueOf(hlaInjury.getInjuryDescription().toString()));
                    case INJURY_DETAIL -> injury.setDetail(hlaInjury.getInjuryDetail());
                    case INJURY_LOCATION -> injury.setLocation(toBodyLocation(hlaInjury.getInjuryLocation()));
                    case INJURY_SEVERITY -> injury.setSeverity(hlaInjury.getInjurySeverity());
                    case INJURY_TYPE -> injury.setInjuryType(InjuryType.valueOf(hlaInjury.getInjuryType().toString()));
                    case MECHANISM_OF_INJURY -> injury.setMechanismOfInjury(fromHla(hlaInjury.getMechanismOfInjury()));
                    case PATIENT_ID -> injury.setPatientId(hlaInjury.getPatientId());
                    case TIME -> injury.setTime(hlaInjury.getTime());
                    case TOTAL_BODY_SURFACE_AREA -> injury.setTotalBodySurfaceArea(hlaInjury.getTotalBodySurfaceArea());
                }
            }
            injurySimDataService.put(injury);
        }
    }

    private MechanismOfInjury fromHla(MechanismOfInjuryRecord hlaRecord){
        MechanismOfInjury sdRecord = new MechanismOfInjury();
        sdRecord.setBlast(BlastType.valueOf(hlaRecord.getBlast().toString()));
        sdRecord.setBlade(BladeType.valueOf(hlaRecord.getBlade().toString()));
        sdRecord.setCbrn(CbrnType.valueOf(hlaRecord.getCbrn().toString()));
        sdRecord.setFall(FallType.valueOf(hlaRecord.getFall().toString()));
        sdRecord.setGunshotAmmunitionType(GunshotAmmunitionType.valueOf(hlaRecord.getGunshotAmmunitionType().toString()));
        sdRecord.setGunshotCaliber(GunshotCaliber.valueOf(hlaRecord.getGunshotCaliber().toString()));
        sdRecord.setShrapnel(ShrapnelType.valueOf(hlaRecord.getShrapnel().toString()));
        sdRecord.setVehicleCrash(VehicleCrash.valueOf(hlaRecord.getVehicleCrash().toString()));
        return sdRecord;
    }

    //---------------------------------------------------------------------------------------------
    //          SimDataListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void entityAdded(Injury newEntity) {
        if(newEntity.isLocal()){
            try {
                HlaInjury hlaInjury = mmsFederate.getHlaWorld().getHlaInjuryManager().createLocalHlaInjury();
                HlaInjuryUpdater hlaInjuryUpdater = hlaInjury.getHlaInjuryUpdater();
                updateHlaInjury(newEntity, hlaInjuryUpdater);
                hlaInjuryUpdater.sendUpdate();
                newEntity.setInstanceName(hlaInjury.getHlaInstanceName());
                injurySimDataService.put(newEntity, true);
            }catch (Exception e){
                logger.error("Failed to send new injury to federation ", e);
            }
        }
    }

    @Override
    public void entityUpdated(Injury entity) {
        if(entity.isLocal()){
            try {
                HlaInjury hlaInjury = mmsFederate.getHlaWorld().getHlaInjuryManager().getInjuryByHlaInstanceName(entity.getInstanceName());
                HlaInjuryUpdater hlaInjuryUpdater = hlaInjury.getHlaInjuryUpdater();
                updateHlaInjury(entity, hlaInjuryUpdater);
                hlaInjuryUpdater.sendUpdate();
            }catch(Exception e){
                logger.error("Failed to update injury on federation", e);
            }
        }
    }

    private void updateHlaInjury(Injury entity, HlaInjuryUpdater updater){
        entity.getUpdatedAttributes().forEach((attribute) -> {
            switch (attribute){
                case DESCRIPTION_ENUM -> ifNotNull(entity.getDescription(),
                        (value)-> updater.setInjuryDescription(InjuryDescriptionEnum.valueOf(value.toString())));
                case DETAIL_STR -> ifNotNull(entity.getDetail(),(value)->updater.setInjuryDetail(value));
                case HEMORRHAGE_RATE_FLT -> ifNotNull(entity.getHemorrhageRate(),(value)->updater.setHemorrhageRate(value));
                case INJURY_ID_STR -> ifNotNull(entity.getInjuryId(), (value)->updater.setInjuryId(value));
                case INJURY_TYPE_ENUM -> ifNotNull(entity.getInjuryType(),
                        (value)->updater.setInjuryType(InjuryTypeEnum.valueOf(value.toString())));
                case LOCATION_OBJ -> ifNotNull(entity.getLocation(),
                        (value)-> updater.setInjuryLocation(toBodyLocationRecord(value)));
                case MECHANISM_OF_INJURY_OBJ -> ifNotNull(entity.getMechanismOfInjury(),
                        (value)->updater.setMechanismOfInjury(toHla(value)));
                case PATIENT_ID_STR -> ifNotNull(entity.getPatientId(), (value)->updater.setPatientId(value));
                case SEVERITY_INT -> ifNotNull(entity.getSeverity(), (value)-> updater.setInjurySeverity(value));
                case TIME_LON -> ifNotNull(entity.getTime(), (value)->updater.setTime(value));
                case TOTAL_BODY_SURFACE_AREA_FLT -> ifNotNull(entity.getTotalBodySurfaceArea(),
                        (value)->updater.setTotalBodySurfaceArea(value));
            }
        });
    }

    private <T> void ifNotNull(T value, Consumer<T> setCommand){
        if(value != null){
            setCommand.accept(value);
        }
    }

    private MechanismOfInjuryRecord toHla(MechanismOfInjury moi){
        return MechanismOfInjuryRecord.create(
                GunshotCaliberEnum.valueOf(moi.getGunshotCaliber().toString()),
                GunshotAmmunitionTypeEnum.valueOf(moi.getGunshotAmmunitionType().toString()),
                BladeTypeEnum.valueOf(moi.getBlade().toString()),
                BlastTypeEnum.valueOf(moi.getBlast().toString()),
                VehicleCrashEnum.valueOf(moi.getVehicleCrash().toString()),
                FallTypeEnum.valueOf(moi.getFall().toString()),
                CBRNTypeEnum.valueOf(moi.getCbrn().toString()),
                ShrapnelTypeEnum.valueOf(moi.getShrapnel().toString())
        );
    }
}
