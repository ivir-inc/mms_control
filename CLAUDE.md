# MMS Control — Project Guide

## Project Overview

MMS Control is a medical simulation control system composed of two sub-projects:

- **`mpif/`** — Java 17 Spring Boot backend (REST API + WebSocket, runs on port 6544 over HTTPS)
- **`flutter_ui/`** — Flutter web frontend, built into `mpif/src/main/resources/static/` for serving

## Build & Run

```bash
# Backend only
cd mpif
./gradlew bootRun

# Build Flutter UI and copy into backend
cd flutter_ui && flutter build web
cd ../mpif && ./gradlew getWeb

# Package full distribution zip
cd mpif && ./gradlew packageControl

# Run tests
cd mpif && ./gradlew test
```

Version is set in `mpif/gradle.properties`.

## Architecture

### Backend (`mpif/`)

Package root: `com.ivir.mpif`

| Package | Purpose |
|---|---|
| `controller` | Spring `@RestController` classes; all REST endpoints |
| `controller/model` | REST POJOs (request/response shapes) |
| `treatment` | Treatment/medication business logic and layout |
| `patient` | Patient management |
| `sceneng` | Scenario engine and rules |
| `simdata` | Core simulation data types and enums |
| `dataws` | WebSocket data layer |
| `db` | Persistence (Nitrite embedded DB) |
| `facility` | Facility management |
| `federate` | HLA federation integration |

### Frontend (`flutter_ui/`)

Standard Flutter project under `lib/`:

| Directory | Purpose |
|---|---|
| `data/model` | Dart model classes (mirrors backend REST shapes) |
| `data` | Repositories and data sources |
| `logic` | BLoC / business logic |
| `presentation` | UI screens and widgets |
| `modules/` | Feature modules (labs, handoff, pump_control, etc.) |

## Coding Standards

### Java (backend)

- All REST POJO classes go in `controller/model/` and are prefixed with `Rest` (e.g., `RestLayout`, `RestCategory`)
- POJOs use fluent setters: setters return `this`, enabling method chaining
- No annotations on POJOs — plain getters/setters only; Jackson serializes by convention
- Controllers are annotated with `@RestController` and inject services via constructor
- Services (classes that end with "Service" or "ServiceImpl") should not include REST models or use web.server or http package libraries
- GlobalExceptionHandler contains the general exception handling for REST controllers
- API paths follow the pattern `/mms/<domain>/<resource>`
- Java 17, Spring Boot 3.x
- Use `ResponseStatusException` for HTTP error responses
- Logging via Log4j2 (Logback is excluded)

### Flutter (frontend)

- SDK: Dart `>=3.3.3 <4.0.0`
- Feature modules live under `lib/modules/`
- Dart model classes mirror the backend REST POJOs in naming and structure

## Key Configuration

- Server port: **6544** (HTTPS, self-signed keystore at `classpath:keystore.jks`)
- Logs: `mpif/logs/mpif-app.log`
- App config: `mpif/src/main/resources/application.properties`
- Embedded DB: Nitrite (`org.dizitart:nitrite:4.3.0`)

## Testing

- JUnit 5 + Mockito; tests in `mpif/src/test/java/com/ivir/mpif/`
- Controller tests use `@SpringBootTest` with `@Mock` services and `@InjectMocks` on the controller
- Run with `./gradlew test`
