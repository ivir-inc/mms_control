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

import com.ivir.mpif.controller.model.PatternOptions;
import com.ivir.mpif.controller.model.PatternOptionItem;
import com.ivir.mpif.controller.model.RestUiVitalsPatterns;
import com.ivir.mpif.controller.model.VitalsPatternUtils;
import com.ivir.mpif.trumonitor.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TruMonitorController {

    @GetMapping("/mms/truMonitor/vitals/pattern/options")
    public Object getOptions(){
        PatternOptions options = new PatternOptions();
        PatternOptionItem optionArray[] = new PatternOptionItem[EcgPattern.values().length];
        int index = 0;
        for(EcgPattern ecg : EcgPattern.values()) {
            optionArray[index] = new PatternOptionItem(ecg.getTypeValue(), ecg.getTypeName());
            index ++;
        }
        options.setEkg(optionArray);

        optionArray = new PatternOptionItem[BpPattern.values().length];
        index = 0;
        for(BpPattern bp : BpPattern.values()) {
            optionArray[index] = new PatternOptionItem(bp.getTypeValue(), bp.getTypeName());
            index ++;
        }
        options.setBp(optionArray);

        optionArray = new PatternOptionItem[Spo2Pattern.values().length];
        index = 0;
        for(Spo2Pattern spo2 : Spo2Pattern.values()) {
            optionArray[index] = new PatternOptionItem(spo2.getTypeValue(), spo2.getTypeName());
            index ++;
        }
        options.setSpo2(optionArray);

        optionArray = new PatternOptionItem[Etco2Pattern.values().length];
        index = 0;
        for(Etco2Pattern etco2 : Etco2Pattern.values()) {
            optionArray[index] = new PatternOptionItem(etco2.getTypeValue(), etco2.getTypeName());
            index ++;
        }
        options.setEtco2(optionArray);

        return options;
    }

    @GetMapping("/mms/truMonitor/vitals/pattern")
    public Object getPatterns(){
        VitalsPatterns patterns = getVitalsPatterns();
        RestUiVitalsPatterns restPatterns = VitalsPatternUtils.toRestUiVitalsPatterns(patterns);
        return restPatterns;

    }

    private VitalsPatterns getVitalsPatterns() {
        VitalsPatterns vitalsPatterns = new VitalsPatterns();
        vitalsPatterns.setEcgPattern(EcgPattern.NORMAL_SINUS);
        vitalsPatterns.setBpPattern(BpPattern.NORMAL);
        vitalsPatterns.setSpo2Pattern(Spo2Pattern.NORMAL);
        vitalsPatterns.setEtco2Pattern(Etco2Pattern.NORMAL);

        return vitalsPatterns;
    }

    @GetMapping("/mms/truMonitor/vitals/visibility")
    public Object getCurrentVisibilities(){
        return createCurrentVisibilities();
    }

    @PostMapping("/mms/truMonitor/note")
    public Object sendNote(){
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    private VitalsVisibility createCurrentVisibilities() {
        VitalsVisibility visibility = new VitalsVisibility();
            visibility.setBp(false);
            visibility.setEkg(false);
            visibility.setEtco2(false);
            visibility.setRr(false);
            visibility.setSpo2(false);
            visibility.setTemp(false);
        return visibility;
    }
}
