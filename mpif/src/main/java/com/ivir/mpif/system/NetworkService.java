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

package com.ivir.mpif.system;

import com.ivir.mpif.controller.model.RestNetworkInterface;
import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import org.springframework.stereotype.Service;

import java.net.Inet4Address;
import java.net.Inet6Address;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
public class NetworkService {

    private final MpifConfigService mpifConfigService;

    public NetworkService(MpifConfigService mpifConfigService) {
        this.mpifConfigService = mpifConfigService;
    }

    public String getEndpointMask() {
        return mpifConfigService.getProperty(MpifConfigKey.ENDPOINT_MASK).orElse("");
    }

    public void updateEndpointMask(String mask) {
        String trimmed = mask == null ? "" : mask.trim();
        validateMask(trimmed);
        String current = getEndpointMask();
        if (!trimmed.equals(current)) {
            mpifConfigService.updateChangedProperties(new MpifConfigService.PropertyPair(MpifConfigKey.ENDPOINT_MASK, trimmed));
        }
    }

    private void validateMask(String mask) {
        if (mask.isEmpty()) {
            throw new IllegalArgumentException("Endpoint mask must not be blank");
        }
        String[] parts = mask.split("\\.", -1);
        if (parts.length > 4) {
            throw new IllegalArgumentException("Endpoint mask must not have more than 4 octets");
        }
        for (String part : parts) {
            int value;
            try {
                value = Integer.parseInt(part);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Endpoint mask octet is not numeric: " + part);
            }
            if (value < 0 || value > 255) {
                throw new IllegalArgumentException("Endpoint mask octet out of range (0-255): " + value);
            }
        }
    }

    public Optional<String> resolveIpForMask() {
        List<RestNetworkInterface> interfaces = getNetworkInterfaces();
        if (interfaces.isEmpty()) return Optional.empty();

        String mask = getEndpointMask();
        if (mask.isEmpty()) {
            return interfaces.get(0).getIpv4().stream().findFirst();
        }

        for (RestNetworkInterface iface : interfaces) {
            for (String ip : iface.getIpv4()) {
                if (ip.startsWith(mask)) return Optional.of(ip);
            }
        }
        return Optional.empty();
    }

    public List<RestNetworkInterface> getNetworkInterfaces() {
        List<RestNetworkInterface> result = new ArrayList<>();
        try {
            for (NetworkInterface iface : Collections.list(NetworkInterface.getNetworkInterfaces())) {
                if (iface.isLoopback() || !iface.isUp()) continue;
                List<String> ipv4 = new ArrayList<>();
                List<String> ipv6 = new ArrayList<>();

                Collections.list(iface.getInetAddresses()).forEach(addr -> {
                    if (addr instanceof Inet4Address) {
                        ipv4.add(addr.getHostAddress());
                    } else if (addr instanceof Inet6Address) {
                        String raw = addr.getHostAddress();
                        //stripping out zoneid
                        int zoneIdx = raw.indexOf('%');
                        ipv6.add(zoneIdx >= 0 ? raw.substring(0, zoneIdx) : raw);
                    }
                });

                if (ipv4.isEmpty() && ipv6.isEmpty()) continue;

                result.add(new RestNetworkInterface()
                        .setDisplayName(iface.getDisplayName())
                        .setName(iface.getName())
                        .setIpv4(ipv4)
                        .setIpv6(ipv6));
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to enumerate network interfaces", e);
        }
        return result;
    }
}
