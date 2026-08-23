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

import java.util.ArrayList;
import java.util.Optional;

public class LabPanelSimDataService extends ConcurrentDataStorage<LabPanel, LabPanel.Attributes>{
    public LabPanelSimDataService(){
        super(LabPanel.class);
    }

    public void addLabPanel(LabPanel labPanel){
        if(labPanel.getInstanceName() == null){
            labPanel.setInstanceName("MPIF-LAB: " + labPanel.getAutoId());
        }
        super.add(labPanel);
    }

    public void putLabPanel(LabPanel labPanel) {
        super.put(labPanel);
    }

    public Optional<LabPanel> getLabPanelByInstanceName(String instanceName){
        return getFirstOrNull(super.searchByAttribute(LabPanel.Attributes.INSTANCE_NAME_STR,instanceName));
    }

    private Optional<LabPanel> getFirstOrNull(ArrayList<LabPanel> returnList){
        if(returnList.isEmpty()){
            return Optional.empty();
        }else{
            return Optional.ofNullable(returnList.get(0));
        }
    }


    public ArrayList<LabPanel> getAllLabPanel(){
        return new ArrayList<LabPanel>(super.getAll());
    }
}
