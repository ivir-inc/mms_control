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

public class MpifInfoSimDataService extends DataStorage<MpifInfo>{

    public MpifInfo getMyMpifInfo(){
        return this.get(MpifInfo.localInstanceName);
    }

    public void addMyMpifInfo(MpifInfo mpifInfo){
        mpifInfo.setInstanceName(MpifInfo.localInstanceName);
        this.add(mpifInfo);
    }

    public MpifInfo getByInstanceName(String instanceName){
        return this.get(instanceName);
    }

    public void addMpifInfo(MpifInfo mpifInfo){
        this.add(mpifInfo);
    }

    public void clear(){
        this.clearAll();
    }
}
