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

public enum BodyLocationCoarse {
    NOT_APPLICABLE("notApplicable", 0),
    ANTERIOR_HEAD_FACE("anteriorHeadFace", 1),
    ANTERIOR_RIGHT_LATERAL_HEAD_FACE("anteriorRightLateralHeadFace", 2),
    ANTERIOR_LEFT_LATERAL_HEAD_FACE("anteriorLeftLateralHeadFace", 3),
    ANTERIOR_NECK("anteriorNeck", 4),
    ANTERIOR_STERNUM("anteriorSternum", 5),
    ANTERIOR_RIGHT_PELVIS("anteriorRightPelvis", 6),
    ANTERIOR_LEFT_PELVIS("anteriorLeftPelvis", 7),
    ANTERIOR_GENITALS("anteriorGenitals", 8),
    ANTERIOR_RIGHT_UPPER_THORAX("anteriorRightUpperThorax", 9),
    ANTERIOR_RIGHT_LOWER_THORAX("anteriorRightLowerThorax", 10),
    ANTERIOR_LEFT_UPPER_THORAX("anteriorLeftUpperThorax", 11),
    ANTERIOR_LEFT_LOWER_THORAX("anteriorLeftLowerThorax", 12),
    ANTERIOR_ABDOMEN_RIGHT_UPPER_QUADRANT("anteriorAbdomenRightUpperQuadrant", 13),
    ANTERIOR_ABDOMEN_RIGHT_LOWER_QUADRANT("anteriorAbdomenRightLowerQuadrant", 14),
    ANTERIOR_ABDOMEN_LEFT_UPPER_QUADRANT("anteriorAbdomenLeftUpperQuadrant", 15),
    ANTERIOR_ABDOMEN_LEFT_LOWER_QUADRANT("anteriorAbdomenLeftLowerQuadrant", 16),
    ANTERIOR_RIGHT_SHOULDER("anteriorRightShoulder", 17),
    ANTERIOR_RIGHT_UPPER_ARM("anteriorRightUpperArm", 18),
    ANTERIOR_RIGHT_FORE_ARM("anteriorRightForeArm", 19),
    ANTERIOR_RIGHT_WRIST_HAND("anteriorRightWristHand", 20),
    ANTERIOR_RIGHT_THIGH("anteriorRightThigh", 21),
    ANTERIOR_RIGHT_KNEE("anteriorRightKnee", 22),
    ANTERIOR_RIGHT_LOWER_LEG("anteriorRightLowerLeg", 23),
    ANTERIOR_RIGHT_ANKLE_FOOT("anteriorRightAnkleFoot", 24),
    ANTERIOR_LEFT_SHOULDER("anteriorLeftShoulder", 25),
    ANTERIOR_LEFT_UPPER_ARM("anteriorLeftUpperArm", 26),
    ANTERIOR_LEFT_FORE_ARM("anteriorLeftForeArm", 27),
    ANTERIOR_LEFT_WRIST_HAND("anteriorLeftWristHand", 28),
    ANTERIOR_LEFT_THIGH("anteriorLeftThigh", 29),
    ANTERIOR_LEFT_KNEE("anteriorLeftKnee", 30),
    ANTERIOR_LEFT_LOWER_LEG("anteriorLeftLowerLeg", 31),
    ANTERIOR_LEFT_ANKLE_FOOT("anteriorLeftAnkleFoot", 32),
    POSTERIOR_HEAD("posteriorHead", 33),
    POSTERIOR_NECK("posteriorNeck", 34),
    POSTERIOR_UPPER_CERVICAL_SPINE("posteriorUpperCervicalSpine", 35),
    POSTERIOR_MIDDLE_THORACIC_SPINE("posteriorMiddleThoracicSpine", 36),
    POSTERIOR_LOWER_LUMBAR_COCCYX_SPINE("posteriorLowerLumbarCoccyxSpine", 37),
    POSTERIOR_LEFT_BUTTOCKS("posteriorLeftButtocks", 38),
    POSTERIOR_RIGHT_BUTTOCKS("posteriorRightButtocks", 39),
    POSTERIOR_LEFT_UPPER_THORAX("posteriorLeftUpperThorax", 40),
    POSTERIOR_LEFT_LOWER_THORAX("posteriorLeftLowerThorax", 41),
    POSTERIOR_RIGHT_UPPER_THORAX("posteriorRightUpperThorax", 42),
    POSTERIOR_RIGHT_LOWER_THORAX("posteriorRightLowerThorax", 43),
    POSTERIOR_LEFT_FLANK("posteriorLeftFlank", 44),
    POSTERIOR_RIGHT_FLANK("posteriorRightFlank", 45),
    POSTERIOR_LEFT_SHOULDER("posteriorLeftShoulder", 46),
    POSTERIOR_LEFT_UPPER_ARM("posteriorLeftUpperArm", 47),
    POSTERIOR_LEFT_FORE_ARM("posteriorLeftForeArm", 48),
    POSTERIOR_LEFT_WRIST_HAND("posteriorLeftWristHand", 49),
    POSTERIOR_LEFT_THIGH("posteriorLeftThigh", 50),
    POSTERIOR_LEFT_KNEE("posteriorLeftKnee", 51),
    POSTERIOR_LEFT_LOWER_LEG("posteriorLeftLowerLeg", 52),
    POSTERIOR_LEFT_ANKLE_FOOT("posteriorLeftAnkleFoot", 53),
    POSTERIOR_RIGHT_SHOULDER("posteriorRightShoulder", 54),
    POSTERIOR_RIGHT_UPPER_ARM("posteriorRightUpperArm", 55),
    POSTERIOR_RIGHT_FORE_ARM("posteriorRightForeArm", 56),
    POSTERIOR_RIGHT_WRIST_HAND("posteriorRightWristHand", 57),
    POSTERIOR_RIGHT_THIGH("posteriorRightThigh", 58),
    POSTERIOR_RIGHT_KNEE("posteriorRightKnee", 59),
    POSTERIOR_RIGHT_LOWER_LEG("posteriorRightLowerLeg", 60),
    POSTERIOR_RIGHT_ANKLE_FOOT("posteriorRightAnkleFoot", 61);
    
    private String _name = null;
    private int _ordinal = 0;

    private BodyLocationCoarse(String name, int ordinal) {
        _name = name;
        _ordinal = ordinal;
    }

    public String getName() {
        return _name;
    }

    public int getOrdinal() {
        return _ordinal;
    }
}
