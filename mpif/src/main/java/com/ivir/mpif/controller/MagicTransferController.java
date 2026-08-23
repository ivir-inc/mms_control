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

import com.ivir.mpif.controller.model.RestMagicTransfer;
import com.ivir.mpif.simdata.MagicTransfer;
import com.ivir.mpif.simdata.MagicTransferSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mms/magicTransfer")
public class MagicTransferController {
    @Autowired
    private MagicTransferSimDataService magicTransferSimDataService;

    @GetMapping("/all")
    public ResponseEntity<?> getAllMagicTransfers() {
        var magicTransfers = magicTransferSimDataService.getAll();
        if (magicTransfers.isEmpty()) {
            return ResponseEntity.ok("No Magic Transfers found.");
        }
        return ResponseEntity.ok(magicTransfers.stream().map(this::toRestMagicTransfer).toList());
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> createMagicTransfer(@RequestBody RestMagicTransfer restMagicTransfer) {
        if (restMagicTransfer == null || restMagicTransfer.getPatientId() == null || restMagicTransfer.getPatientId().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("MagicTransfer data must be provided with a valid Patient ID.");
        }

        MagicTransfer magicTransfer = new MagicTransfer()
                .setPatientId(restMagicTransfer.getPatientId())
                .setFacilityId(restMagicTransfer.getFacilityId())
                .setLocal(true);

        magicTransferSimDataService.put(magicTransfer);
        return ResponseEntity.ok(toRestMagicTransfer(magicTransfer));
    }

    private RestMagicTransfer toRestMagicTransfer(MagicTransfer magicTransfer) {
        return new RestMagicTransfer()
                .setPatientId(magicTransfer.getPatientId())
                .setFacilityId(magicTransfer.getFacilityId())
                .setLocal(magicTransfer.isLocal());
    }
}
