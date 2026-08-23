MMS CONTROL - SETUP AND LAUNCH INSTRUCTIONS
=============================================

This covers what you need installed before running MMS Control, and how to
start it. It does not cover using the application itself once it's running.

PREREQUISITES
-------------

1. Java 17
   Must be installed on your computer before running MMS Control. Any
   Java 17 distribution works (e.g. Oracle JDK, Eclipse Temurin).

2. Portico 2.1.4 (HLA RTI middleware)
   Required for MMS Control to run. Windows users: if Portico was installed
   using its default install location, no further setup is needed (see
   below). Mac/Linux users will need to tell MMS Control where Portico is
   installed (see below).

WINDOWS - run.bat
-----------------

Double-click run.bat.

This assumes Portico 2.1.4 was installed to its default location:
  C:\Program Files\Portico\portico-2.1.4

If you installed Portico somewhere else, open run.bat in a text editor and
update these two lines near the top to match your install location:
  set RTI_HOME=C:\Program Files\Portico\portico-2.1.4
  set RTI_LIB="C:\Program Files\Portico\portico-2.1.4\lib"

MAC / LINUX - run.sh
--------------------

run.sh cannot be double-clicked - it must be run from a terminal.

Do NOT use run.bat on a Mac - it is a Windows-only file and will not run.

One-time setup:
  1. Open Terminal and navigate to this folder, e.g.:
       cd path/to/mms_control
  2. Make the script runnable:
       chmod +x run.sh
  3. Open run.sh in a text editor and set RTI_HOME to point at wherever
     Portico 2.1.4 is installed on your computer, for example:
       export RTI_HOME=/Users/yourname/portico-2.1.4
     (Uncomment that line if it starts with a # and fill in your path.)

Then, to launch, from Terminal:
  ./run.sh

CONFIRMING IT LAUNCHED
-----------------------

Once running, open a web browser to:
  https://<this computer's address>:6544

Your browser will show a certificate warning - this is expected, MMS
Control uses a self-signed certificate. Proceed past the warning to reach
the application.

TROUBLESHOOTING
----------------

"What application do you want to use to open this file?" (on Mac)
  You tried to open run.bat, which is Windows-only. Use run.sh instead,
  from Terminal (see above).

"RTI_HOME must be set."
  Portico is not installed, or RTI_HOME in run.sh has not been set to
  where it's installed (Mac/Linux only - see above).

"java: command not found" / "'java' is not recognized"
  Java 17 is not installed, or not set up correctly on your computer.

Browser shows a certificate/security warning
  Expected - proceed past it (see "Confirming it launched" above).
