#!/bin/zsh

# Rebuilds the Flutter web UI and redeploys it onto an already-running
# backend, without restarting the backend. Use this for tablet/browser
# testing against the Spring-served build (flutter run's hot restart never
# touches this path, so changes there are invisible here until redeployed).
#
# Requires application-local.properties to have Spring's static-resource
# caching disabled (no-store) and the backend running with the local
# profile active, otherwise stale assets may still be served. See:
# JAVA_TOOL_OPTIONS="-Dspring.profiles.active=local" ./gradlew bootRun

set -e

echo "Building Flutter web..."
pushd ../flutter_ui > /dev/null
flutter build web
popd > /dev/null

echo "Copying build into Spring static resources..."
./gradlew getWeb processResources

echo "Done. If the backend is running with the local (no-store) profile,"
echo "just reload the page — no restart needed."
