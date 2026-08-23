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

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.FederationControl;
import devstudio.generatedcode.HlaInteractionManager;
import devstudio.generatedcode.exceptions.*;
import org.slf4j.LoggerFactory;

public class FederationControlSimDataListenerForFederate implements ConcurrentDataStorageListener<FederationControl> {
    private final org.slf4j.Logger logger = LoggerFactory.getLogger(this.getClass());
    HlaInteractionManager hlaInteractionManager;

    public FederationControlSimDataListenerForFederate(HlaInteractionManager hlaInteractionManager){
        this.hlaInteractionManager = hlaInteractionManager;
    }

    @Override
    public void entityAdded(FederationControl newEntity) {
        if(newEntity.getLocal()){
            switch(newEntity.getCommand()){
                case START -> sendStart();
                case STOP -> sendStop();
                case PAUSE -> sendPause();
                case RESUME -> sendResume();
                case SAVE -> sendSave();
            }
        }
    }

    @Override
    public void entityUpdated(FederationControl entity) {
    //not used
    }

    public void sendStart(){
        try {
            hlaInteractionManager.sendStart();
            logger.trace("Sending start interaction");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send start",ex);
        }
    }

    public void sendStop(){
        try {
            hlaInteractionManager.sendStop();
            logger.trace("Sending stop interaction");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send stop",ex);
        }
    }

    public void sendPause(){
        try {
            hlaInteractionManager.sendPause();
            logger.trace("Sending pause interaction");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send pause",ex);
        }
    }

    public void sendResume(){
        try {
            hlaInteractionManager.sendResume();
            logger.trace("Sending resume interaction");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send resume",ex);
        }
    }

    public void sendSave(){
        try {
            String saveLabel = "save";
            hlaInteractionManager.sendSave(saveLabel);
            logger.trace("Sending save interaction");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send save",ex);
        }
    }

    public void sendRestore(){
        try {
            hlaInteractionManager.sendRestore("save");
        } catch (HlaNotConnectedException | HlaFomException |
                 HlaInternalException | HlaRtiException |
                 HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send restore",ex);
        }
    }

}
