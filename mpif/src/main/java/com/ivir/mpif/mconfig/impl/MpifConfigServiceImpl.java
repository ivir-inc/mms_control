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

package com.ivir.mpif.mconfig.impl;

import com.ivir.mpif.db.MpifConfigProperties;
import com.ivir.mpif.db.MpifConfigPropertiesRepository;
import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class MpifConfigServiceImpl implements MpifConfigService {
    private static Logger logger = LoggerFactory.getLogger(MpifConfigServiceImpl.class);
    @Autowired
    MpifConfigPropertiesRepository mpifConfigRepo;

    @PostConstruct
    public void init(){
        MpifConfigProperties properties = MpifConfigFileManager.loadProperties();
        mpifConfigRepo.update(properties);
    }

    private String getProperty(String key){
        return mpifConfigRepo.get().getProperty(key);
    }

    private void setProperty(String key, Object value){
        MpifConfigProperties properties = mpifConfigRepo.get();
        properties.setProperty(key,value);
        mpifConfigRepo.update(properties);
    }

    @Override
    public Optional<String> getProperty(MpifConfigKey key) {
        return Optional.ofNullable(getProperty(key.getKeyStr()));
    }

    @Override
    public Optional<Boolean> getPropertyAsBoolean(MpifConfigKey key) {
        return Optional.ofNullable(Boolean.parseBoolean(getProperty(key.getKeyStr())));
    }

    @Override
    public void setProperty(MpifConfigKey key, Object value) {
        setProperty(key.toString(), value);
    }

    @Override
    public int updateChangedProperties(PropertyPair... propertySet) {
        int counter = 0;
        MpifConfigProperties properties = mpifConfigRepo.get();
        for(PropertyPair pair : propertySet){
            if(pair.value() != null){
                String orgValue = properties.getProperty(pair.key().getKeyStr());
                if(orgValue != null){
                    if(!orgValue.equals(pair.value().toString())){
                        counter++;
                        properties.setProperty(pair.key().getKeyStr(), pair.value());
                    }
                }else{
                    counter ++;
                    properties.setProperty(pair.key().getKeyStr(), pair.value());
                }
            }
        }
        if(counter > 0){
            mpifConfigRepo.update(properties);
            MpifConfigFileManager.saveProperties(properties);
        }
        return counter;
    }

}
