#!/bin/zsh

# Mac helper script to automate build process and launch browser.

# build UI
pushd ../flutter_ui
flutter build web
if [[ $? -ne 0 ]]; then
  echo "Flutter build failed"
  exit 1
fi
popd

# build mpif
./gradlew clean
./gradlew getWeb
./gradlew build
if [[ $? -eq 0 ]]; then
  (sleep 5; open https://localhost:6544) &
  ./gradlew bootRun
else
  echo "MPIF build failed"
  exit 1
fi
