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

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.ivir.mpif.event.oeilog;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author blewa
 */
public class OeiLogParser {
    private final SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private final SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
    private ObjectMapper mapper = null;
    private int logEntrySize = 0;
    private int currentNodeIndex = -1;
    private Iterator<JsonNode> logItemIterator = null;
    private JsonNode currentNode = null;
    private Logger logger = Logger.getGlobal();
    

    private OeiLogParser(String logData) {
        //setting this to ensure there is not padding added to the times for 
        //local timezone
        timeFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        
        logData = cleanUpJson(logData);
        startParser(logData);
        if(logEntrySize > 0){
            next();
        }
    }

    public static OeiLogParser parseLog(String logData) {
        if (logData == null) {
            return null;
        }

        return new OeiLogParser(logData);
    }

    private void startParser(String data) {
        mapper = new ObjectMapper();

        try {
            JsonNode node = mapper.readTree(data);
            logEntrySize = node.size();
            logItemIterator = node.elements();
        } catch (JsonProcessingException ex) {
            logger.log(Level.SEVERE, null, ex);
        }
    }

    /**
     * OEI logs are not JSON compliant.  It needs to be fixed before it is parsed
     * 
     * We need to turn:
     * {
     *    "": { },
     *    "": { }, 
     * }
     * 
     * Into:
     * [
     *    { },
     *    { },
     * ]
     *
     * @param data
     */
    private String cleanUpJson(String data) {
        data = data.replaceFirst("\\{", "[");
        data = replaceLast(data,"}","]");
        data = data.replaceAll("\\\"\\\"\\:", "");
        return data;
    }

    private String replaceLast(String string, String toReplace, String replacement) {
        int pos = string.lastIndexOf(toReplace);
        if (pos > -1) {
            return string.substring(0, pos)
                    + replacement
                    + string.substring(pos + toReplace.length());
        } else {
            return string;
        }
    }
    
    public int getSize(){
        return this.logEntrySize;
    }
    
    /**
     * moves to the next log entry.  If the parser is already at the last entry
     * then it will move and return false.  NOTE:  if there are no more entries,
     * the it will stay at the last entry (and return false).
     * @return true if moved to the next entry.  false if it could not (end of log)
     */
    public boolean next() {
        if (this.logItemIterator.hasNext()) {
            this.currentNode = this.logItemIterator.next();
            this.currentNodeIndex ++;
            return true;
        }
        return false;
    }
    
    /**
     * returns the index of the log entry. 
     * the first position is 0.  If there are not log entries, then this will
     * return -1
     * 
     * @return position of the log or -1 if log is empty 
     */
    public int getCurrentIndex(){
        return this.currentNodeIndex;
    }
    
    public LogEntryHeader getEntryHeader(){
        LogEntryHeader logEntryHeader = new LogEntryHeader();
        logEntryHeader.setSessionUniqueId(this.currentNode.get("sessionUniqueId").asText());
        logEntryHeader.setLogType(LogType.getByLogTypeNum(this.currentNode.get("logType").asInt()));
        try {
            logEntryHeader.setWorldTime(this.dateTimeFormatter.parse(this.currentNode.get("worldTime").asText()));
            logEntryHeader.setSystemTime(this.timeFormatter.parse(this.currentNode.get("systemTime").asText()));
            logEntryHeader.setPatientTime(this.timeFormatter.parse(this.currentNode.get("patientTime").asText()));
        } catch (ParseException ex) {
            Logger.getLogger(OeiLogParser.class.getName()).log(Level.SEVERE, null, ex);
        }
       
        return logEntryHeader;
    }
    
    public SimulationStateMessage getSimulationStateMessage(){
        JsonNode messageNode = this.currentNode.get("message");
        SimulationStateMessage returnMessage = new SimulationStateMessage().setState(StateValue.FAILED);
        String stateStr = messageNode.get("State").textValue();
        if(stateStr.equalsIgnoreCase("Successful")){
           returnMessage.setState(StateValue.SUCCESSFUL);
        }else{
            logger.log(Level.WARNING, "got unkown simulation state: {0} setting to FAILED", stateStr);
        }
        
        return returnMessage;
    }
    
    /**
     *     "Parameters": [
     *          {
     *              "Name": "HR",
     *              "Value": "108"
     *          }
     *      ],
     *      "ProfileUniqueId": "PAT_JOHN_DOE-8E7F912C"
     *
     * @return 
     */
    public SimulationParamMessage getSimulationParamMessage(){
        JsonNode messageNode = this.currentNode.get("message");
        JsonNode paramNodeListNode = messageNode.get("Parameters");
        if(paramNodeListNode.elements().hasNext()){
            //there should be 1 element
            JsonNode paramElement = paramNodeListNode.elements().next();
            JsonNode nameNode = paramElement.get("Name");
            ParamType paramType = ParamType.oeiNameToParamType(nameNode.asText());
            if(paramType == null){
                logger.log(Level.WARNING, "ParameterMessage has unknown name value: {0}", nameNode.asText());
                return null;
            }else{
                SimulationParamMessage message = new SimulationParamMessage();
                message.setParamType(paramType);
                JsonNode valueNode = paramElement.get("Value");
                message.setValue(paramType.getParamValueMapper().oeiStringValueToFloat(valueNode.textValue()));
               return message;
            }
        }
        logger.log(Level.WARNING,"Message contained no parameter");
        return null;
    }
}
