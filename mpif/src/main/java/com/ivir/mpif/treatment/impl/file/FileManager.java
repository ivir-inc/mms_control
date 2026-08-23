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

package com.ivir.mpif.treatment.impl.file;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ivir.mpif.treatment.data.MedicationTreatmentDetail;
import com.ivir.mpif.treatment.data.PhysicalTreatmentDetail;
import com.ivir.mpif.treatment.data.Scenario;
import com.ivir.mpif.treatment.data.TreatmentLayout;
import com.ivir.mpif.treatment.data.TreatmentLayout.Column;
import com.ivir.mpif.treatment.data.TreatmentLayout.Panel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;

public class FileManager {
    private Logger logger = LoggerFactory.getLogger(FileManager.class);
    private static final ObjectMapper mapper = new ObjectMapper();

    private String scenarioFolder = "scenarios";
    private String defaultLayoutFileName = "default.txl";
    private String customLayoutFileName = "custom.txl";

    public void setScenarioFolder(String path){
        this.scenarioFolder = path;
    }

    //-----------------------------------------------------------------------------------------------------------------
    //                                               Layout File Management
    //-----------------------------------------------------------------------------------------------------------------

    /**
     * save the current layout to a file so that it can be loaded later. This is used to save the layout as the user
     * has it configured. The default layout is always available and cannot be overwritten, but the custom
     * layout can be overwritten by the user.
     * @param layout
     */
    public void saveLayoutFile(TreatmentLayout layout){
        saveLayoutFile(layout, true);
    }

