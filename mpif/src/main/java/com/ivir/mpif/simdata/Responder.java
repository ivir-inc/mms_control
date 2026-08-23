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

public class Responder implements Comparable<Responder>, Serializable {
    @Serial
    private static final long serialVersionUID = 807544249284854173L;

    private String lastName = "";
    private String firstName = "";
    private String trainingLevel = "";
    private String socialSecurityAccountNumber = "";

    public String getLastName() {
        return lastName;
    }

    public Responder setLastName(String lastName) {
        this.lastName = lastName;
        return this;
    }

    public String getFirstName() {
        return firstName;
    }

    public Responder setFirstName(String firstName) {
        this.firstName = firstName;
        return this;
    }

    public String getTrainingLevel() {
        return trainingLevel;
    }

    public Responder setTrainingLevel(String trainingLevel) {
        this.trainingLevel = trainingLevel;
        return this;
    }

    public String getSocialSecurityAccountNumber() {
        return socialSecurityAccountNumber;
    }

    public Responder setSocialSecurityAccountNumber(String socialSecurityAccountNumber) {
        this.socialSecurityAccountNumber = socialSecurityAccountNumber;
        return this;
    }

    @Override
        public int compareTo(Responder other) {
            int cmp = this.lastName.compareTo(other.lastName);
            if (cmp != 0) return cmp;
            cmp = this.firstName.compareTo(other.firstName);
            if (cmp != 0) return cmp;
            cmp = this.trainingLevel.compareTo(other.trainingLevel);
            if (cmp != 0) return cmp;
            return this.socialSecurityAccountNumber.compareTo(other.socialSecurityAccountNumber);
        }
}
