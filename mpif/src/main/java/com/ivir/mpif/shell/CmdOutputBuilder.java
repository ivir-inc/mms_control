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

public class CmdOutputBuilder {
	StringBuilder outTextBuilder = new StringBuilder("");
	
	private CmdOutputBuilder() {}
	
	public static CmdOutputBuilder start() {
		return new CmdOutputBuilder();
	}
	
	public CmdOutputBuilder line(String text) {
		outTextBuilder.append(text).append("\n");
		return this;
	}

	public CmdOutputBuilder line(String ...concatParts) {
		for(String part : concatParts) {
			outTextBuilder.append(part);
		}
		outTextBuilder.append("\n");
		return this;
	}
	
	public CmdOutputBuilder lineForEach(String ...lines) {
		for(String lineText : lines) {
			outTextBuilder.append(lineText).append("\n");
		}
		return this;
	}
	
	
    /**
     * prompts user to select an item from the list.  It will use the object's
     * toString() to identify each item
     * @param itemName name of item to used in the prompt
     * @param selectionList list of items to select from
     */	
	public CmdOutputBuilder promptToSelect(String itemName, Object[] selectionList) {
		promptToSelect(itemName, selectionList, (obj)->{return obj.toString();});
		return this;
	}
	
	
	
    /**
     * prompts user to select an item from the list
     * @param itemName name of item to used in the prompt
     * @param selectionList list of items to select from
     * @param objectToString function to convert object to a string
     * @return 
     */	
	public CmdOutputBuilder promptToSelect( String itemName, Object[] selectionList, ObjectToStringFunc objectToString) {
		outTextBuilder.append("Enter number of ").append(itemName).append(":\n");
        int count = 0;
        for (Object item : selectionList) {
        	outTextBuilder.append(count).append(") ").append(objectToString.objecToString(item));
            count++;
        }
        outTextBuilder.append("99) back to main menu\n");
        outTextBuilder.append(itemName).append(" number>\n");
        return this;
	}
	
	
	public String toString() {
		return this.outTextBuilder.toString();
	}
	
    public interface ObjectToStringFunc{
        public String objecToString(Object o);
    }	
	
}
