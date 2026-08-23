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

import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.Signs;
import com.ivir.mpif.simdata.SignsSimDataService;

import devstudio.generatedcode.HlaLogicalTime;
import devstudio.generatedcode.HlaSigns;
import devstudio.generatedcode.HlaSignsAttributes;
import devstudio.generatedcode.HlaSignsListener;
import devstudio.generatedcode.HlaSignsManager;
import devstudio.generatedcode.HlaSignsManagerListener;
import devstudio.generatedcode.HlaSignsUpdater;
import devstudio.generatedcode.HlaTimeStamp;
import devstudio.generatedcode.HlaWorld;
import devstudio.generatedcode.datatypes.BowelSoundEnum;
import devstudio.generatedcode.datatypes.CoughEnum;
import devstudio.generatedcode.datatypes.EcgRhythmEnum;
import devstudio.generatedcode.datatypes.HeartSoundEnum;
import devstudio.generatedcode.datatypes.LungSoundEnum;
import devstudio.generatedcode.datatypes.PupilSizeEnum;
import jakarta.annotation.PostConstruct;

@Component
public class SignsAdapter implements MmsFederateInitializationListener, HlaSignsListener, HlaSignsManagerListener, ConcurrentDataStorageListener<Signs> {
    private static final Logger logger = Logger.getLogger("SignsAdapter");

    private MmsFederate mmsFederate;
    private HlaSignsManager hlaSignsManager;

    @Autowired
    private SignsSimDataService signsSimDataService;

