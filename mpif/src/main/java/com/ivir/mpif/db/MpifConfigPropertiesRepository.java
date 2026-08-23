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

package com.ivir.mpif.db;

import jakarta.annotation.PostConstruct;
import org.dizitart.no2.Nitrite;
import org.dizitart.no2.collection.Document;
import org.dizitart.no2.collection.NitriteCollection;
import org.dizitart.no2.collection.events.CollectionEventListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicReference;

@Component
public class MpifConfigPropertiesRepository{
    @Autowired
    private Nitrite nitrite;

    private NitriteCollection collection;

    @PostConstruct
    public void init(){
        collection = nitrite.getCollection(MpifConfigProperties.class.toString());
    }

    public void addListener(CollectionEventListener cel) {
        collection.subscribe(cel);
    }

    public MpifConfigProperties get() {
        Document document = collection.find().firstOrNull();
        MpifConfigProperties mpifConfigProperties = new MpifConfigProperties();
        if(document == null){
            return mpifConfigProperties;
        }
        document.forEach((pair)->{
            mpifConfigProperties.setProperty(pair.getFirst(), pair.getSecond());
        });
        return mpifConfigProperties;
    }

    public void update(MpifConfigProperties mpifConfigProperties) {
        AtomicReference<Document> documentAr = new AtomicReference<>();
        documentAr.set(collection.find().firstOrNull());
        boolean firstVersion = false;
        if(documentAr.get() == null){
            documentAr.set(Document.createDocument());
            firstVersion = true;
        }
        mpifConfigProperties.forEach((key,value)->{
            documentAr.get().put(key.toString(),value);
        });
        if(firstVersion){
            collection.insert(documentAr.get());
        }else{
            collection.update(documentAr.get(),true);
        }
    }
}
