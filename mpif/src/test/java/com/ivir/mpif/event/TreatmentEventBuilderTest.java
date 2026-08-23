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

package com.ivir.mpif.event;

import com.ivir.mpif.simdata.*;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest(classes = TreatmentEventBuilderTest.class)
public class TreatmentEventBuilderTest {

    @Test
    public void physicalTreatmentClause_generates(){
        assertEquals("Eye covered", TreatmentEventBuilder.physicalTreatmentClause(PhysicalTreatmentType.COVER_EYE));
    }

    @Test
    public void medicationTreatmentClause_generates(){
        assertEquals("Saline 0.9% administered", TreatmentEventBuilder.medicationTreatmentClause(Medication.SALINE09));
    }

    @Test
    public void locationPhrase_withNoBodyPart_generatesEmptyString(){
        assertEquals("",TreatmentEventBuilder.locationPhrase(new BodyLocation()));
    }

    @Test
    public void locationPhrase_withOnlyOrientation_generates(){
        assertEquals("on the left",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setSagittalPlane(SagittalPlane.LEFT)));

        assertEquals("on the left upper",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setSagittalPlane(SagittalPlane.LEFT)
                .setTransversePlane(TransversePlane.UPPER)
        ));

        assertEquals("on the left upper posterior",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setSagittalPlane(SagittalPlane.LEFT)
                .setTransversePlane(TransversePlane.UPPER)
                .setCoronalPlane(CoronalPlane.POSTERIOR)
        ));


        assertEquals("on the upper",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setTransversePlane(TransversePlane.UPPER)
        ));

        assertEquals("on the anterior",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setCoronalPlane(CoronalPlane.ANTERIOR)
        ));
    }

    @Test
    public void locationPhrase_withOnlyBodyPartGenerates(){
        assertEquals("on the face",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setGeneralRegion(GeneralRegion.FACE)
        ));

        assertEquals("on the skin",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setRegionTissueType(RegionTissueType.SKIN)
        ));

        assertEquals("on the brain",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setInternalAnatomy(InternalAnatomy.BRAIN)
        ));

        assertEquals("on the fibula",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setSkeletalSystem(SkeletalSystem.FIBULA)
        ));

        assertEquals("on the space of sixth intercostal compartment",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setDetailedAnatomy(DetailedAnatomy.SPACE_OF_SIXTH_INTERCOSTAL_COMPARTMENT)
        ));
    }

    @Test
    public void locationPhrase_withBothOrientationAndPart_generates(){
        assertEquals("on the left upper spine",TreatmentEventBuilder.locationPhrase(new BodyLocation()
                .setSagittalPlane(SagittalPlane.LEFT)
                .setTransversePlane(TransversePlane.UPPER)
                .setSkeletalSystem(SkeletalSystem.SPINE)
        ));
    }

    @Test
    public void locationPhrase_withBothRegionTissueTypeAndGeneralRegion_generates(){
        assertEquals("on the left anterior musculature of the lower leg", TreatmentEventBuilder.locationPhrase(
                new BodyLocation()
                        .setSagittalPlane(SagittalPlane.LEFT)
                        .setCoronalPlane(CoronalPlane.ANTERIOR)
                        .setRegionTissueType(RegionTissueType.MUSCULATURE)
                        .setGeneralRegion(GeneralRegion.LOWER_LEG)
        ));
    }
}