    public SignsAdapter() {
    }

    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        this.hlaSignsManager = mmsFederate.getHlaWorld().getHlaSignsManager();
        if (this.hlaSignsManager != null) {
            this.hlaSignsManager.addHlaSignsManagerListener(this);
            this.hlaSignsManager.addHlaSignsDefaultInstanceListener(this);
            signsSimDataService.addDataStorageListener(this); // Listen for local storage updates
        }
    }

    @Override
    public void entityAdded(Signs newEntity) {
        logger.info("New signs entity detected in local storage for patient: " + newEntity.getPatientId());
        updateHlaSigns(newEntity.getPatientId(), newEntity);
    }

    @Override
    public void entityUpdated(Signs entity) {
        logger.info("Signs entity updated in local storage for patient: " + entity.getPatientId());
        updateHlaSigns(entity.getPatientId(), entity);
    }

    @Override
    public void attributesUpdated(HlaSigns hlaSigns, Set<HlaSignsAttributes.Attribute> attributes, HlaTimeStamp timeStamp, HlaLogicalTime logicalTime) {
        logger.info("Received update from HLA for patient: " + hlaSigns.getHlaInstanceName());

        Signs updatedSigns = convertHlaSignsToSigns(hlaSigns);
        
        logger.info("⬇HLA sent back: " + 
            "PatientId=" + updatedSigns.getPatientId() + 
            ", HeartSound=" + updatedSigns.getHeartSound() + 
            ", LungSound=" + updatedSigns.getLungSound() + 
            ", BowelSound=" + updatedSigns.getBowelSound() + 
            ", Cough=" + updatedSigns.getCoughSound() + 
            ", ECG=" + updatedSigns.getEcgRhythm() + 
            ", PupilSize=" + updatedSigns.getPupilSize()
        );

        signsSimDataService.putSigns(updatedSigns);  // Sync back to local storage
    }

    private boolean updateHlaSigns(String patientId, Signs signs) {
        if (hlaSignsManager == null || !mmsFederate.isConnected()) {
            logger.warning("Cannot update HLA: Not connected.");
            return false;
        }
    
        HlaSigns hlaSigns = findHlaSignsInstance(patientId);
        
        if (hlaSigns == null) {
            logger.info("ℹNo existing HLA Signs instance for patient: " + patientId + ". Creating new one...");
            hlaSigns = createHlaSignsInstance(patientId);
            if (hlaSigns == null) {
                logger.severe("Failed to create HLA Signs instance for patient: " + patientId);
                return false;
            }
        } else {
            logger.info("Found existing HLA Signs instance for patient: " + patientId + ". Updating...");
        }
    
        try {
            HlaSignsUpdater updater = hlaSigns.getHlaSignsUpdater();
            updater.setPatientId(patientId);
    
            // Log every value being sent to HLA
            HeartSoundEnum heartSound = parseHeartSound(signs.getHeartSound());
            LungSoundEnum lungSound = parseLungSound(signs.getLungSound());
            BowelSoundEnum bowelSound = parseBowelSound(signs.getBowelSound());
            CoughEnum cough = parseCoughSound(signs.getCoughSound());
            EcgRhythmEnum ecgRhythm = parseEcgRhythm(signs.getEcgRhythm());
            PupilSizeEnum pupilSize = parsePupilSize(signs.getPupilSize());
    
            logger.info("Sending update to HLA: " + 
                "PatientId=" + patientId + 
                ", HeartSound=" + heartSound + 
                ", LungSound=" + lungSound + 
                ", BowelSound=" + bowelSound + 
                ", Cough=" + cough + 
                ", ECG=" + ecgRhythm + 
                ", PupilSize=" + pupilSize
            );
    
            updater.setHeartSound(heartSound);
            updater.setLungSound(lungSound);
            updater.setBowelSound(bowelSound);
            updater.setCough(cough);
            updater.setEcgRhythm(ecgRhythm);
            updater.setPupilSize(pupilSize);
    
            updater.sendUpdate();
    
            logger.info("Successfully updated HLA Signs for patient: " + patientId);
            return true;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to update HLA for patient: " + patientId, e);
            return false;
        }
    }
        
    private HeartSoundEnum parseHeartSound(String value) {
        if (value == null) {
            return HeartSoundEnum.NOT_APPLICABLE;
        }
    
        try {
            // Normalize input (remove underscores, lowercase for case-insensitive match)
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
    
            // Find a matching enum value
            for (HeartSoundEnum e : HeartSoundEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
    
            throw new IllegalArgumentException();  // If no match, throw error to catch block
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid heart sound: " + value + " (Expected one of: " + HeartSoundEnum.values() + ")");
            return HeartSoundEnum.NOT_APPLICABLE;
        }
    }
    
    private LungSoundEnum parseLungSound(String value) {
        if (value == null) {
            return LungSoundEnum.NOT_APPLICABLE;
        }
    
        try {
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
            for (LungSoundEnum e : LungSoundEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
            throw new IllegalArgumentException();
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid lung sound: " + value);
            return LungSoundEnum.NOT_APPLICABLE;
        }
    }
    
    private BowelSoundEnum parseBowelSound(String value) {
        if (value == null) {
            return BowelSoundEnum.NOT_APPLICABLE;
        }
    
        try {
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
            for (BowelSoundEnum e : BowelSoundEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
            throw new IllegalArgumentException();
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid bowel sound: " + value);
            return BowelSoundEnum.NOT_APPLICABLE;
        }
    }
    
    private CoughEnum parseCoughSound(String value) {
        if (value == null) {
            return CoughEnum.NOT_APPLICABLE;
        }
    
        try {
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
            for (CoughEnum e : CoughEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
            throw new IllegalArgumentException();
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid cough sound: " + value);
            return CoughEnum.NOT_APPLICABLE;
        }
    }
    
    
    private EcgRhythmEnum parseEcgRhythm(String value) {
        if (value == null) {
            return EcgRhythmEnum.NOT_APPLICABLE;
        }
    
        try {
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
            for (EcgRhythmEnum e : EcgRhythmEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
            throw new IllegalArgumentException();
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid ECG rhythm: " + value);
            return EcgRhythmEnum.NOT_APPLICABLE;
        }
    }
    
    private PupilSizeEnum parsePupilSize(String value) {
        if (value == null) {
            return PupilSizeEnum.NOT_APPLICABLE;
        }
    
        try {
            String normalizedValue = value.trim().replaceAll("[-_]", "").toUpperCase();
            for (PupilSizeEnum e : PupilSizeEnum.values()) {
                if (e.name().replaceAll("[-_]", "").equalsIgnoreCase(normalizedValue)) {
                    return e;
                }
            }
            throw new IllegalArgumentException();
        } catch (IllegalArgumentException e) {
            logger.warning("Invalid pupil size: " + value);
            return PupilSizeEnum.NOT_APPLICABLE;
        }
    }
    
    private HlaSigns findHlaSignsInstance(String patientId) {
        if (hlaSignsManager == null) {
            logger.warning("HLA Signs Manager is null, cannot find instance for: " + patientId);
            return null;
        }
    
        return hlaSignsManager.getAllHlaSigns().stream()
            .filter(hla -> hla.getHlaSignsAttributes().hasPatientId() &&
                    hla.getHlaSignsAttributes().getPatientId().equals(patientId)) // ✅ Ensure matching patientId
            .findFirst()
            .orElse(null);
    }

    private HlaSigns createHlaSignsInstance(String patientId) {
        try {
            // 🔍 Ensure the instance doesn't already exist before creating
            if (findHlaSignsInstance(patientId) != null) {
                logger.warning("Attempted to create duplicate HLA Signs instance for patient: " + patientId);
                return findHlaSignsInstance(patientId);
            }
    
            String instanceName = "SIGNS_" + patientId;  // ✅ Ensure unique instance naming
            HlaSigns hlaSigns = hlaSignsManager.createLocalHlaSigns(instanceName);
    
            if (hlaSigns != null) {
                logger.info("Successfully created new HLA Signs instance for patient: " + patientId);
            }
    
            return hlaSigns;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Exception while creating new HLA Signs instance", e);
            return null;
        }
    }
    
    private Signs convertHlaSignsToSigns(HlaSigns hlaSigns) {
        logger.info("Converting HLA Signs to local Signs object for patient: " + hlaSigns.getHlaInstanceName());
        HlaSignsAttributes attributes = hlaSigns.getHlaSignsAttributes();

        Signs newSigns = new Signs()
            .setInstanceName(hlaSigns.getHlaInstanceName())
            .setPatientId(attributes.hasPatientId() ? attributes.getPatientId() : null)  // ✅ Use patientId instead of id
            .setHeartSound(attributes.hasHeartSound() ? attributes.getHeartSound().name() : HeartSoundEnum.NOT_APPLICABLE.name())
            .setLungSound(attributes.hasLungSound() ? attributes.getLungSound().name() : LungSoundEnum.NOT_APPLICABLE.name())
            .setBowelSound(attributes.hasBowelSound() ? attributes.getBowelSound().name() : BowelSoundEnum.NOT_APPLICABLE.name())
            .setCoughSound(attributes.hasCough() ? attributes.getCough().name() : CoughEnum.NOT_APPLICABLE.name())
            .setEcgRhythm(attributes.hasEcgRhythm() ? attributes.getEcgRhythm().name() : EcgRhythmEnum.NOT_APPLICABLE.name())
            .setPupilSize(attributes.hasPupilSize() ? attributes.getPupilSize().name() : PupilSizeEnum.NOT_APPLICABLE.name());

        return newSigns;
    }

    @Override
    public void hlaSignsDiscovered(HlaSigns hlaSigns, HlaTimeStamp timeStamp) {
        logger.info("HLA Signs discovered: " + hlaSigns.getHlaInstanceName());
    }

    @Override
    public void hlaSignsInitialized(HlaSigns hlaSigns, HlaTimeStamp timeStamp, HlaLogicalTime logicalTime) {
        logger.info("HLA Signs initialized: " + hlaSigns.getHlaInstanceName());
    }

    @Override
    public void hlaSignsDeleted(HlaSigns hlaSigns, HlaTimeStamp timeStamp, HlaLogicalTime logicalTime) {
        logger.warning("HLA Signs deleted: " + hlaSigns.getHlaInstanceName());
        signsSimDataService.removeSigns(hlaSigns.getPatientId());
    }

    @Override
    public void hlaSignsInInterest(HlaSigns hlaSigns, HlaTimeStamp timeStamp) {
        logger.info("HLA Signs in interest: " + hlaSigns.getHlaInstanceName());
    }

    @Override
    public void hlaSignsOutOfInterest(HlaSigns hlaSigns, HlaTimeStamp timeStamp) {
        logger.info("HLA Signs out of interest: " + hlaSigns.getHlaInstanceName());
    }
}
