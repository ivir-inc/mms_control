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

package com.ivir.mpif.treatment.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;

public class ScenarioStorage {
    private int idCounter = 0;
    private HashMap<Integer, Scenario> scenarioMap = new HashMap<>();
    
    public void putScenario(Scenario scenario){
        if(scenario.getId() == null){
            scenario.setId(idCounter ++);
        }
        this.scenarioMap.put(scenario.getId(), scenario);
    }
    
    public Scenario getScenario(int id){
        return this.scenarioMap.get(id);
    }
    
    public ArrayList<Scenario> getAllScenarios(){
        return new ArrayList<>(scenarioMap.values());
    }

    public Optional<Integer> getScenarioId(String scenarioName){
        for(Scenario scenario : this.getAllScenarios()){
            if(scenario.getName().equalsIgnoreCase(scenarioName)){
                return Optional.of(scenario.getId());
            }
        }
        return Optional.empty();
    }

    public int size(){
        return this.scenarioMap.size();
    }
    
}
