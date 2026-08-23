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

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.ivir.mpif.event.oeilog;

import java.util.Date;

/**
 *
 * @author blewa
 */
public class LogEntryHeader {
    private String sessionUniqueId = null;
    private LogType logType = null;
    private Date worldTime = null;
    private Date systemTime = null;
    private Date patientTime = null;

    public String getSessionUniqueId() {
        return sessionUniqueId;
    }

    public LogEntryHeader setSessionUniqueId(String sessionUniqueId) {
        this.sessionUniqueId = sessionUniqueId;
        return this;
    }

    public LogType getLogType() {
        return logType;
    }

    public LogEntryHeader setLogType(LogType logType) {
        this.logType = logType;
        return this;
    }

    public Date getWorldTime() {
        return worldTime;
    }

    public LogEntryHeader setWorldTime(Date worldTime) {
        this.worldTime = worldTime;
        return this;
    }

    public Date getSystemTime() {
        return systemTime;
    }

    public LogEntryHeader setSystemTime(Date systemTime) {
        this.systemTime = systemTime;
        return this;
    }

    public Date getPatientTime() {
        return patientTime;
    }

    public LogEntryHeader setPatientTime(Date patientTime) {
        this.patientTime = patientTime;
        return this;
    }

    @Override
    public String toString() {
        return "LegEntryHeader{" + "sessionUniqueId=" + sessionUniqueId + ", logType=" + logType + ", worldTime=" + worldTime + ", systemTime=" + systemTime + ", patientTime=" + patientTime + '}';
    }
}
