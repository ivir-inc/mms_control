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

package com.ivir.mpif.shell;

import com.ivir.mpif.clock.ClockService;
import com.ivir.mpif.simdata.DateTimeSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

@ShellComponent
public class ClockCommands {
   @Autowired
    ClockService clockService;
   @Autowired
   DateTimeSimDataService dateTimeSimDataService;

    @ShellMethod(key = "clockStatus", value = "get the current status of the clock")
    public void getClockStatus(){
       System.out.println("State: " + clockService.getClockState());
       System.out.println("Owns Federation Clock: " + clockService.getOwnsFederationTime());
       dateTimeSimDataService.getAllDateTimes().forEach(System.out::println);
    }

    @ShellMethod(key = "startClock", value = "Start the clock.")
    public void startClock(){
        clockService.startClock();
        getClockStatus();
    }


    @ShellMethod(key = "stopClock", value = "Stop the clock")
    public void stopClock(){
        clockService.stopClock();
        getClockStatus();
    }

    @ShellMethod(key = "pauseClock", value = "pause the clock")
    public void pauseClock(){
        clockService.pauseClock();
        getClockStatus();
    }


}
