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

public class BasicDeleteReturn {
    private Integer deletedCount;
    private String message;

    public BasicDeleteReturn(){
        this.deletedCount = 0;
        this.message = null;
    }

    public BasicDeleteReturn(Integer updated, String message){
        this.deletedCount = updated;
        this.message = message;
    }

    public Integer getDeletedCount() {
        return deletedCount;
    }

    public BasicDeleteReturn setDeletedCount(Integer deletedCount) {
        this.deletedCount = deletedCount;
        return this;
    }

    public String getMessage() {
        return message;
    }

    public BasicDeleteReturn setMessage(String message) {
        this.message = message;
        return this;
    }
}
