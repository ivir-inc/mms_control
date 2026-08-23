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
import org.jeasy.rules.api.Rule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static com.ivir.mpif.sceneng.rules.ReservedFacts.CLOCK_CHANGE_LONG;

public abstract class ManualRule<T extends Comparable> implements Rule {
    Logger logger = LoggerFactory.getLogger(this.getClass());
    protected abstract String getControlFactKey();
    protected abstract ReservedFacts getVitalsReservedFact();
    protected abstract T addIncrement(T currentValue, float increment);

    @Override
    public int getPriority() {
        return 3;
    }

    @Override
    public boolean evaluate(Facts facts) {
        ManualControl<T> control = facts.get(getControlFactKey());
        if(control == null){
            return false;
        }

        T currentValue = getVitalsReservedFact().getFact(facts);
        Long clockChange = CLOCK_CHANGE_LONG.getFact(facts);
        if(clockChange == 0){
            return false;
        }

        if(control.isInstantaneousChange()){
            return control.getInstantaneousValue() != currentValue;
        }
        return (currentValue.compareTo(control.getCeiling()) < 0 ) && (currentValue.compareTo(control.getFloor()) > 0);
    }

    @Override
    public void execute(Facts facts) throws Exception {
        ManualControl<T> control = facts.get(getControlFactKey());
        T currentValue = getVitalsReservedFact().getFact(facts);
        Long clockChange = facts.get(CLOCK_CHANGE_LONG.getFactId());

        if(control.isInstantaneousChange()){
            getVitalsReservedFact().setFact(facts, control.getInstantaneousValue());
            facts.remove(getControlFactKey());
        }else{
            float clockChangeSecs = clockChange/1000;
            getVitalsReservedFact().setFact(facts, addIncrement(currentValue, control.getRate() * clockChangeSecs));
        }
    }

    @Override
    public int compareTo(Rule o) {
        if(this.getName().equals(o.getName())){
            return this.getPriority() - o.getPriority();
        }
        return this.getName().compareTo(o.getName());
    }
}
