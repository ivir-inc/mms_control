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
import devstudio.generatedcode.datatypes.FacilityTypeEnum;
import devstudio.generatedcode.datatypes.PhysicalLocationRecord;
import devstudio.generatedcode.datatypes.RoleOfCareEnum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.function.Consumer;

@Component
public class FacilityAdapter implements MmsFederateInitializationListener, HlaFacilityListener, ConcurrentDataStorageListener<Facility> {

    @Autowired
    private FacilitySimDataService facilitySimDataService;
    private static final Logger logger = LoggerFactory.getLogger(FacilityAdapter.class);
    private MmsFederate mmsFederate;

    //---------------------------------------------------------------------------------------------
    //          MmsFederateInitializationListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        mmsFederate.getHlaWorld().getHlaFacilityManager().addHlaFacilityDefaultInstanceListener(this);
        facilitySimDataService.addDataStorageListener(this);
        logger.info("FacilityAdapter ready");
    }

    //---------------------------------------------------------------------------------------------
    //          HlaFacilityListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaFacility hlaFacility, Set<HlaFacilityAttributes.Attribute> updateSet, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if (!hlaFacility.isLocal()) {
            Facility facility = facilitySimDataService.getByInstanceName(hlaFacility.getHlaInstanceName());
            if (facility == null) {
                facility = new Facility()
                        .setInstanceName(hlaFacility.getHlaInstanceName())
                        .setLocal(false);
            }
            for (HlaFacilityAttributes.Attribute attribute : updateSet) {

                switch (attribute) {
                    case FACILITY_ID -> facility.setFacilityId(hlaFacility.getFacilityId());
                    case ROLE_OF_CARE ->
                            facility.setRoleOfCare(RoleOfCare.valueOf(hlaFacility.getRoleOfCare().toString()));
                    case FACILITY_TYPE ->
                            facility.setFacilityType(FacilityType.valueOf(hlaFacility.getFacilityType().toString()));
                    case LOCATION -> facility.setLocation(toLocation(hlaFacility.getLocation()));
                    case PATIENT_CAPACITY ->
                            facility.setPatientCapacity(hlaFacility.getPatientCapacity());
                }
            }
            facilitySimDataService.put(facility);
        }
    }

    private PhysicalLocation toLocation(PhysicalLocationRecord hlaLocation) {
        return new PhysicalLocation()
                .setLatitude(hlaLocation.getLatitude())
                .setLongitude(hlaLocation.getLongitude())
                .setAltitude(hlaLocation.getAltitude());
    }
    //---------------------------------------------------------------------------------------------
    //          SimDataListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void entityAdded(Facility newEntity) {
        if (newEntity.isLocal()) {
            try {
                HlaFacility hlaFacility = mmsFederate.getHlaWorld().getHlaFacilityManager().createLocalHlaFacility();
                HlaFacilityUpdater hlaFacilityUpdater = hlaFacility.getHlaFacilityUpdater();
                updateHlaFacility(newEntity, hlaFacilityUpdater);
                hlaFacilityUpdater.sendUpdate();
                newEntity.setInstanceName(hlaFacility.getHlaInstanceName());
                facilitySimDataService.put(newEntity, true);
            } catch (Exception e) {
                logger.error("Failed to send new facility to federation ", e);
            }
        }
    }

    @Override
    public void entityUpdated(Facility entity) {
        if (entity.isLocal()) {
            try {
                HlaFacility hlaFacility = mmsFederate.getHlaWorld().getHlaFacilityManager().getFacilityByHlaInstanceName(entity.getInstanceName());
                HlaFacilityUpdater hlaFacilityUpdater = hlaFacility.getHlaFacilityUpdater();
                updateHlaFacility(entity, hlaFacilityUpdater);
                hlaFacilityUpdater.sendUpdate();
            } catch (Exception e) {
                logger.error("Failed to update facility on federation", e);
            }
        }
    }

    private void updateHlaFacility(Facility entity, HlaFacilityUpdater updater) {
        entity.getUpdatedAttributes().forEach(attribute -> {
            switch (attribute) {
                case FACILITY_ID_STR -> ifNotNull(entity.getFacilityId(), updater::setFacilityId);
                case FACILITY_TYPE_ENUM ->
                        ifNotNull(entity.getFacilityType(), value -> updater.setFacilityType(FacilityTypeEnum.valueOf(value.toString())));
                case ROLE_OF_CARE_ENUM -> ifNotNull(entity.getRoleOfCare(), value -> updater.setRoleOfCare(RoleOfCareEnum.valueOf(value.toString())));
                case PATIENT_CAPACITY_INT -> ifNotNull(entity.getPatientCapacity(), updater::setPatientCapacity);
                case LOCATION_OBJ -> ifNotNull(toLocationRecord(entity.getLocation()), updater::setLocation);
            }
        });
    }

    private PhysicalLocationRecord toLocationRecord(PhysicalLocation location) {
        return PhysicalLocationRecord.create(location.getLatitude(), location.getLongitude(), location.getAltitude());
    }

    private <T> void ifNotNull(T value, Consumer<T> setCommand) {
        if (value != null) {
            setCommand.accept(value);
        }
    }
}
