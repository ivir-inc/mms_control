@echo off
title devpackage

REM Portico does not support quotes in RTI_HOME variable but the java classpath
REM needs the windows path in quotes so we used RTI_HOME for portico
REM and RTI_LIB (with quotes the for classpath)
set RTI_HOME=C:\Program Files\Portico\portico-2.1.4
set RTI_LIB="C:\Program Files\Portico\portico-2.1.4\lib"
set RTI_RID_FILE=%RTI_HOME%\RTI.rid

java.exe -Ddevstudio.generatedcode.settings=FederateConfig.txt -Dheadless=true -cp %RTI_LIB%/portico.jar;libs/* -Djava.net.preferIPv4Stack=true com.ivir.mpif.MpifApplication

pause
