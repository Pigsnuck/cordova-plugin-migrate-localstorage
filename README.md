# NOTE!

This fork implements a different use-case to the original plugin, and handles the case where the app ALREADY used WKWebView but is switching from the HTTP scheme to the FILE scheme.

In this case, we need to move the localStorage across from the HTTP files to the files for the FILE scheme.

# Migrate LocalStorage

This plugin is an adaptation of
[cordova-plugin-wkwebview-engine](https://github.com/jairemix/cordova-plugin-migrate-localstorage)
to allow for the migration of LocalStorage when using [cordova-plugin-wkwebview-engine]
(https://github.com/ionic-team/apache/cordova-plugin-wkwebview-engine) to persist LocalStorage data when migrating from the HTTP scheme to the FILE scheme using for apps already using WKWebView. All related files will be moved automatically on first install so the user can simply pick up where they left off.

## How to use

Simply add the plugin to your cordova project via the cli:
```sh
cordova plugin add https://github.com/pigsnuck/cordova-plugin-migrate-localstorage
```

## Notes

- LocalStorage files are only copied over once and only if no LocalStorage data exists for `WKWebView`
yet. This means that if you've run your app with `WKWebView` before this plugin will likely not work.
To test if data is migrated over correctly:
    1. Delete the app from your emulator or device
    2. Remove the `cordova-plugin-wkwebview-engine` and `cordova-plugin-migrate-localstorage` plugins
    3. Run your app and store some data in LocalStorage
    4. Add both plugins back
    5. Run your app again. Your data should still be there!

- Once the data is copied over, it is not being synced back to `UIWebView` so any changes done in
`WKWebView` will not persist should you ever move back to `UIWebView`. If you have a problem with this,
let us know in the issues section!

## Background

One of the drawbacks of migrating Cordova apps to `WKWebView` is that LocalStorage data does
not persist between the two. Unfortunately,
[cordova-plugin-wkwebview-engine](https://github.com/apache/cordova-plugin-wkwebview-engine) and
[cordova-plugin-ionic-webview](https://github.com/ionic-team/cordova-plugin-ionic-webview)
do not offer a solution for this out of the box.
