# Quick Guide for MMS Control

## General Operation

- MMS Control is designed for use on a JETS federation.
- All of the Settings options, along with the QR code page, can be used while either connected or disconnected from a federation.
- All settings are saved between runtimes.
- All dashboards and patient pages are only functional while connected to a federation.

### Patient Control

- Any patients created by other federates will automatically populate in MMS Control.
- "Internal" patients are patients created by MMS Control, where MMS Control owns the vital signs object
- "External" patients are patients created by other systems, where MMS Control can only display the vital signs and cannot change them
- All federates can publish injuries and treatments for a patient, regardless of vital signs ownership

### Patient Case

Patient cases determine which treatments and medications are available for selection during runtime. They also set initial injuries and initial vital signs for the patient.

## QR Code

The QR code is provided as an easy way to open the web UI from a tablet interface. You can also manually open the web UI on a tablet by entering the url: https://[host-ip]:6544

If you are primarily using the web UI on the host machine, uncheck the "show screen on startup" option to instead default to the federation dashboard on launch.

## Troubleshooting

- If the web UI is not generating a QR code but shows a list of IP addresses, force select the proper IP address to refresh the code.
- If the federation connection panel is showing an error and you've recently installed a new version, force a browser cache refresh.
