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

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ivir.mpif.db.MpifConfigProperties;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class MpifConfigFileManager {
    private static final org.slf4j.Logger logger = LoggerFactory.getLogger(MpifConfigFileManager.class);

    public static MpifConfigProperties loadProperties() {
        Properties properties = new Properties();
		ObjectMapper mapper = new ObjectMapper();
		Map<String,String> fileValues;
		String fileName = "mpif.json";
		try{
			fileValues = mapper.readValue(Paths.get(fileName).toFile(), new TypeReference<Map<String, String>>(){});
		} catch (JsonMappingException e) {
            throw new RuntimeException(e);
        } catch (JsonParseException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

		fileValues.forEach((key,value)->{
			properties.setProperty(key,value);
		});

        return new MpifConfigProperties(properties);
    }

    public static void saveProperties(MpifConfigProperties mpifConfigProperties) {
		String propFileName = "mpif.json";
		Properties properties = mpifConfigProperties.getProperties();
		Map<String,String> fileValues = new HashMap<>();

        properties.forEach((key, value) -> {
            if (!key.toString().startsWith("_")) {
				fileValues.put(key.toString(),value.toString());
            }
        });

		ObjectMapper mapper = new ObjectMapper();
		try {
			mapper.writerWithDefaultPrettyPrinter()
					.writeValue(Paths.get(propFileName).toFile(), fileValues);
		} catch (JsonGenerationException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

    }


}
