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

package com.ivir.mpif.simdata;

import java.util.Arrays;
import java.util.List;
public class Signs extends ConcurrentSimData<Signs.Attributes> {
    private static final long serialVersionUID = -1234567890123456789L;

    public enum Attributes {
        INSTANCE_NAME,
        LOCAL,
        PATIENT_ID,
        HEART_SOUND,
        LUNG_SOUND,
        BOWEL_SOUND,
        COUGH_SOUND,
        ECG_RHYTHM,
        PUPIL_SIZE,
        TIME_STAMP
    }

    public Signs() {
        super(Signs.Attributes.class, Attributes.PATIENT_ID); // Default key is now PATIENT_ID
    }

    // =============================
    // INSTANCE MANAGEMENT
    // =============================
    public String getInstanceName() {
        return (String) this.getValue(Attributes.INSTANCE_NAME);
    }

    public Signs setInstanceName(String instanceName) {
        this.setValue(Attributes.INSTANCE_NAME, instanceName);
        return this;
    }

    public Boolean isLocal() {
        return (Boolean) this.getValue(Attributes.LOCAL);
    }

    public Signs setLocal(boolean local) {
        this.setValue(Attributes.LOCAL, local);
        return this;
    }

    // =============================
    // ATTRIBUTE GETTERS (Allow NULL)
    // =============================
    public String getPatientId() {  // Map patientId directly to ID
        return (String) this.getValue(Attributes.PATIENT_ID);
    }

    public String getHeartSound() {
        return (String) this.getValue(Attributes.HEART_SOUND); 
    }

    public String getLungSound() {
        return (String) this.getValue(Attributes.LUNG_SOUND);
    }

    public String getBowelSound() {
        return (String) this.getValue(Attributes.BOWEL_SOUND);
    }

    public String getCoughSound() {
        return (String) this.getValue(Attributes.COUGH_SOUND);
    }

    public String getEcgRhythm() {
        return (String) this.getValue(Attributes.ECG_RHYTHM);
    }

    public String getPupilSize() {
        return (String) this.getValue(Attributes.PUPIL_SIZE);
    }

    public Long getTimeStamp() {
        return (Long) this.getValue(Attributes.TIME_STAMP);
    }

    // =============================
    // ATTRIBUTE SETTERS (Only Accept Valid Values)
    // =============================
    public Signs setPatientId(String patientId) {  // Ensure Signs uses patientId
        this.setValue(Attributes.PATIENT_ID, patientId);
        if (patientId != null) {
            this.setInstanceName("SIGNS_" + patientId);
        }
        return this;
    }
    
    public Signs setHeartSound(String heartSound) {
        if (heartSound == null || isValidHeartSound(heartSound)) {
            this.setValue(Attributes.HEART_SOUND, heartSound);
        } else {
            System.err.println("Invalid heart sound: " + heartSound);
        }
        return this;
    }

    public Signs setLungSound(String lungSound) {
        if (lungSound == null || isValidLungSound(lungSound)) {
            this.setValue(Attributes.LUNG_SOUND, lungSound);
        } else {
            System.err.println("Invalid lung sound: " + lungSound);
        }
        return this;
    }

    public Signs setBowelSound(String bowelSound) {
        if (bowelSound == null || isValidBowelSound(bowelSound)) {
            this.setValue(Attributes.BOWEL_SOUND, bowelSound);
        } else {
            System.err.println("Invalid bowel sound: " + bowelSound);
        }
        return this;
    }

    public Signs setCoughSound(String coughSound) {
        if (coughSound == null || isValidCoughSound(coughSound)) {
            this.setValue(Attributes.COUGH_SOUND, coughSound);
        } else {
            System.err.println("Invalid cough sound: " + coughSound);
        }
        return this;
    }

    public Signs setEcgRhythm(String ecgRhythm) {
        if (ecgRhythm == null || isValidEcgRhythm(ecgRhythm)) {
            this.setValue(Attributes.ECG_RHYTHM, ecgRhythm);
        } else {
            System.err.println("Invalid ECG rhythm: " + ecgRhythm);
        }
        return this;
    }

