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

package com.ivir.mpif.treatment.impl;

import com.ivir.mpif.simdata.PhysicalTreatmentType;
import com.ivir.mpif.simdata.TreatmentDevice;

import java.util.HashMap;
import java.util.HashSet;

import static com.ivir.mpif.simdata.TreatmentDevice.*;
import static com.ivir.mpif.simdata.PhysicalTreatmentType.*;

public class TreatmentDeviceMap {
    private static TreatmentDeviceMap instance = new TreatmentDeviceMap();
    private HashMap<PhysicalTreatmentType, HashSet<TreatmentDevice>> deviceMap = new HashMap<>();

    public static TreatmentDeviceMap getInstance(){
        return instance;
    }

    private TreatmentDeviceMap(){
        put(OPEN_NASAL_AIRWAY, NASOPHARYNGEAL_AIRWAY);
        put(OPEN_TRACHEAL_AIRWAY, OROPHARYNGEAL_AIRWAY, ENDOTRACHEAL_TUBE, LARYNGEAL_TUBE, LARYNGOSCOPE,
                SUPRAGLOTTIC_DEVICE, CRICOTHYROIDOTOMY_KIT);
        put(STOP_HEMORRHAGE, EXTREMITY_TOURNIQUET, JUNCTIONAL_TOURNIQUET, BANDAGE, GAUZE, ENDOVASCULAR_BALLOON);
        put(RELEASE_INTRAPLEURAL_PRESSURE, CHEST_NEEDLE_DECOMPRESSION, CHEST_TUBE);
        put(STABILIZE_ORTHOPEDIC_FRACTURE, SPINE_BOARD, CERVICAL_COLLAR, SPLINT);
        put(IMMOBILIZE_SPINE, SPINE_BOARD, CERVICAL_COLLAR, LITTER);
        put(CLEAN_WOUND, ISOPROPYL_ALCOHOL_PAD, BANDAGE, GAUZE);
        put(SEAL_CHEST_WOUND, OCCLUSIVE_DRESSING, VENTED_OCCLUSIVE_DRESSING);
        put(WARM_PATIENT, MYLAR_BLANKET);
        put(CATHETERIZE, FOLEY_CATHETER);
        put(VENTILATION_MANUAL, OXYGEN_MASK);
        put(BANDAGE_BURN, BANDAGE);
        put(COVER_EYE, EYE_SHIELD);
    }

    private void put(PhysicalTreatmentType treatment, TreatmentDevice ... devices){
        HashSet<TreatmentDevice> deviceSet = new HashSet<>();
        for(TreatmentDevice device : devices){
            deviceSet.add(device);
        }
        deviceMap.put(treatment, deviceSet);
    }

    public HashMap<PhysicalTreatmentType, HashSet<TreatmentDevice>> getDeviceMap(){
        return this.deviceMap;
    }

}
