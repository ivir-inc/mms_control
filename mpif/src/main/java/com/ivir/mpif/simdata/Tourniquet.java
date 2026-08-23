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

public class Tourniquet implements Comparable<Tourniquet>, Serializable {
    @Serial
    private static final long serialVersionUID = -904236575196800313L;

    public String type = "";
    public String time = "";

    public String getType() {
        return type;
    }

    public Tourniquet setType(String type) {
        this.type = type;
        return this;
    }

    public String getTime() {
        return time;
    }

    public Tourniquet setTime(String time) {
        this.time = time;
        return this;
    }

    @Override
        public int compareTo(Tourniquet other) {
            if (this.time == null && other.time == null) {
                if (this.type == null && other.type == null) return 0;
                if (this.type == null) return -1;
                if (other.type == null) return 1;
                return this.type.compareTo(other.type);
            }
            if (this.time == null) return -1;
            if (other.time == null) return 1;
            int timeCompare = this.time.compareTo(other.time);
            if (timeCompare != 0) return timeCompare;
            if (this.type == null && other.type == null) return 0;
            if (this.type == null) return -1;
            if (other.type == null) return 1;
            return this.type.compareTo(other.type);
        }
}