    public Signs setPupilSize(String pupilSize) {
        if (pupilSize == null || isValidPupilSize(pupilSize)) {
            this.setValue(Attributes.PUPIL_SIZE, pupilSize);
        } else {
            System.err.println("Invalid pupil size: " + pupilSize);
        }
        return this;
    }

    public Signs setTimeStamp(Long timeStamp) {
        this.setValue(Attributes.TIME_STAMP, timeStamp);
        return this;
    }

    // =============================
    // ENUM VALIDATION METHODS
    // =============================
    private static final List<String> VALID_HEART_SOUNDS = Arrays.asList(
        "notApplicable", "normal", "murmur", "aorticStenosisEarly", "aorticStenosisLate",
        "mitralRegurgitation", "mitralStenosis", "pulmonicStenosis", "aorticInsufficiency",
        "atrialSeptalDefect", "ventricularSeptalDefect", "tricuspidRegurgitation",
        "patentDuctusAsteriosus", "s2", "s3", "s4", "pericardialRub", "null"
    );

    private static final List<String> VALID_LUNG_SOUNDS = Arrays.asList(
            "notApplicable", "normal", "cracklesCoarse", "cracklesFine", "pleuralRub",
            "rhonchi", "stridor", "wheeze", "null"
    );

    private static final List<String> VALID_BOWEL_SOUNDS = Arrays.asList(
            "notApplicable", "normal", "hyperactiveBowels", "hypoactiveBowels", "null"
    );

    private static final List<String> VALID_ECG_RHYTHMS = Arrays.asList(
            "notApplicable", "normalSinus", "firstDegreeHeartBlock", "secondDegreeAVHeartBlock",
            "thirdDegreeHeartBlock", "supraventricularTachycardia", "ventricularTachycardia",
            "ventricularFibrillation", "atrialFibrillation", "atrialFlutter", "asystole",
            "pulselessElectricalActivity", "pulselessVentricularTachycardia", "longQT"
    );

    private static final List<String> VALID_PUPIL_SIZES = Arrays.asList(
            "notApplicable", "normal", "dilated", "constricted"
    );

    private static final List<String> VALID_COUGH_TYPES = Arrays.asList(
            "n_a", "dry", "wetWithPhlegm", "wetWithBlood", "wetWithoutPhelgm",
            "coughWithWheeze", "paroxysmalCough", "barkingCough", "whoopingCough", "choking"
    );

    private boolean isValidHeartSound(String value) {
        return isValidEnumValue(value, VALID_HEART_SOUNDS, "HeartSoundEnum");
    }

    private boolean isValidLungSound(String value) {
        return isValidEnumValue(value, VALID_LUNG_SOUNDS, "LungSoundEnum");
    }

    private boolean isValidBowelSound(String value) {
        return isValidEnumValue(value, VALID_BOWEL_SOUNDS, "BowelSoundEnum");
    }

    private boolean isValidEcgRhythm(String value) {
        return isValidEnumValue(value, VALID_ECG_RHYTHMS, "EcgRhythmEnum");
    }

    private boolean isValidPupilSize(String value) {
        return isValidEnumValue(value, VALID_PUPIL_SIZES, "PupilSizeEnum");
    }

    private boolean isValidCoughSound(String value) {
        return isValidEnumValue(value, VALID_COUGH_TYPES, "CoughEnum");
    }

    /**
     * Generic method to validate an enum string against a list of valid values.
     */
    private boolean isValidEnumValue(String value, List<String> validValues, String enumName) {
        if (value == null) {
            return true; // Allow null values
        }
    
        // Normalize value for comparison
        String formattedValue = value.trim().replaceAll("[-_]", "").toLowerCase();
    
        boolean isValid = validValues.stream()
            .map(v -> v.replaceAll("[-_]", "").toLowerCase()) // Normalize valid values
            .anyMatch(v -> v.equals(formattedValue));
    
        if (!isValid) {
            System.err.println("Invalid " + enumName + ": " + value + ". Expected: " + validValues);
        }
        return isValid;
    }

}
