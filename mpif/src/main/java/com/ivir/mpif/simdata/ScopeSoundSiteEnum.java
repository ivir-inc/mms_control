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

public enum ScopeSoundSiteEnum {
    AORTIC("HEART",1,"Aortic"),
    PULMONIC("HEART",2,"Pulmonic"),
    TRICUSPID("HEART",3,"Tricuspid"),
    MITRAL("HEART",4,"Mitral"),
    LUNG_RL("LUNG",5,"Lung Right Lower"),
    LUNG_RU("LUNG",6,"Lung Right Upper"),
    LUNG_LL("LUNG",7,"Lung Left Lower"),
    LUNG_LU("LUNG",8,"Lung Left Upper"),
    BOWEL("BOWEL",13,"Bowel"),
    BRUIT("BRUIT",17,"Bruit"),
    TEST("OTHER",96,"Test Tone 50Hz"),
    KOROTFOFF("OTHER",20,"Korotfoff"),
    ECG("OTHER",95,"ECG");
    
    private String category = null;
    private Integer siteId = null;
    private String siteName = null;
    
    private ScopeSoundSiteEnum(String cat, int id, String name){
        this.category = cat;
        this.siteId = id;
        this.siteName = name;
    }
    
    public int getSiteId(){
        return this.siteId;
    }
    
    public String getCategory(){
        return this.category;
    }
    
    public String getSiteDescription(){
        return this.siteName;
    }
    
    public static ScopeSoundSiteEnum getSiteById(int id){
        for(ScopeSoundSiteEnum site : ScopeSoundSiteEnum.values()){
            if(id == site.getSiteId()){
                return site;
            }
        }
        return null;
    }    

}
