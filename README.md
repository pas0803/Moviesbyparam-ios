# MovieNova (iOS)

Minimal iOS app that opens https://movienova.sc/ in a full-screen web view.

## Build the IPA

1. Push this folder's contents to the **root** of a new GitHub repo
   (`.github/workflows/build-ios.yml` must be at the top level).
2. Open **Actions → Build iOS IPA** (runs automatically on push, or use Run workflow).
3. Download the **MovieNova-ipa** artifact at the bottom of the run page and unzip it to get `MovieNova.ipa`.

The IPA is unsigned. Install it with a sideloading tool (AltStore, Sideloadly) which signs it
with your own Apple ID.

## Change the link

Edit `startURL` in `MovieNova/ViewController.swift`.
