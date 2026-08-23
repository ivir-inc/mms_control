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

package com.ivir.mpif.sceneng.rules.manual;

import com.ivir.mpif.sceneng.rules.ReservedFacts;
import com.ivir.mpif.sceneng.rules.model.ManualControl;
import org.jeasy.rules.api.Facts;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest(classes = ManualHeartRateRuleTest.class)
public class ManualHeartRateRuleTest {
    ManualHeartRateRule sut = new ManualHeartRateRule();

    @Test
    public void evaluate_returnsFalse_onNoTimeChange(){
       Facts facts = new Facts();
       ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,0L);
       ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(80));
       facts.put("heart_rate_control", ManualControl.instantaneousUpdate(70));

       assertEquals(false, sut.evaluate(facts));
    }

    @Test
    public void evaluate_returnsFalse_onNoInstantaneousChange(){
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(80));
        facts.put("heart_rate_control", ManualControl.instantaneousUpdate(80));

        assertEquals(false, sut.evaluate(facts));
    }

    @Test
    public void evaluate_returnsTrue_onInstantaneousChange(){
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(80));
        facts.put("heart_rate_control", ManualControl.instantaneousUpdate(70));

        assertEquals(true, sut.evaluate(facts));
    }

    @Test
    public void evaluate_returnsFalse_onRateChangeHitsCeiling(){
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(80));
        facts.put("heart_rate_control", ManualControl.gradualUpdate(1f, 0,80));

        assertEquals(false, sut.evaluate(facts));
    }

    @Test
    public void evaluate_returnsFalse_onRateChangeHitsFloor(){
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(0));
        facts.put("heart_rate_control", ManualControl.gradualUpdate(1f, 0,80));

        assertEquals(false, sut.evaluate(facts));
    }

    @Test
    public void evaluate_returnsTrue_onRateChangeWithinRange(){
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(60));
        facts.put("heart_rate_control", ManualControl.gradualUpdate(1f, 0,80));

        assertEquals(true, sut.evaluate(facts));
    }

    @Test
    public void execute_setsNewRate_fromInstantaneous() throws Exception {
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(60));
        facts.put("heart_rate_control", ManualControl.instantaneousUpdate(70));

        assertEquals(Integer.valueOf(60), ReservedFacts.HEART_RATE_INT.getFact(facts));
        sut.execute(facts);
        assertEquals(Integer.valueOf(70), ReservedFacts.HEART_RATE_INT.getFact(facts));
    }

    @Test
    public void execute_setNewRate_fromRate() throws Exception{
        Facts facts = new Facts();
        ReservedFacts.CLOCK_CHANGE_LONG.setFact(facts,3000L);
        ReservedFacts.HEART_RATE_INT.setFact(facts, Integer.valueOf(60));
        facts.put("heart_rate_control", ManualControl.gradualUpdate(1f,0, 90));

        assertEquals(Integer.valueOf(60), ReservedFacts.HEART_RATE_INT.getFact(facts));
        sut.execute(facts);
        assertEquals(Integer.valueOf(63), ReservedFacts.HEART_RATE_INT.getFact(facts));
    }



}
