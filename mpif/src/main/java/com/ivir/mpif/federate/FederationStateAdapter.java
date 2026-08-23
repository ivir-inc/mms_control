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

import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import devstudio.generatedcode.HlaFederationState;
import devstudio.generatedcode.HlaFederationStateManager;
import devstudio.generatedcode.HlaFederationStateUpdater;
import devstudio.generatedcode.HlaWorld;
import devstudio.generatedcode.datatypes.FederationStateEnum;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class FederationStateAdapter implements MmsFederateInitializationListener{
	private static Logger logger = LoggerFactory.getLogger(FederationStateAdapter.class);
	@Autowired
	MpifConfigService mpifConfigService;

	private boolean activeManager = false;
	private HlaFederationStateManager hlaFederationStateManager;
	private HlaFederationState hlaFederationState = null;
	private String internalFedState = "Unknown";
	private MmsFederate mmsFederate;

	@Override
	public void initializing(MmsFederate mmsFederate) {
		this.mmsFederate = mmsFederate;
		hlaFederationStateManager = mmsFederate.getHlaWorld().getHlaFederationStateManager();
		mpifConfigService.getPropertyAsBoolean(MpifConfigKey.OWNS_FEDERATION_STATE).ifPresent(this::setActiveManager);
	}

	public void setActiveManager(boolean active) {
		this.activeManager = active;
		logger.info("FederationStateAdapter active: {}",active);
	}
	
	public void updateFederationState(FederationStateEnum newState) {
		if(!this.activeManager) {
			return;
		}
		
		try {
			createObjectIfNeeded();
			
			this.internalFedState = newState.toString();
			HlaFederationStateUpdater updater = hlaFederationState.getHlaFederationStateUpdater();
			updater.setState(newState);
			updater.sendUpdate();
		}catch(Exception e) {
			logger.error("failed to update FedeationState",e);
		}
	}
	
	private void createObjectIfNeeded() {
		try {
			if(this.hlaFederationState == null) {
				this.hlaFederationState = hlaFederationStateManager.createLocalHlaFederationState();
			}
		}catch(Exception e) {
			logger.error("could not create federationstate object",e);
		}
	}
	
	public String getInternalFedState() {
		return this.internalFedState;
	}


}
