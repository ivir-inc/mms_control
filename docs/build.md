# Building MMS Control 
All examples assume in you are in the MPIF project root directory.

## Build Flutter UI

### Build
`cd fluter_ui`  
`flutter build web`  
or  
`cd fluter_ui`  
`flutter build web --source-maps`

### Test Run
`flutter run -d chrome`

## Build MPIF

### Clean
from the command line, execute  
for linux:
`./gradlew clean`  
for windows:
`./gradlew.bat clean`

### Get Flutter (web) files

from the command line, execute  
for linux:
`./gradlew getWeb`  
for windows:
`./gradlew.bat getWeb`


### Build
from the command line, execute:  
for linux:
`./gradlew build`  
for windows:
`./gradlew.bat build`

## Run from source
from the command line, execute:  
for linux:
`./gradlew bootRun`  
for windows:
`./gradlew.bat bootRun`

## Package
To generate zip packages that can be provided to customers, 3rd parties, etc:
1. Update the version number in build.gradle
2. Download dependencies
3. Execute the correct package target

### Update the version number
Open build.gradle and update version number in the `version =` line.

```
group = 'com.ivir'
version = '0.0.1-SNAPSHOT'
```

### Download dependencies
for linux: `./gradlew getDeps`  
for windows: `./gradlew.bat getDeps`


### Execute package target
To create the MMS Control package, execute:  
for linux: `./gradlew packageControl`  
for windows: `./gradlew.bat packageControl`

This will generate the package mms_control_${version}.zip
