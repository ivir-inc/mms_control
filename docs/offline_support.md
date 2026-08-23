# Offline Support
In order to maintain offline support:
1. Ensure index.html includes local canvaskit
2. Add fonts
3. Test offline

## Ensure index.html includes local canvaskit
If the index.html in the web folder, then review the file to ensure that the flutterConfiguration still exists.

```
  <script>
    window.flutterConfiguration = {
        canvasKitBaseUrl: "/canvaskit/"
    };
  </script>
```

Ref:
https://stackoverflow.com/questions/73109896/how-can-i-run-flutter-web-app-without-internet-connection

## Add font
For each font you wan to used in the UI:
1. Download the font (.ttf) into fonts folder.
   - You can find fonts in the google library:
  https://fonts.google.com
2. Update pubspec.yaml to include the fonts

Ref:
https://docs.flutter.dev/cookbook/design/fonts

## Test offline
Test MMS Control with incognito mode without internet.