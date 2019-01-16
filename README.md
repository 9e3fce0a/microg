This is a community supported repo to support integration of [microG](https://microg.org/) with RattlesnakeOS. The author of RattlesnakeOS doesn't recommend the use of microG, but since it's a highly requested feature I wanted to at least host it in a known place where others can help contribute. It uses the required signature spoofing patch and includes a subset of prebuilt packages from here: https://github.com/lineageos4microg/android_prebuilts_prebuiltapks.

I have also included a fingerprint spoofing patch for compatibility with Google's SafetyNet Attestation API. The script was derived from this comment by the developer of RattlesnakeOS: https://github.com/dan-v/rattlesnakeos-stack/issues/64#issuecomment-439794086 and this script written by packetup: https://github.com/packetup/android_shellscripts/blob/master/00002-modify-build-fingerprint.sh.

In addition to the patch I have included a modified DroidGuard APK from packetup's repo here: https://github.com/packetup/android_prebuilts_prebuiltapks/blob/master/DroidGuard/org.microg.gms.droidguard-4.apk, originally found here: https://nanolx.org/fdroid/repo/DroidGuard_0.apk. This APK is pre-built with a custom patch applied at https://github.com/microg/android_packages_apps_GmsCore/issues/638#issuecomment-428640487.

I have also chosen to include the latest version of Yalp Store found here: https://github.com/yeriomin/YalpStore/releases/tag/0.45. The APK and privapp-permissions have been taken from the "yalp-store-ota-contemporary-45.zip" and the Android.mk was written by me. This enables installation of split APK's like Google Maps.

## How to
Add the following to end of your `rattlesnakeos-stack` config file.
```
[[custom-patches]]https://nanolx.org/fdroid/repo/DroidGuard_0.apk
patches = ["10004-microg-sigspoof.patch"]
repo = "https://github.com/Hammergrat7/microg"

[[custom-scripts]]
scripts = ["90004-modify-build-fingerprint.sh"]
repo = "https://github.com/Hammergrat7/microg"

[[custom-prebuilts]]
modules = ["DroidGuard","GmsCore","GsfProxy","YalpStore","FakeStore","com.google.android.maps.jar"]
repo = "https://github.com/Hammergrat7/microg"
```

A few points about the microG setup. Due to the way patches are applied in the stack, if you try to combine other patches, the build may fail. The combination of this with other patches hasn't been tested. The first time you boot, open the microG app and do the self-test. Give it the permissions and add location backends. If it still complains that network location is not enabled, you need to toggle the location from main android settings once for it to work. Ideally, you should get all check boxes after that. Finally, in Chromium, go to site settings, and disable the location permission for google.com; it causes crashes in the microG setup.

## Contributors
* https://github.com/pgera
* https://github.com/packetup
* https://github.com/dan-v
* https://github.com/Riamse
