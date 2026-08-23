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

package com.ivir.mpif.controller.model;

import java.util.List;

public class RestNetworkInterface {

    private String name;
    private String displayName;
    private List<String> ipv4;
    private List<String> ipv6;

    public String getName() { return name; }
    public RestNetworkInterface setName(String name) { this.name = name; return this; }

    public List<String> getIpv4() { return ipv4; }
    public RestNetworkInterface setIpv4(List<String> ipv4) { this.ipv4 = ipv4; return this; }

    public List<String> getIpv6() { return ipv6; }
    public RestNetworkInterface setIpv6(List<String> ipv6) { this.ipv6 = ipv6; return this; }

    public String getDisplayName() {
        return displayName;
    }

    public RestNetworkInterface setDisplayName(String displayName) {
        this.displayName = displayName;
        return this;
    }
}
