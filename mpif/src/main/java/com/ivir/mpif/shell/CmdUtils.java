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

import org.jline.reader.LineReader;

import java.util.List;
import java.util.Optional;
import java.util.function.Function;

public class CmdUtils {
    public static String promptToEnterString(LineReader lineReader, String prompt) {
        System.out.println(prompt + ":");
        return lineReader.readLine("Enter>", null, "");
    }

    public static Optional<Integer> promptToEnterInt(LineReader lineReader, String prompt) {
        System.out.println(prompt + ":");
        String value = lineReader.readLine("Enter>", null, "");
        try {
            int enteredItem = Integer.valueOf(value);
            return Optional.ofNullable(enteredItem);
        } catch (Exception e) {
            System.out.println("invalid entry, you must enter a number");
            return Optional.empty();
        }
    }

    public static Optional<Float> promptToEnterFloat(LineReader lineReader, String prompt) {
        System.out.println(prompt + ":");
        String value = lineReader.readLine("Enter>", null, "");
        try {
            float enteredItem = Float.valueOf(value);
            return Optional.ofNullable(enteredItem);
        } catch (Exception e) {
            System.out.println("invalid entry, you must enter a number");
            return Optional.empty();
        }
    }

    /**
     * prompts user to select an item from the list.  It will use the object's
     * toString() to identify each item
     * @param itemName name of item to used in the prompt
     * @param selectionList list of items to select from
     * @return
     */
    public static Optional<Object> promptToSelectObject(LineReader lineReader, String itemName, Object[] selectionList) {
        return promptToSelectObject(lineReader, itemName, selectionList, (obj)->{return obj.toString();});
    }

    /**
     * prompts user to select an item from the list
     * @param itemName name of item to used in the prompt
     * @param selectionList list of items to select from
     * @return
     */
    public static Optional<Object> promptToSelectObject(LineReader lineReader, String itemName, Object[] selectionList, Function<Object, String> toStringFunc) {
        CmdOutputBuilder builder = CmdOutputBuilder.start();
        builder.line("Enter number of " + itemName + ":");
        int count = 0;
        for (Object item : selectionList) {
            builder.line(String.valueOf(count), ") ",toStringFunc.apply(item));
            count++;
        }
        builder.line("99) back to main menu")
                .line(itemName);
        System.out.println(builder);
        String value = lineReader.readLine("Enter>", null, "");
        try{
            int selectedItem = Integer.parseInt(value);
            if ((selectedItem < 0) || (selectedItem >= selectionList.length)) {
                return Optional.empty();
            } else {
                return Optional.ofNullable(selectionList[selectedItem]);
            }
        }catch(Exception e){
            return Optional.empty();
        }
    }

    public static Optional<Integer> promptForNumber(LineReader lineReader, String itemName, String ... selectionList){
        CmdOutputBuilder builder = CmdOutputBuilder.start();
        builder.line("Enter number of " + itemName + ":");
        int count = 0;
        for (String item : selectionList) {
            builder.line(String.valueOf(count), ") ", item);
            count++;
        }
        builder.line("99) cancel")
                .line(itemName);
        System.out.println(builder);
        String value = lineReader.readLine("Enter>", null, "");
        try{
            int selectedItem = Integer.parseInt(value);
            if ((selectedItem < 0) || (selectedItem >= selectionList.length)) {
                System.out.println("Selection must be from 0 to " + (selectionList.length - 1));
                return Optional.empty();
            } else {
                return Optional.ofNullable(selectedItem);
            }
        }catch(Exception e){
            System.out.println("You must enter a number");
            return Optional.empty();
        }
    }

    public static String booleanToOnOff(boolean on){
        if(on){
            return "On";
        }else{
            return "Off";
        }
    }

}
