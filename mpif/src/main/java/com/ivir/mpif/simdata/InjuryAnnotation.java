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

import java.io.Serial;
import java.io.Serializable;

public class InjuryAnnotation implements Comparable<InjuryAnnotation>, Serializable {
    @Serial
    private static final long serialVersionUID = -6217186081136317514L;

    private Tourniquet rightArmTourniquet = new Tourniquet();
    private Tourniquet leftArmTourniquet = new Tourniquet();
    private Tourniquet rightLegTourniquet = new Tourniquet();
    private Tourniquet leftLegTourniquet = new Tourniquet();
    private ComparableList<InjuryLocation> annotationList = new ComparableList<>();

    public Tourniquet getRightArmTourniquet() {
        return rightArmTourniquet;
    }

    public InjuryAnnotation setRightArmTourniquet(Tourniquet rightArmTourniquet) {
        this.rightArmTourniquet = rightArmTourniquet;
        return this;
    }

    public Tourniquet getLeftArmTourniquet() {
        return leftArmTourniquet;
    }

    public InjuryAnnotation setLeftArmTourniquet(Tourniquet leftArmTourniquet) {
        this.leftArmTourniquet = leftArmTourniquet;
        return this;
    }

    public Tourniquet getRightLegTourniquet() {
        return rightLegTourniquet;
    }

    public InjuryAnnotation setRightLegTourniquet(Tourniquet rightLegTourniquet) {
        this.rightLegTourniquet = rightLegTourniquet;
        return this;
    }

    public Tourniquet getLeftLegTourniquet() {
        return leftLegTourniquet;
    }

    public InjuryAnnotation setLeftLegTourniquet(Tourniquet leftLegTourniquet) {
        this.leftLegTourniquet = leftLegTourniquet;
        return this;
    }

    public ComparableList<InjuryLocation> getAnnotationList() {
        return annotationList;
    }

    public InjuryAnnotation setAnnotationList(ComparableList<InjuryLocation> annotationList) {
        this.annotationList = annotationList;
        return this;
    }

    @Override
    public int compareTo(InjuryAnnotation other) {
        int cmp;
        cmp = this.rightArmTourniquet.compareTo(other.rightArmTourniquet);
        if (cmp != 0) return cmp;
        cmp = this.leftArmTourniquet.compareTo(other.leftArmTourniquet);
        if (cmp != 0) return cmp;
        cmp = this.rightLegTourniquet.compareTo(other.rightLegTourniquet);
        if (cmp != 0) return cmp;
        cmp = this.leftLegTourniquet.compareTo(other.leftLegTourniquet);
        if (cmp != 0) return cmp;
        cmp = this.annotationList.compareTo(other.annotationList);
        if (cmp != 0) return cmp;
        return 0;
    }
}
