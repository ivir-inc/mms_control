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
import org.dizitart.no2.Nitrite;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

import java.util.Optional;
import java.util.TreeSet;

@ShellComponent
public class DbCommands {
    @Autowired
    Nitrite nitrite;

    @ShellMethod(key = "listTables")
    public String listTables(){
        TreeSet<String> treeSet = new TreeSet<>();
        nitrite.listRepositories().forEach((name)->treeSet.add(name));
        nitrite.listCollectionNames().forEach((name)->treeSet.add(name));

        StringBuilder builder = new StringBuilder("\n");
        treeSet.forEach((name)->builder.append(name).append(("\n")));
        return builder.toString();
    }

    @ShellMethod(key = "queryTable")
    public String queryTable(
            @ShellOption(defaultValue = "NONE") String table
    ) throws ClassNotFoundException {
        if(table == "NONE"){
            return "include table name";
        }
        Optional<String> repoName = nitrite.listRepositories().stream().filter((name)->name.contains(table)).findFirst();
        if(repoName.isPresent()){
            StringBuilder tableBuilder = new StringBuilder();
            nitrite.getRepository(Class.forName(repoName.get())).find().toList().forEach((row)->tableBuilder.append(row.toString()).append("\n"));
            return tableBuilder.toString();
        }else{
            Optional<String> collectionName = nitrite.listCollectionNames().stream().filter((name)->name.contains(table)).findFirst();
            if(collectionName.isPresent()) {
                StringBuilder collectionBuilder = new StringBuilder();
                nitrite.getCollection(collectionName.get()).find().toList().forEach((row) -> collectionBuilder.append(row.toString()).append("\n"));
                return collectionBuilder.toString();
            }
        }
        return "Table: " + table + " not found";
    }

}
