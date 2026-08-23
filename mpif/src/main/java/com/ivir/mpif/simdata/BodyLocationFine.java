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

public enum BodyLocationFine {
    /** <code>anteriorHead</code> (with ordinal 1) */
    ANTERIOR_HEAD("anteriorHead", 1),
    /** <code>anteriorFace</code> (with ordinal 2) */
    ANTERIOR_FACE("anteriorFace", 2),
    /** <code>anteriorNeck</code> (with ordinal 3) */
    ANTERIOR_NECK("anteriorNeck", 3),
    /** <code>anteriorSternum</code> (with ordinal 4) */
    ANTERIOR_STERNUM("anteriorSternum", 4),
    /** <code>anteriorPelvis</code> (with ordinal 5) */
    ANTERIOR_PELVIS("anteriorPelvis", 5),
    /** <code>anteriorGenitals</code> (with ordinal 6) */
    ANTERIOR_GENITALS("anteriorGenitals", 6),
    /** <code>anteriorRightUpperChest</code> (with ordinal 7) */
    ANTERIOR_RIGHT_UPPER_CHEST("anteriorRightUpperChest", 7),
    /** <code>anteriorRightLowerChest</code> (with ordinal 8) */
    ANTERIOR_RIGHT_LOWER_CHEST("anteriorRightLowerChest", 8),
    /** <code>anteriorRightUpperQuadrant</code> (with ordinal 9) */
    ANTERIOR_RIGHT_UPPER_QUADRANT("anteriorRightUpperQuadrant", 9),
    /** <code>anteriorRightLowerQuadrant</code> (with ordinal 10) */
    ANTERIOR_RIGHT_LOWER_QUADRANT("anteriorRightLowerQuadrant", 10),
    /** <code>anteriorRightGroin</code> (with ordinal 11) */
    ANTERIOR_RIGHT_GROIN("anteriorRightGroin", 11),
    /** <code>anteriorRightHip</code> (with ordinal 12) */
    ANTERIOR_RIGHT_HIP("anteriorRightHip", 12),
    /** <code>anteriorRightShoulder</code> (with ordinal 13) */
    ANTERIOR_RIGHT_SHOULDER("anteriorRightShoulder", 13),
    /** <code>anteriorRightBicep</code> (with ordinal 14) */
    ANTERIOR_RIGHT_BICEP("anteriorRightBicep", 14),
    /** <code>anteriorRightElbow</code> (with ordinal 15) */
    ANTERIOR_RIGHT_ELBOW("anteriorRightElbow", 15),
    /** <code>anteriorRightProximalForearm</code> (with ordinal 16) */
    ANTERIOR_RIGHT_PROXIMAL_FOREARM("anteriorRightProximalForearm", 16),
    /** <code>anteriorRightMiddleForearm</code> (with ordinal 17) */
    ANTERIOR_RIGHT_MIDDLE_FOREARM("anteriorRightMiddleForearm", 17),
    /** <code>anteriorRightDistalForearm</code> (with ordinal 18) */
    ANTERIOR_RIGHT_DISTAL_FOREARM("anteriorRightDistalForearm", 18),
    /** <code>anteriorRightWrist</code> (with ordinal 19) */
    ANTERIOR_RIGHT_WRIST("anteriorRightWrist", 19),
    /** <code>anteriorRightPalm</code> (with ordinal 20) */
    ANTERIOR_RIGHT_PALM("anteriorRightPalm", 20),
    /** <code>anteriorRightProximalThigh</code> (with ordinal 21) */
    ANTERIOR_RIGHT_PROXIMAL_THIGH("anteriorRightProximalThigh", 21),
    /** <code>anteriorRightMiddleThigh</code> (with ordinal 22) */
    ANTERIOR_RIGHT_MIDDLE_THIGH("anteriorRightMiddleThigh", 22),
    /** <code>anteriorRightDistalThigh</code> (with ordinal 23) */
    ANTERIOR_RIGHT_DISTAL_THIGH("anteriorRightDistalThigh", 23),
    /** <code>anteriorRightKnee</code> (with ordinal 24) */
    ANTERIOR_RIGHT_KNEE("anteriorRightKnee", 24),
    /** <code>anteriorRightProximalLowerLeg</code> (with ordinal 25) */
    ANTERIOR_RIGHT_PROXIMAL_LOWER_LEG("anteriorRightProximalLowerLeg", 25),
    /** <code>anteriorRightMiddleLowerLeg</code> (with ordinal 26) */
    ANTERIOR_RIGHT_MIDDLE_LOWER_LEG("anteriorRightMiddleLowerLeg", 26),
    /** <code>anteriorRightDistalLowerLeg</code> (with ordinal 27) */
    ANTERIOR_RIGHT_DISTAL_LOWER_LEG("anteriorRightDistalLowerLeg", 27),
    /** <code>anteriorRightAnkle</code> (with ordinal 28) */
    ANTERIOR_RIGHT_ANKLE("anteriorRightAnkle", 28),
    /** <code>anteriorRightFoot</code> (with ordinal 29) */
    ANTERIOR_RIGHT_FOOT("anteriorRightFoot", 29),
    /** <code>anteriorLeftUpperChest</code> (with ordinal 30) */
    ANTERIOR_LEFT_UPPER_CHEST("anteriorLeftUpperChest", 30),
    /** <code>anteriorLeftLowerChest</code> (with ordinal 31) */
    ANTERIOR_LEFT_LOWER_CHEST("anteriorLeftLowerChest", 31),
    /** <code>anteriorLeftUpperQuadrant</code> (with ordinal 32) */
    ANTERIOR_LEFT_UPPER_QUADRANT("anteriorLeftUpperQuadrant", 32),
    /** <code>anteriorLeftLowerQuadrant</code> (with ordinal 33) */
    ANTERIOR_LEFT_LOWER_QUADRANT("anteriorLeftLowerQuadrant", 33),
    /** <code>anteriorLeftGroin</code> (with ordinal 34) */
    ANTERIOR_LEFT_GROIN("anteriorLeftGroin", 34),
    /** <code>anteriorLeftHip</code> (with ordinal 35) */
    ANTERIOR_LEFT_HIP("anteriorLeftHip", 35),
    /** <code>anteriorLeftShoulder</code> (with ordinal 36) */
    ANTERIOR_LEFT_SHOULDER("anteriorLeftShoulder", 36),
    /** <code>anteriorLeftBicep</code> (with ordinal 37) */
    ANTERIOR_LEFT_BICEP("anteriorLeftBicep", 37),
    /** <code>anteriorLeftElbow</code> (with ordinal 38) */
    ANTERIOR_LEFT_ELBOW("anteriorLeftElbow", 38),
    /** <code>anteriorLeftProximalForearm</code> (with ordinal 39) */
    ANTERIOR_LEFT_PROXIMAL_FOREARM("anteriorLeftProximalForearm", 39),
    /** <code>anteriorLeftMiddleForearm</code> (with ordinal 40) */
    ANTERIOR_LEFT_MIDDLE_FOREARM("anteriorLeftMiddleForearm", 40),
    /** <code>anteriorLeftDistalForearm</code> (with ordinal 41) */
    ANTERIOR_LEFT_DISTAL_FOREARM("anteriorLeftDistalForearm", 41),
    /** <code>anteriorLeftWrist</code> (with ordinal 42) */
    ANTERIOR_LEFT_WRIST("anteriorLeftWrist", 42),
    /** <code>anteriorLeftPalm</code> (with ordinal 43) */
    ANTERIOR_LEFT_PALM("anteriorLeftPalm", 43),
    /** <code>anteriorLeftProximalThigh</code> (with ordinal 44) */
    ANTERIOR_LEFT_PROXIMAL_THIGH("anteriorLeftProximalThigh", 44),
    /** <code>anteriorLeftMiddleThigh</code> (with ordinal 45) */
    ANTERIOR_LEFT_MIDDLE_THIGH("anteriorLeftMiddleThigh", 45),
    /** <code>anteriorLeftDistalThigh</code> (with ordinal 46) */
    ANTERIOR_LEFT_DISTAL_THIGH("anteriorLeftDistalThigh", 46),
    /** <code>anteriorLeftKnee</code> (with ordinal 47) */
    ANTERIOR_LEFT_KNEE("anteriorLeftKnee", 47),
    /** <code>anteriorLeftProximalLowerLeg</code> (with ordinal 48) */
    ANTERIOR_LEFT_PROXIMAL_LOWER_LEG("anteriorLeftProximalLowerLeg", 48),
    /** <code>anteriorLeftMiddleLowerLeg</code> (with ordinal 49) */
    ANTERIOR_LEFT_MIDDLE_LOWER_LEG("anteriorLeftMiddleLowerLeg", 49),
    /** <code>anteriorLeftDistalLowerLeg</code> (with ordinal 50) */
    ANTERIOR_LEFT_DISTAL_LOWER_LEG("anteriorLeftDistalLowerLeg", 50),
    /** <code>anteriorLeftAnkle</code> (with ordinal 51) */
    ANTERIOR_LEFT_ANKLE("anteriorLeftAnkle", 51),
    /** <code>anteriorLeftFoot</code> (with ordinal 52) */
    ANTERIOR_LEFT_FOOT("anteriorLeftFoot", 52),
    /** <code>posteriorHead</code> (with ordinal 53) */
    POSTERIOR_HEAD("posteriorHead", 53),
    /** <code>posteriorNeck</code> (with ordinal 54) */
    POSTERIOR_NECK("posteriorNeck", 54),
    /** <code>posteriorThoracicSpine</code> (with ordinal 55) */
    POSTERIOR_THORACIC_SPINE("posteriorThoracicSpine", 55),
    /** <code>posteriorLumbarSpine</code> (with ordinal 56) */
    POSTERIOR_LUMBAR_SPINE("posteriorLumbarSpine", 56),
    /** <code>posteriorTailBone</code> (with ordinal 57) */
    POSTERIOR_TAIL_BONE("posteriorTailBone", 57),
    /** <code>posteriorLeftUpperBack</code> (with ordinal 58) */
    POSTERIOR_LEFT_UPPER_BACK("posteriorLeftUpperBack", 58),
    /** <code>posteriorLeftMiddleBack</code> (with ordinal 59) */
    POSTERIOR_LEFT_MIDDLE_BACK("posteriorLeftMiddleBack", 59),
    /** <code>posteriorLeftLowerBack</code> (with ordinal 60) */
    POSTERIOR_LEFT_LOWER_BACK("posteriorLeftLowerBack", 60),
    /** <code>posteriorLeftButtock</code> (with ordinal 61) */
    POSTERIOR_LEFT_BUTTOCK("posteriorLeftButtock", 61),
    /** <code>posteriorLeftShoulder</code> (with ordinal 62) */
    POSTERIOR_LEFT_SHOULDER("posteriorLeftShoulder", 62),
    /** <code>posteriorLeftBicep</code> (with ordinal 63) */
    POSTERIOR_LEFT_BICEP("posteriorLeftBicep", 63),
    /** <code>posteriorLeftElbow</code> (with ordinal 64) */
    POSTERIOR_LEFT_ELBOW("posteriorLeftElbow", 64),
    /** <code>posteriorLeftProximalForearm</code> (with ordinal 65) */
    POSTERIOR_LEFT_PROXIMAL_FOREARM("posteriorLeftProximalForearm", 65),
    /** <code>posteriorLeftMiddleForearm</code> (with ordinal 66) */
    POSTERIOR_LEFT_MIDDLE_FOREARM("posteriorLeftMiddleForearm", 66),
    /** <code>posteriorLeftDistalForearm</code> (with ordinal 67) */
    POSTERIOR_LEFT_DISTAL_FOREARM("posteriorLeftDistalForearm", 67),
    /** <code>posteriorLeftWrist</code> (with ordinal 68) */
    POSTERIOR_LEFT_WRIST("posteriorLeftWrist", 68),
    /** <code>posteriorLeftHand</code> (with ordinal 69) */
    POSTERIOR_LEFT_HAND("posteriorLeftHand", 69),
    /** <code>posteriorLeftFingers</code> (with ordinal 70) */
    POSTERIOR_LEFT_FINGERS("posteriorLeftFingers", 70),
    /** <code>posteriorLeftProximalThigh</code> (with ordinal 71) */
    POSTERIOR_LEFT_PROXIMAL_THIGH("posteriorLeftProximalThigh", 71),
    /** <code>posteriorLeftMiddleThigh</code> (with ordinal 72) */
    POSTERIOR_LEFT_MIDDLE_THIGH("posteriorLeftMiddleThigh", 72),
    /** <code>posteriorLeftDistalThigh</code> (with ordinal 73) */
    POSTERIOR_LEFT_DISTAL_THIGH("posteriorLeftDistalThigh", 73),
    /** <code>posteriorLeftKnee</code> (with ordinal 74) */
    POSTERIOR_LEFT_KNEE("posteriorLeftKnee", 74),
    /** <code>posteriorLeftProximalLowerLeg</code> (with ordinal 75) */
    POSTERIOR_LEFT_PROXIMAL_LOWER_LEG("posteriorLeftProximalLowerLeg", 75),
    /** <code>posteriorLeftMiddleLowerLeg</code> (with ordinal 76) */
    POSTERIOR_LEFT_MIDDLE_LOWER_LEG("posteriorLeftMiddleLowerLeg", 76),
    /** <code>posteriorLeftDistalLowerLeg</code> (with ordinal 77) */
    POSTERIOR_LEFT_DISTAL_LOWER_LEG("posteriorLeftDistalLowerLeg", 77),
    /** <code>posteriorLeftAnkle</code> (with ordinal 78) */
    POSTERIOR_LEFT_ANKLE("posteriorLeftAnkle", 78),
    /** <code>posteriorLeftHeel</code> (with ordinal 79) */
    POSTERIOR_LEFT_HEEL("posteriorLeftHeel", 79),
    /** <code>posteriorRightUpperBack</code> (with ordinal 80) */
    POSTERIOR_RIGHT_UPPER_BACK("posteriorRightUpperBack", 80),
    /** <code>posteriorRightMiddleBack</code> (with ordinal 81) */
    POSTERIOR_RIGHT_MIDDLE_BACK("posteriorRightMiddleBack", 81),
    /** <code>posteriorRightLowerBack</code> (with ordinal 82) */
    POSTERIOR_RIGHT_LOWER_BACK("posteriorRightLowerBack", 82),
    /** <code>posteriorRightButtock</code> (with ordinal 83) */
    POSTERIOR_RIGHT_BUTTOCK("posteriorRightButtock", 83),
    /** <code>posteriorRightShoulder</code> (with ordinal 84) */
    POSTERIOR_RIGHT_SHOULDER("posteriorRightShoulder", 84),
    /** <code>posteriorRightBicep</code> (with ordinal 85) */
    POSTERIOR_RIGHT_BICEP("posteriorRightBicep", 85),
    /** <code>posteriorRightElbow</code> (with ordinal 86) */
    POSTERIOR_RIGHT_ELBOW("posteriorRightElbow", 86),
    /** <code>posteriorRightProximalForearm</code> (with ordinal 87) */
    POSTERIOR_RIGHT_PROXIMAL_FOREARM("posteriorRightProximalForearm", 87),
    /** <code>posteriorRightMiddleForearm</code> (with ordinal 88) */
    POSTERIOR_RIGHT_MIDDLE_FOREARM("posteriorRightMiddleForearm", 88),
    /** <code>posteriorRightDistalForearm</code> (with ordinal 89) */
    POSTERIOR_RIGHT_DISTAL_FOREARM("posteriorRightDistalForearm", 89),
    /** <code>posteriorRightWrist</code> (with ordinal 90) */
    POSTERIOR_RIGHT_WRIST("posteriorRightWrist", 90),
    /** <code>posteriorRightHand</code> (with ordinal 91) */
    POSTERIOR_RIGHT_HAND("posteriorRightHand", 91),
    /** <code>posteriorRightFingers</code> (with ordinal 92) */
    POSTERIOR_RIGHT_FINGERS("posteriorRightFingers", 92),
    /** <code>posteriorRightProximalThigh</code> (with ordinal 93) */
    POSTERIOR_RIGHT_PROXIMAL_THIGH("posteriorRightProximalThigh", 93),
    /** <code>posteriorRightMiddleThigh</code> (with ordinal 94) */
    POSTERIOR_RIGHT_MIDDLE_THIGH("posteriorRightMiddleThigh", 94),
    /** <code>posteriorRightDistalThigh</code> (with ordinal 95) */
    POSTERIOR_RIGHT_DISTAL_THIGH("posteriorRightDistalThigh", 95),
    /** <code>posteriorRightKnee</code> (with ordinal 96) */
    POSTERIOR_RIGHT_KNEE("posteriorRightKnee", 96),
    /** <code>posteriorRightProximalLowerLeg</code> (with ordinal 97) */
    POSTERIOR_RIGHT_PROXIMAL_LOWER_LEG("posteriorRightProximalLowerLeg", 97),
    /** <code>posteriorRightMiddleLowerLeg</code> (with ordinal 98) */
    POSTERIOR_RIGHT_MIDDLE_LOWER_LEG("posteriorRightMiddleLowerLeg", 98),
    /** <code>posteriorRightDistalLowerLeg</code> (with ordinal 99) */
    POSTERIOR_RIGHT_DISTAL_LOWER_LEG("posteriorRightDistalLowerLeg", 99),
    /** <code>posteriorRightAnkle</code> (with ordinal 100) */
    POSTERIOR_RIGHT_ANKLE("posteriorRightAnkle", 100),
    /** <code>posteriorRightHeel</code> (with ordinal 101) */
    POSTERIOR_RIGHT_HEEL("posteriorRightHeel", 101);

    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;

    private BodyLocationFine(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return ordinal;
    }

    public String getName() {
        return name;
    }

    /**
     * Find the enum with the specified ordinal.
     *
     * @param ordinal ordinal of the enum to find
     *
     * @return the enum with the specified <code>ordinal</code>, or <code>null</code> if not found
     */
    public static BodyLocationFine find(long ordinal) {
        for (BodyLocationFine value : values()) {
            if (value.getOrdinal() == ordinal) {
                return value;
            }
        }
        return null;
    }

    /**
     * Find the enum with the specified name.
     *
     * @param name name of the enum to find
     *
     * @return the enum with the specified <code>name</code>, or <code>null</code> if not found
     */
    public static BodyLocationFine find(String name) {
        for (BodyLocationFine value : values()) {
            if (value.getName().equals(name)) {
                return value;
            }
        }
        return null;
    }
}
