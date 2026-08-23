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

public class TreatmentFluid implements Comparable<TreatmentFluid>, Serializable {
   @Serial
    private static final long serialVersionUID = 7776058134236934300L;

    private String name = "";
    private Integer volume = 0;
    private String route = "";
    private String time = "";

    public String getName() {
        return name;
    }

    public TreatmentFluid setName(String name) {
        this.name = name;
        return this;
    }

    public Integer getVolume() {
        return volume;
    }

    public TreatmentFluid setVolume(Integer volume) {
        this.volume = volume;
        return this;
    }

    public String getRoute() {
        return route;
    }

    public TreatmentFluid setRoute(String route) {
        this.route = route;
        return this;
    }

    public String getTime() {
        return time;
    }

    public TreatmentFluid setTime(String time) {
        this.time = time;
        return this;
    }

    @Override
        public int compareTo(TreatmentFluid other) {
            int result = this.name.compareTo(other.name);
            if (result != 0) return result;
            result = this.volume.compareTo(other.volume);
            if (result != 0) return result;
            result = this.route.compareTo(other.route);
            if (result != 0) return result;
            return this.time.compareTo(other.time);
        }
}
