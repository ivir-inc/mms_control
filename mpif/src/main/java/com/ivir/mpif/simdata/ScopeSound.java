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

import java.util.Date;

public class ScopeSound extends ConcurrentSimData<ScopeSound.Attributes>{

    public enum Attributes{
        IP_ADDRESS,
        LAST_UPDATE,
        SITE_ENUM,
        FILE_ID,
        MUTE,
        FILE_NAME,
        SELECTED_LOCAL
    }

    public ScopeSound(){
        super(Attributes.class, Attributes.IP_ADDRESS);
    }

    public String getIpAddress() {
        return (String) getValue(Attributes.IP_ADDRESS);
    }

    public ScopeSound setIpAddress(String ipAddress) {
        setValue(Attributes.IP_ADDRESS, ipAddress);
        return this;
    }

    public Date getLastUpdate() {
        return (Date) getValue(Attributes.LAST_UPDATE);
    }

    public ScopeSound setLastUpdate(Date lastUpdate) {
        setValue(Attributes.LAST_UPDATE, lastUpdate);
        return this;
    }

    public ScopeSoundSiteEnum getSiteEnum() {
        return (ScopeSoundSiteEnum) getValue(Attributes.SITE_ENUM);
    }

    public ScopeSound setSiteEnum(ScopeSoundSiteEnum site) {
        setValue(Attributes.SITE_ENUM, site);
        return this;
    }

    public String getFileId() {
        return (String) getValue(Attributes.FILE_ID);
    }

    public ScopeSound setFileId(String fileId) {
        setValue(Attributes.FILE_ID, fileId);
        return this;
    }

    public Boolean getMute() {
        return (Boolean) getValue(Attributes.MUTE);
    }

    public ScopeSound setMute(Boolean mute) {
        setValue(Attributes.MUTE, mute);
        return this;
    }    

    public String getFileName() {
        return (String) getValue(Attributes.FILE_NAME);
    }

    public ScopeSound setFileName(String fileName) {
        setValue(Attributes.FILE_NAME, fileName);
        return this;
    }

    public Boolean getSelectedLocal(){
        return (Boolean) getValue(Attributes.SELECTED_LOCAL);
    }

    public ScopeSound setSelectedLocal(Boolean selected){
        setValue(Attributes.SELECTED_LOCAL, selected);
        return this;
    }
}