    private void saveLayoutFile(TreatmentLayout layout, boolean useCustom){
        LayoutFile file = new LayoutFile();
        file.setTreatments(buildLayoutPanelFileList(layout.getTreatmentPanels()));
        file.setMedications(buildLayoutPanelFileList(layout.getMedicationPanels()));

        String fileName = defaultLayoutFileName;
        if(useCustom){
            fileName = customLayoutFileName;
        }
        try {
            logger.info("Saving layout: " + fileName);
            mapper.writerWithDefaultPrettyPrinter()
                    .writeValue(Paths.get(scenarioFolder+"/"+fileName).toFile(), file);
        } catch (JsonGenerationException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private ArrayList<LayoutPanelFile> buildLayoutPanelFileList(ArrayList<Panel> panelList){
        ArrayList<LayoutPanelFile> panelFileList = new ArrayList<>();
        for(Panel panel : panelList){
            LayoutPanelFile panelFile = new LayoutPanelFile();
            panelFile.setName(panel.getPanelName());
            ArrayList<LayoutColumnFile> columnFileList = new ArrayList<>();
            for(Column column : panel.getColumns()){
                LayoutColumnFile columnFile = new LayoutColumnFile();
                columnFile.setName(column.getColumnName());
                ArrayList<String> treatmentList = new ArrayList<>();
                for(String treatment : column.getTreatments()){
                    treatmentList.add(treatment);
                }
                columnFile.setTreatments(treatmentList);
                columnFileList.add(columnFile);
            }
            panelFile.setColumns(columnFileList);
            panelFileList.add(panelFile);
        }
        return panelFileList;
    }

    /**
     * load the layout from a file. Load from the custom layout.
     * @return
     */
    public TreatmentLayout loadLayoutFile(){
        return loadLayoutFile(this.scenarioFolder, true);
    }
    
    private TreatmentLayout loadLayoutFile(String directoryPath, boolean useCustom){
        LayoutFile layoutFile = null;

        String fileName = defaultLayoutFileName;
        if(useCustom){
            fileName = customLayoutFileName;
        }
        try {
                layoutFile = mapper.readValue(Paths.get(directoryPath+"/"+fileName).toFile(), LayoutFile.class);
        } catch (JsonParseException e) {
                e.printStackTrace();
        } catch (JsonMappingException e) {
                e.printStackTrace();
        } catch (IOException e) {
                e.printStackTrace();
        }

        if(layoutFile == null){
            return null;
        }

        TreatmentLayout treatmentLayout = new TreatmentLayout();
        for(LayoutPanelFile panelFile : layoutFile.getTreatments()){
            Panel panel = treatmentLayout.treatmentPanel(panelFile.getName());
            int columnNum = 0;
            for(LayoutColumnFile columnFile : panelFile.getColumns()){
                Column column =  panel.column(columnNum);
                column.columnName(columnFile.getName());
                columnNum ++;
                for(String treatment : columnFile.getTreatments()){
                    column.addTreatment(treatment);
                }
            }
        }
        
        for(LayoutPanelFile panelFile : layoutFile.getMedications()){
            Panel panel = treatmentLayout.medicationPanel(panelFile.getName());
            int columnNum = 0;
            for(LayoutColumnFile columnFile : panelFile.getColumns()){
                Column column =  panel.column(columnNum);
                column.columnName(columnFile.getName());
                columnNum ++;
                for(String treatment : columnFile.getTreatments()){
                    column.addTreatment(treatment);
                }
            }
        }
        return treatmentLayout;
    }

    public void resetLayout(){
        TreatmentLayout defaultLayout = loadLayoutFile(this.scenarioFolder, false);
        saveLayoutFile(defaultLayout, true);
    }

    //-----------------------------------------------------------------------------------------------------------------
    //                                              Scenario File Management
    //-----------------------------------------------------------------------------------------------------------------
    public Scenario loadScenario(String fileName){
        return loadScenario(this.scenarioFolder, fileName);
    }
    
    public Scenario loadScenario(String scenarioFolder, String fileName){
        ScenarioFile scenarioFile = null;

        fileName = fileName + ".txs";
        try {
            logger.info("loading treatment scenario: " + fileName);
            scenarioFile = mapper.readValue(Paths.get(scenarioFolder+"/"+fileName).toFile(), ScenarioFile.class);
        } catch (JsonParseException e) {
                e.printStackTrace();
        } catch (JsonMappingException e) {
                e.printStackTrace();
        } catch (IOException e) {
                e.printStackTrace();
        }

        if(scenarioFile == null){
            return null;
        }
        
        Scenario scenario = new Scenario();
        scenario.setName(scenarioFile.getName());
        for(InjuryFile injuryFile : scenarioFile.getInjuries()){
            for(PhysicalTreatmentFile treatmentFile : injuryFile.getTreatments()){
                PhysicalTreatmentDetail treatment = new PhysicalTreatmentDetail(treatmentFile.getTreatmentName());
                treatment.setDevice(treatmentFile.getDevice());
                treatment.setLocation(treatmentFile.getLocation());
                treatment.setPhysicalTreatmentType(treatmentFile.getPhysicalTreatment());
                scenario.addTreatment(injuryFile.getName(), treatment);
            }
        }
        for(MedicationTreatmentFile treatmentFile : scenarioFile.getMedications()){
            MedicationTreatmentDetail treatment = new MedicationTreatmentDetail(treatmentFile.getTreatmentName());
            treatment.setCorrectDosage(treatmentFile.getDosageCorrectVal());
            treatment.setLocation(treatmentFile.getLocation());
            treatment.setMedicationName(treatmentFile.getMedication());
            treatment.setOverDosage(treatmentFile.getDosageOverVal());
            treatment.setRoute(treatmentFile.getRoute());
            treatment.setTimePeriod(treatmentFile.getTimePeriod());
            treatment.setUnderDosage(treatmentFile.getDosageUnderVal());
            treatment.setAnalgesics(treatmentFile.getAnalgesics());
            treatment.setAnaphylaxisTreatment(treatmentFile.getAnaphylaxisTreatment());
            treatment.setAntiEmetics(treatmentFile.getAntiEmetics());
            treatment.setBloodProducts(treatmentFile.getBloodProducts());
            treatment.setCardiacMedication(treatmentFile.getCardiacMedication());
            treatment.setCbrneTreatment(treatmentFile.getCbrneTreatment());
            treatment.setClottingMedication(treatmentFile.getClottingMedication());
            treatment.setFluidMedication(treatmentFile.getFluidMedication());
            treatment.setHypoglycemiaTreatment(treatmentFile.getHypoglycemiaTreatment());
            treatment.setInfectionMedication(treatmentFile.getInfectionMedication());
            treatment.setNutrition(treatmentFile.getNutrition());
            treatment.setOverdoseTreatment(treatmentFile.getOverdoseTreatment());
            treatment.setParalytics(treatmentFile.getParalytics());
            treatment.setPressers(treatmentFile.getPressers());
            treatment.setRespiratoryTreatment(treatmentFile.getRespiratoryTreatment());
            treatment.setSedation(treatmentFile.getSedation());
            treatment.setSeizureTreatment(treatmentFile.getSeizureTreatment());

            scenario.addTreatment(treatment);
        }
        return scenario;
    }
    
    public ArrayList<String> listScenarios(){
        return listScenarios(this.scenarioFolder);
    }
    
    /**
     * get a list of the treatment scenario file name available in this directory. The
     * file names are <scearioId>.txs; so the is pulled right from the
     * name.
     *
     * @return list of file names
     */
    public ArrayList<String> listScenarios(String sceanrioFolder) {

        ArrayList<String> fileList = new ArrayList<>();

        try {
            Files.list(new File(sceanrioFolder).toPath())
                    .forEach(path -> {
                        String fileName = path.getFileName().toString();
                        int extPos = fileName.indexOf(".txs");
                        if (extPos > 0) {
                            fileList.add(fileName.substring(0, extPos));
                        }

                    });
        } catch (IOException e) {
            e.printStackTrace();
        }

        return fileList;
    }
    
    public String saveScenario(String fileName, Scenario scenario){
        return saveScenario(this.scenarioFolder, fileName, scenario);
    }
    
    public String saveScenario(String userSpecifiedFolder, String fileName, Scenario scenario){
        ScenarioFile scenarioFile = new ScenarioFile();
        scenarioFile.setName(scenario.getName());
        
        //build physical treatments which start with the injury
        ArrayList<InjuryFile> injuryFileList = new ArrayList<>();
        for(String injuryName : scenario.getInjuryBasedTreatments().keySet()){
            InjuryFile injuryFile = new InjuryFile();
            injuryFile.setName(injuryName);
            ArrayList<PhysicalTreatmentFile> treatments = new ArrayList<>();
            for(PhysicalTreatmentDetail treatmentDetails : scenario.getInjuryBasedTreatments().get(injuryName).values()){
                PhysicalTreatmentFile treatmentFile = new PhysicalTreatmentFile();
                treatmentFile.setTreatmentName(treatmentDetails.getTreatmentName());
                treatmentFile.setDevice(treatmentDetails.getDevice());
                treatmentFile.setLocation(treatmentDetails.getLocation());
                treatmentFile.setPhysicalTreatment(treatmentDetails.getPhysicalTreatmentType());
                treatments.add(treatmentFile);
            }
            injuryFile.setTreatments(treatments);
            injuryFileList.add(injuryFile);
        }
        scenarioFile.setInjuries(injuryFileList);
        
        //build medication treatments which do not contain injuries
        ArrayList<MedicationTreatmentFile> treatments = new ArrayList<>();
        for(MedicationTreatmentDetail treatmentDetail : scenario.getMedicationTreatments().values()){
            MedicationTreatmentFile treatmentFile = new MedicationTreatmentFile();
            treatmentFile.setDosageCorrectVal(treatmentDetail.getCorrectDosage());
            treatmentFile.setDosageOverVal(treatmentDetail.getOverDosage());
            treatmentFile.setDosageUnderVal(treatmentDetail.getUnderDosage());
            treatmentFile.setLocation(treatmentDetail.getLocation());
            treatmentFile.setMedication(treatmentDetail.getMedicationName());
            treatmentFile.setRoute(treatmentDetail.getRoute());
            treatmentFile.setTimePeriod(treatmentDetail.getTimePeriod());
            treatmentFile.setTreatmentName(treatmentDetail.getTreatmentName());
            treatmentFile.setAnalgesics(treatmentDetail.getAnalgesics());
            treatmentFile.setAnaphylaxisTreatment(treatmentDetail.getAnaphylaxisTreatment());
            treatmentFile.setAntiEmetics(treatmentDetail.getAntiEmetics());
            treatmentFile.setBloodProducts(treatmentDetail.getBloodProducts());
            treatmentFile.setCardiacMedication(treatmentDetail.getCardiacMedication());
            treatmentFile.setCbrneTreatment(treatmentDetail.getCbrneTreatment());
            treatmentFile.setClottingMedication(treatmentDetail.getClottingMedication());
            treatmentFile.setFluidMedication(treatmentDetail.getFluidMedication());
            treatmentFile.setHypoglycemiaTreatment(treatmentDetail.getHypoglycemiaTreatment());
            treatmentFile.setInfectionMedication(treatmentDetail.getInfectionMedication());
            treatmentFile.setNutrition(treatmentDetail.getNutrition());
            treatmentFile.setOverdoseTreatment(treatmentDetail.getOverdoseTreatment());
            treatmentFile.setParalytics(treatmentDetail.getParalytics());
            treatmentFile.setPressers(treatmentDetail.getPressers());
            treatmentFile.setRespiratoryTreatment(treatmentDetail.getRespiratoryTreatment());
            treatmentFile.setSedation(treatmentDetail.getSedation());
            treatmentFile.setSeizureTreatment(treatmentDetail.getSeizureTreatment());

            treatments.add(treatmentFile);
        }
        scenarioFile.setMedications(treatments);
        
        try {
                mapper.writeValue(Paths.get(userSpecifiedFolder +"/"+fileName+".txs").toFile(), scenarioFile);
                return Paths.get(userSpecifiedFolder +"/"+fileName+".txs").toFile().getAbsolutePath();
        } catch (JsonGenerationException e) {
                e.printStackTrace();
        } catch (JsonMappingException e) {
                e.printStackTrace();
        } catch (IOException e) {
                e.printStackTrace();
        }
        return null;
    }
}
