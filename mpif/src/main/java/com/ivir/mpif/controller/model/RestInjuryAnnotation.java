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

package com.ivir.mpif.controller.model;

import com.ivir.mpif.simdata.ComparableList;
import com.ivir.mpif.simdata.InjuryLocation;
import com.ivir.mpif.simdata.Tourniquet;

import java.util.ArrayList;
import java.util.List;

public class RestInjuryAnnotation {
    private Tourniquet rightArmTourniquet = new Tourniquet();
    private Tourniquet leftArmTourniquet = new Tourniquet();
    private Tourniquet rightLegTourniquet = new Tourniquet();
    private Tourniquet leftLegTourniquet = new Tourniquet();
    private List<RestInjuryLocation> annotationList = new ArrayList<>();

    public Tourniquet getRightArmTourniquet() {
        return rightArmTourniquet;
    }

    public RestInjuryAnnotation setRightArmTourniquet(Tourniquet rightArmTourniquet) {
        this.rightArmTourniquet = rightArmTourniquet;
        return this;
    }

    public Tourniquet getLeftArmTourniquet() {
        return leftArmTourniquet;
    }

    public RestInjuryAnnotation setLeftArmTourniquet(Tourniquet leftArmTourniquet) {
        this.leftArmTourniquet = leftArmTourniquet;
        return this;
    }

    public Tourniquet getRightLegTourniquet() {
        return rightLegTourniquet;
    }

    public RestInjuryAnnotation setRightLegTourniquet(Tourniquet rightLegTourniquet) {
        this.rightLegTourniquet = rightLegTourniquet;
        return this;
    }

    public Tourniquet getLeftLegTourniquet() {
        return leftLegTourniquet;
    }

    public RestInjuryAnnotation setLeftLegTourniquet(Tourniquet leftLegTourniquet) {
        this.leftLegTourniquet = leftLegTourniquet;
        return this;
    }

    public List<RestInjuryLocation> getAnnotationList() {
        return annotationList;
    }

    public RestInjuryAnnotation setAnnotationList(List<RestInjuryLocation> annotationList) {
        this.annotationList = annotationList;
        return this;
    }
}
