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

package com.ivir.mpif.simdata;

import org.apache.commons.lang3.SerializationUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class ConcurrentDataStorage<T extends ConcurrentSimData<E>, E extends Enum<E>> {
    private static final Logger logger = LoggerFactory.getLogger(ConcurrentDataStorage.class);
    private final HashMap<String,T> dataMap = new HashMap<>();
    private final ArrayList<ConcurrentDataStorageListener<T>> dataStorageListenerList = new ArrayList<>();
    private final ConcurrentHashMap<String,ArrayList<ConcurrentEventListener>> eventListenerMap = new ConcurrentHashMap<>();
    private long autoIndexCounter = 0;
    private Class<T> type;
    private ConcurrentLinkedQueue<String> orderAddedQueue = new ConcurrentLinkedQueue<>();

    public ConcurrentDataStorage(Class<T> type) {
        this.type = type;
    }

    public void add(T newEntity){
        add(newEntity, false);
    }

    public void add(T newEntity, boolean silentAdd){
        if(newEntity.hasAutoIndex()){
            if(newEntity.getIndex() != null){
                throw new RuntimeException("Index must be null to add entity with auto id");
            }else {
                long nextIndex = autoIndexCounter ++;
                newEntity.setIndex(nextIndex);
            }
        }else{
            if(newEntity.getIndex() == null){
                throw new RuntimeException("The index field must be set in order to add");
            }
        }
        T currentVersion = dataMap.get(newEntity.getIndex());
        if(currentVersion != null) {
            throw new RuntimeException("Entity with that index already exists");
        }
        try {
            T entityCopy = SerializationUtils.clone(newEntity);
            entityCopy.resetUpdateSet();
            dataMap.put(newEntity.getIndex(), entityCopy);
            orderAddedQueue.add(newEntity.getIndex());
            if(!silentAdd) {
                this.fireEntityAdded(newEntity);
            }
        } catch (Exception e) {
            logger.error("Could not add new entity", e);
            throw new RuntimeException("Could not add new entity", e);
        }
    }

    public  void put(T updatedEntity){
        put(updatedEntity, false);
    }

    public void put(T updatedEntity, boolean silentPut) {
        T lastVersion = dataMap.get(updatedEntity.getIndex());
        if (lastVersion == null) {
            add(updatedEntity);
        } else {
            try {
                T entityCopy = SerializationUtils.clone(updatedEntity);
                entityCopy.resetUpdateSet();
                dataMap.put(updatedEntity.getIndex(), entityCopy);
                if (!silentPut) {
                    fireEntityUpdated(updatedEntity);
                }
            } catch (Exception e) {
                logger.info("could not add entity", e);
                throw new RuntimeException(e);
            }
        }
    }
        
    public T get(Comparable<?> indexValue){
        T foundItem = this.dataMap.get(String.valueOf(indexValue)); // keys are strings
        if(foundItem == null){
            return null;
        }
        try{
            return SerializationUtils.clone(foundItem);
        }catch(Exception e){
            logger.error("failed to serialize", e);
            return null;
        }
    }

    public T delete(Comparable<?> indexValue){
        T toReturn = this.dataMap.remove(indexValue.toString());
        if(toReturn != null){
            orderAddedQueue.remove(indexValue.toString());
        }
        return toReturn;
    }
    
    public ArrayList<T> searchByAttribute(E att, Comparable<?> value) {
        ArrayList<T> foundList = new ArrayList<>();
        try{
            for (T item : dataMap.values()) {
                if (value == null) {
                    if (item.getValue(att) == null) {
                        foundList.add(SerializationUtils.clone(item));
                    }
                } else if (item.compareValue(att, value) == 0) {
                    foundList.add(SerializationUtils.clone(item));
                }
            }
        }catch(Exception e){
            logger.error("Cannot search for entity", e);
            throw new RuntimeException(e);
        }

        return foundList;
    }

    public Collection<T> getAll() {
        ArrayList<T> foundList = new ArrayList<>();
        try {
            for (T listItem : dataMap.values()) {
                foundList.add(SerializationUtils.clone(listItem));
            }
        } catch (Exception e) {
            logger.error("Could not getAll", e);
            throw new RuntimeException(e);
        }
        return foundList;
    }

    public List<T> getAllOrderAdded(){
        return orderAddedQueue.stream().map(this::get).toList();
    }
    
    public void clearAll() {
    	dataMap.clear();
        this.autoIndexCounter = 0;
    }
    
    public int storageSize(){
        return this.dataMap.size();
    }
    
    private void fireEntityAdded(T entity){
        if(!dataStorageListenerList.isEmpty()){
            dataStorageListenerList.forEach((listener)->{
                try{
                    listener.entityAdded(SerializationUtils.clone(entity));
                }catch(Exception e){
                    logger.error("Could not fire listener", e);
                    throw new RuntimeException(e);
                }
            });
        }
    }
    
    private void fireEntityUpdated(T entity) {
    	if(!dataStorageListenerList.isEmpty()) {
            dataStorageListenerList.forEach((listener) -> {
                try {
                    listener.entityUpdated(SerializationUtils.clone(entity));
                } catch (Exception e) {
                    logger.error("could not fire listener", e);
                    throw new RuntimeException(e);
                }
            });
    	}
    }

    public void addEventListener(ConcurrentEventListener<T> listener){
        listener.getInterestedEvents().forEach((eventType)->{
            eventListenerMap.putIfAbsent(eventType.toUpperCase(), new ArrayList<>());
            ArrayList<ConcurrentEventListener> listenerList = eventListenerMap.get(eventType.toUpperCase());
            if(!listenerList.contains(listener)){
                listenerList.add(listener);
            }
        });
    }

    public void sendEvent(T entity, String eventType){
        fireEventOccurred(entity, eventType);
    }

    private void fireEventOccurred(T entity, String eventType){
        ArrayList<ConcurrentEventListener> eventListenerList = eventListenerMap.get(eventType.toUpperCase());
        if(eventListenerList == null || eventListenerList.isEmpty()){
            logger.debug("No listeners for event type: {}", eventType);
            return;
        }
        eventListenerList.forEach((listener)->{
            try{
                listener.eventOccurred(SerializationUtils.clone(entity), eventType.toUpperCase());
            }catch(Exception e){
                logger.error("Could not fire event listener", e);
                throw new RuntimeException(e);
            }
        });
    }
    
    public void addDataStorageListener(ConcurrentDataStorageListener<T> listener){
        this.dataStorageListenerList.add(listener);
    }

    public Class<T> getType(){
        return type;
    }

}