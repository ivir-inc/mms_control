# Third-Party Notices

> **Draft** — verify each license, version, and URL against the actual artifact's
> `META-INF` / project site before publishing. Portico's license in particular
> must be confirmed (see notes below).

MMS Control itself is licensed under the Apache License, Version 2.0 (see
[`LICENSE`](LICENSE)). It depends on the third-party components listed below;
each remains under its own license, and those terms apply only to those
components, not to MMS Control.

## Vendored components (`mpif/lib/`)

These are redistributed in this repository.

| Component | Version | License | Project |
| --- | --- | --- | --- |
| Portico RTI | 2.1.4 | CDDL-1.0 (**verify**) | https://github.com/openlvc/portico |

## Runtime dependencies (resolved from Maven Central)

Declared in `mpif/build.gradle` and downloaded at build time — not stored in this
repository, but redistributed in the packaged distribution (`packageControl`).

| Component | Version | License | Project |
| --- | --- | --- | --- |
| Spring Boot (web, websocket, log4j2, test) | 3.3.4 | Apache-2.0 | https://spring.io/projects/spring-boot |
| Spring Shell | 3.3.3 | Apache-2.0 | https://spring.io/projects/spring-shell |
| Jackson Core | 2.21.1 | Apache-2.0 | https://github.com/FasterXML/jackson-core |
| Jackson Databind | 2.18.0 | Apache-2.0 | https://github.com/FasterXML/jackson-databind |
| ZXing (core, javase) | 3.5.3 | Apache-2.0 | https://github.com/zxing/zxing |
| Apache Commons Lang | 3.18.0 | Apache-2.0 | https://commons.apache.org/proper/commons-lang/ |
| Apache Log4j (API, Core) | 2.x (via Spring Boot BOM) | Apache-2.0 | https://logging.apache.org/log4j/2.x/ |
| Nitrite (nitrite, nitrite-jackson-mapper) | 4.3.0 | Apache-2.0 | https://github.com/nitrite/nitrite-java |
| Easy Rules (easy-rules-core) | 4.1.0 | MIT | https://github.com/j-easy/easy-rules |

## Notes

- **`mms-rti-client` jar** — This is an IVIR component, **not** third-party open
  source, and is intentionally omitted from the tables above. It is not included
  in this repository and must be obtained from IVIR and placed in `mpif/lib/`.
  Its licensing and redistribution status must be resolved separately before
  release.
- **Portico** is distributed under the CDDL; confirm the exact version/terms in
  the jar or the Portico repository, and note that the CDDL carries
  source-availability obligations for the Portico jar itself.
- **HLA FOM modules** (`mpif/*.xml`) — Each module currently embeds a
  `<useLimitation>` stating it is licensed under **CC BY-ND 4.0** (NoDerivatives)
  by Information Visualization and Innovative Research, Inc. This conflicts with
  an Apache-2.0 open-source release, under which contributors may modify these
  files. As the copyright holder, IVIR must reconcile this before publishing
  (e.g. relicense the FOM text for this release, or segregate the modules as
  read-only third-party content). See the top of any `mpif/*.xml` file.

## Full license texts

The complete texts of the licenses referenced above are included in
[`licenses/`](licenses/):

- [`licenses/Apache-2.0.txt`](licenses/Apache-2.0.txt)
- [`licenses/MIT.txt`](licenses/MIT.txt)
- `licenses/CDDL-1.0.txt` 
