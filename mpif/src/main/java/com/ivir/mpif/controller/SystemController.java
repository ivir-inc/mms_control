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

package com.ivir.mpif.controller;

import com.ivir.mpif.controller.model.RestNetworkInterface;
import com.ivir.mpif.system.NetworkService;
import com.ivir.mpif.system.QrService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/mms/system")
public class SystemController {

    private final QrService qrService;
    private final NetworkService networkService;

    public SystemController(QrService qrService, NetworkService networkService) {
        this.qrService = qrService;
        this.networkService = networkService;
    }

    @GetMapping(value = "/qr", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> getQrCode() {
        return qrService.getQrPng()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping(value = "/preferredUrl", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> getPreferredUrl() {
        return qrService.resolveUrl()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/network")
    public ResponseEntity<List<RestNetworkInterface>> getNetworkInterfaces() {
        return ResponseEntity.ok(networkService.getNetworkInterfaces());
    }

    @GetMapping(value = "/network/endpointMask", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> getEndpointMask() {
        String mask =  networkService.getEndpointMask();
        if((mask == null) || mask.isEmpty()){
            mask = "<no mask>";
        }
        return ResponseEntity.ok(mask);
    }

    @PutMapping(value = "/network/endpointMask", consumes = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<Void> updateEndpointMask(@RequestBody String mask) {
        if(mask != null && !mask.isEmpty()){
            if(mask.trim().equalsIgnoreCase("<no mask>")){
                mask = "";
            }
        }
        networkService.updateEndpointMask(mask);
        return ResponseEntity.ok().build();
    }
}
