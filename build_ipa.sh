#!/bin/bash

# THIS DOESN'T WORK JUST YET

echo "Pre-cleanup"
rm -rf build/Payload
rm build/Payload.zip
rm build/Payload.ipa

echo "Building flutter ios release"
flutter build ios --release

echo "Copy release to Payload folder"
mkdir build/Payload
cp build/ios/iphoneos/Runner.app build/.payload

echo "Compressing Payload folder"
zip -r build/Payload.zip build/Payload

echo "Create ipa from Payload zip"
mv build/Payload.zip build/Payload.ipa

echo "Cleanup"

rm -rf build/Payload
