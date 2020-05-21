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
