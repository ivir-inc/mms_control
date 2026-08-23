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

package com.ivir.mpif.dataws;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.ConcurrentWebSocketSessionDecorator;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CopyOnWriteArrayList;

public class DataWebSocketHandler extends TextWebSocketHandler{
    private static final Logger logger = LoggerFactory.getLogger(DataWebSocketHandler.class);
    List<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
    List<DataWebSocketStatusListener> statusListeners = new ArrayList<>();
    private ObjectMapper objectMapper;

    private static final int SEND_BUFFER_SIZE = 1024 * 1024; // 1MB
    private static final int SEND_TIME_LIMIT_MS = 10000; // 10 seconds

    public DataWebSocketHandler(){
        objectMapper = new ObjectMapper();
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message)
            throws InterruptedException, IOException {
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        WebSocketSession safeSession = new ConcurrentWebSocketSessionDecorator(
            session,
            SEND_TIME_LIMIT_MS,
            SEND_BUFFER_SIZE
        );
        sessions.add(safeSession);
        for(DataWebSocketStatusListener listener : statusListeners){
            listener.webSocketConnected(safeSession);
        }
    }

    public void addStatusListener(DataWebSocketStatusListener listener){
        statusListeners.add(listener);
    }

    public void sendToAll(DataMessage dataMessage) {
        CompletableFuture.runAsync(() -> {
            for (WebSocketSession session : sessions) {
                sendMessage(session, dataMessage);
            }
        });
    }

    public void sendMessage(WebSocketSession session, DataMessage message){
        if(session.isOpen()){
            try {
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
            } catch (JsonProcessingException ex) {
                logger.error("failed to send message", ex);
            } catch (IOException ex) {
                logger.error("failed to send message", ex);
            }
        }
    }
}
