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

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

@SpringBootTest(classes = SimDataTest.class)
public class SimDataTest {


    @Test
    public void equals_worksCorrectly(){
        SimDataMock simData1 = new SimDataMock();
        SimDataMock simData2 = new SimDataMock();
        simData1.setValueTest(SimDataMock.TestAttributes.ATT0_INT,1);
        simData1.setValueTest(SimDataMock.TestAttributes.ATT1_STR,"A");
        simData2.setValueTest(SimDataMock.TestAttributes.ATT0_INT,1);
        simData2.setValueTest(SimDataMock.TestAttributes.ATT1_STR,"A");
        assertEquals(simData1,simData2);

        simData2.setValueTest(SimDataMock.TestAttributes.ATT1_STR, "B");
        assertNotEquals(simData1,simData2);

        simData1.setValueTest(SimDataMock.TestAttributes.ATT1_STR, "B");
        assertEquals(simData1,simData2);

        simData1.setValueTest(SimDataMock.TestAttributes.ATT0_INT, 3);
        assertNotEquals(simData1,simData2);

        simData2.setValueTest(SimDataMock.TestAttributes.ATT0_INT, 3);
        simData2.setValueTest(SimDataMock.TestAttributes.ATT1_STR,null);
        simData1.setValueTest(SimDataMock.TestAttributes.ATT1_STR,null);
        assertEquals(simData1,simData2);
    }

    @Test
    public void hasCode_worksCorrectly(){
        SimDataMock simData1 = new SimDataMock();
        SimDataMock simData2 = new SimDataMock();
        simData1.setValueTest(SimDataMock.TestAttributes.ATT0_INT,1);
        simData1.setValueTest(SimDataMock.TestAttributes.ATT1_STR,"A");
        simData2.setValueTest(SimDataMock.TestAttributes.ATT0_INT,1);
        simData2.setValueTest(SimDataMock.TestAttributes.ATT1_STR,"A");

        assertEquals(simData1.hashCode(), simData2.hashCode());

    }

}
