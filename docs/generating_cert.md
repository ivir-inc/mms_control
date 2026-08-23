# Generating new certificate for MPIF
Use the Java keytool
1. navgivate to mpif/lib
2. generate a new keystore.jks
```
keytool -genkey -alias ivirinc.com -keystore keystore.jks -storepass ivirIVIR -validity 360 -keyalg RSA -keysize 2048
```

If you want to export the cert:
```
keytool -exportcert -alias ivirinc.com -keystore keystore.jks -file ivirinc.crt
```

## Trusting the cert on macOS (required for Chromium WebSocket dev)

Chromium enforces TLS certificate trust for `wss://` connections. Without this step, the Flutter web app will connect then immediately drop the WebSocket because the self-signed cert is untrusted.

Export the cert from the JKS and add it to the macOS System Keychain:

```bash
keytool -exportcert -alias ivirinc.com \
  -keystore mpif/src/main/resources/keystore.jks \
  -storepass ivirIVIR \
  -file /tmp/mpif_dev.crt \
  -rfc

sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  /tmp/mpif_dev.crt
```

Then **fully quit and restart Chromium** so it picks up the new trust anchor. This is a one-time step per machine.
