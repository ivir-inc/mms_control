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
package com.ivir.mpif.treatment.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

/**
 *
 * @author blewa
 */
public class TreatmentLayout {
    private final HashSet<String> treatmentSet = new HashSet<>();
    private final HashMap<String,Panel> treatmentPanelMap = new HashMap<>();
    private final ArrayList<Panel> treatmentPanelOrder = new ArrayList<>();
    private final HashMap<String,Panel> medicationPanelMap = new HashMap<>();
    private final ArrayList<Panel> medicationPanelOrder = new ArrayList<>();
    
    public TreatmentLayout(){
        
    }
    
    public static TreatmentLayout builder(){
        TreatmentLayout layout = new TreatmentLayout();
        return layout;
    }
    
    public Panel treatmentPanel(String name){
        Panel panel = this.treatmentPanelMap.get(name);
        if(panel == null){
            panel = new Panel(name);
            this.treatmentPanelMap.put(name,panel);
            this.treatmentPanelOrder.add(panel);
        }
        return panel;
    }

    public Panel medicationPanel(String name){
        Panel panel = this.medicationPanelMap.get(name);
        if(panel == null){
            panel = new Panel(name);
            this.medicationPanelMap.put(name,panel);
            this.medicationPanelOrder.add(panel);
        }
        return panel;
    }
    
    public ArrayList<Panel> getTreatmentPanels(){
        return this.treatmentPanelOrder;
    }
    
    public ArrayList<Panel> getMedicationPanels(){
        return this.medicationPanelOrder;
    }
    
    protected void addTreatmentToSet(String treatment){
        this.treatmentSet.add(treatment);
    }

    //--------------------------------------------------------------------------
    //                             Panel
    //--------------------------------------------------------------------------

    public class Panel {
        private String name;
        private final ArrayList<Column> columns = new ArrayList<>();

        public Panel(String name){
            this.name = name;
        }
        
        public String getPanelName(){
           return this.name;
        }

        public Column column(int colNum){
            if(colNum < columns.size()){
                return columns.get(colNum);
            }else{
                Column newCol = null;
                for(int gapCount = columns.size()-1; gapCount < colNum; gapCount ++){
                    newCol = new Column();
                    columns.add(newCol);
                    columns.size();
                }
                return newCol;
            }
        }
        
        public ArrayList<Column> getColumns(){
            return this.columns;
        }

        public Panel treatmentPanel(String name){
            return TreatmentLayout.this.treatmentPanel(name);
        }

        public Panel medicationPanel(String name){
            return TreatmentLayout.this.medicationPanel(name);
        }
        
        public TreatmentLayout build(){
            return TreatmentLayout.this;
        }

    }

    //--------------------------------------------------------------------------
    //                       Column
    //--------------------------------------------------------------------------
    public class Column {
        private String name = null;
        private ArrayList<String> treatments = new ArrayList<>();

        public Column columnName(String name){
            this.name = name;
            return this;
        }

        public String getColumnName(){
            return this.name;
        }
        
        public ArrayList<String> getTreatments(){
            return treatments;
        }
        
        public Column addTreatment(String treatment){
            treatments.add(treatment);
            TreatmentLayout.this.addTreatmentToSet(treatment);
            return this;
        }

        public Panel treatmentPanel(String name){
            return TreatmentLayout.this.treatmentPanel(name);
        }

        public Panel medicationPanel(String name){
            return TreatmentLayout.this.medicationPanel(name);
        }

        public TreatmentLayout build(){
            return TreatmentLayout.this;
        }
        
        
    }
    //--------------------------------------------------------------------------
}
