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

package com.ivir.mpif.dataws.model;

public class FederationControlWs {
    private Long id;
    private String command;
    private String parameter;
    private Long time;
    private Boolean local;

    public Long getId() {
        return id;
    }

    public FederationControlWs setId(Long id) {
        this.id = id;
        return this;
    }

    public String getCommand() {
        return command;
    }

    public FederationControlWs setCommand(String command) {
        this.command = command;
        return this;
    }

    public String getParameter() {
        return parameter;
    }

    public FederationControlWs setParameter(String parameter) {
        this.parameter = parameter;
        return this;
    }

    public Long getTime() {
        return time;
    }

    public FederationControlWs setTime(Long time) {
        this.time = time;
        return this;
    }

    public Boolean getLocal() {
        return local;
    }

    public FederationControlWs setLocal(Boolean local) {
        this.local = local;
        return this;
    }
}
