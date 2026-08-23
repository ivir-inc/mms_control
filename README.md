# MMS Control

MMS Control is a medical simulation control system for the Joint Emergency Trauma Simulation (JETS) federation. It provides a web-based control interface for
managing simulated patients, treatments, medications, scenarios, and facilities,
and acts as an HLA (High Level Architecture) federate that exchanges ground-truth
patient data with other federates.

It is made up of two sub-projects:

- **`mpif/`** — a Java 17 Spring Boot backend (REST API + WebSocket) that hosts
  the federation logic and serves the web UI over HTTPS.
- **`flutter_ui/`** — a Flutter web frontend, built and served from the backend.

The backend connects to a federation using the
[Portico](https://github.com/openlvc/portico) RTI and the HLA 1516-2010 (Evolved)
FOM modules included in this repository.

You can also view and download the [MMS FOM](https://github.com/ivir-inc/jets_mms_fom) separately.

See the [Quick Guide](https://github.com/ivir-inc/mms_control/blob/main/docs/quick_guide.md) for system operation notes.

For more information, please contact jets@ivirinc.com

For additional detail on JETS, see https://jets-systems.com/

## Features

- Web-based control interface (served over HTTPS on port `6544`)
- Create, monitor, and control simulated patients, injuries, and vital signs
- Customize treatments, medications, and their layout
- Facility management and patient transfer
- QR-code startup tab for quick client connection
- HLA federation integration (join/resign, object/interaction exchange)
- Embedded persistence (Nitrite) — no external database required

## Requirements

- **Java** — JDK 17
- **Flutter** — Dart SDK `>=3.3.3 <4.0.0` (only needed to build the UI from source)
- **Portico RTI** `2.1.4` — install separately and set `RTI_HOME`
  (download from https://github.com/openlvc/portico)
- **`mms-rti-client` jar** — an IVIR-provided component (see
  [`THIRD-PARTY.md`](THIRD-PARTY.md)); place it in `mpif/lib/`

Third-party libraries are resolved from Maven Central by Gradle. The Portico RTI
jar is vendored in `mpif/lib/`. See [`THIRD-PARTY.md`](THIRD-PARTY.md) for the
full list and their licenses.

## Building

All commands assume you start in the repository root.

### 1. Build the Flutter UI

```bash
cd flutter_ui
flutter build web
```

### 2. Copy the UI into the backend and build

```bash
cd mpif
./gradlew getWeb      # copies flutter_ui/build/web into the backend's static resources
./gradlew build       # use gradlew.bat on Windows
```

See [`docs/build.md`](docs/build.md) for more detail.

## Running

### From source (development)

```bash
cd mpif
./gradlew bootRun     # gradlew.bat bootRun on Windows
```

Then open `https://localhost:6544` in a browser. The server uses a self-signed
certificate, so you will need to accept the browser security warning.

> The bundled keystore (`demoDemo` password) is for local development only.
> Generate your own certificate before any real deployment — see
> [`docs/generating_cert.md`](docs/generating_cert.md).

### From a packaged distribution

To build a distributable zip:

```bash
cd mpif
./gradlew getDeps         # download runtime dependencies
./gradlew packageControl  # produces build/zip/mms_control_<version>.zip
```

The packaged app launches with the `run` scripts, which require Portico to be
installed and `RTI_HOME` set. See the bundled
[`scripts/README.txt`](mpif/src/main/resources/scripts/README.txt) for end-user
launch instructions.

## Configuration

- **`mpif/mpif.json`** — runtime settings (federation/federate names, facility
  id, integration hostnames/ports, feature toggles).
- **`mpif/FederateConfig.txt`** — HLA federate/federation names, FOM module URLs,
  and optional CRC host/port overrides.
- **`mpif/src/main/resources/application.properties`** — Spring Boot settings
  (server port, SSL keystore, logging). A local override file
  `application-local.properties` is git-ignored.
- **`mpif/*.xml`** — HLA 1516-2010 (Evolved) FOM modules.

## Repository layout

```
mpif/                         Java 17 Spring Boot backend
  src/main/java/com/ivir/mpif/ Backend source (controllers, services, sceneng, ...)
  src/main/resources/          application.properties, scripts, static web UI
  lib/                         Vendored jars (portico.jar, mms-rti-client)
  *.xml                        HLA FOM modules (Base, Patient, Communications, ...)
  FederateConfig.txt           Federate configuration
  mpif.json                    Runtime settings
  scenarios/                   Scenario definitions
flutter_ui/                   Flutter web frontend
  lib/                         Dart source (data, logic, presentation, modules)
docs/                         Build and design docs
licenses/                     Full third-party license texts
```

See [`CLAUDE.md`](CLAUDE.md) for a more detailed architecture and coding-standards
reference.

## License

Licensed under the Apache License, Version 2.0 — see [`LICENSE`](LICENSE).

```
Copyright 2026 IVIR Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Bundled and referenced third-party components remain under their own licenses;
see [`THIRD-PARTY.md`](THIRD-PARTY.md).
