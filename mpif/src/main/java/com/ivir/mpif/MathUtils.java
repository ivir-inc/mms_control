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

package com.ivir.mpif;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class MathUtils {


        private static BigDecimal bd32 = new BigDecimal(32).setScale(1,RoundingMode.HALF_UP);
        
        public static BigDecimal fahrenheitToCelsius(float tempF) {
            tempF = tempF - 32;
            if(tempF == 0) {
                return new BigDecimal(0).setScale(0);
            }else {
                return roundToNearestTenth(tempF/1.8000f);
            }
        }
        
        public static BigDecimal celsiusToFahrenheit(float tempC) {
            return roundToNearestTenth(tempC * 1.8000f).add(bd32);
        }
        
        public static BigDecimal roundToNearestTenth(float orginalValue) { 
            BigDecimal bd = new BigDecimal(orginalValue).setScale(1, RoundingMode.HALF_UP);
            return bd;
        }
 

}
