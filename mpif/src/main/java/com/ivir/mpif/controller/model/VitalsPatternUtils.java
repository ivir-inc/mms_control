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
import com.ivir.mpif.trumonitor.VitalsPatterns;

public class VitalsPatternUtils {
	
	public static RestUiVitalsPatterns toRestUiVitalsPatterns(VitalsPatterns vPattern) {
		RestUiVitalsPatterns restPatterns = new RestUiVitalsPatterns();
		if(vPattern.getBpPattern() != null)
			restPatterns.setBp(vPattern.getBpPattern().getTypeValue());
		
		if(vPattern.getEcgPattern() != null)
			restPatterns.setEkg(vPattern.getEcgPattern().getTypeValue());
		
		if(vPattern.getSpo2Pattern() != null)
			restPatterns.setSpo2(vPattern.getSpo2Pattern().getTypeValue());
	
		if(vPattern.getEtco2Pattern() != null)
		restPatterns.setEtco2(vPattern.getEtco2Pattern().getTypeValue());
		
		return restPatterns;
	}

}
