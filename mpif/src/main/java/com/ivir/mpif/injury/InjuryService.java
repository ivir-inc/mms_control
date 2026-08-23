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

package com.ivir.mpif.injury;

import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.Injury;

import java.util.List;
import java.util.Optional;

public interface InjuryService {
    /**
     * "applys" the injury by preparing the object for being published and then adding it to the simdata
     * @param injury injury to apply
     * @return prepared injury
     */
    Injury apply(Injury injury);

    /**
     * add injury to simdata
     * @param injury
     */
    void add(Injury injury);

    /**
     * update injury to simdata
     * @param injury
     */
    void update(Injury injury);

    Optional<Injury> getByAutoId(String autoId);

    List<Injury> getByPatientId(String patientId);

    List<Injury> getAll();

    void addInjuryListener(ConcurrentDataStorageListener<Injury> listener);
}
