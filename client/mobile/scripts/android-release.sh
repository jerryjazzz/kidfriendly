#!/bin/bash

cordova build --release android
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ../key/kf-release-key.keystore ../platforms/android/ant-build/CordovaApp-release-unsigned.apk kidfriendly
rm -f ../platforms/android/ant-build/KidFriendly.apk
zipalign -v 4 ../platforms/android/ant-build/CordovaApp-release-unsigned.apk ../platforms/android/ant-build/KidFriendly.apk
