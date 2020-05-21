/**
* This plugin is for the situation where previous versions of the app use WKWebView using the HTTP protocol, but this version of the app uses the FILE protocol.
* LocalStorage files are migrated ONCE.
* Code Adapted from
* https://github.com/MaKleSoft/cordova-plugin-migrate-localstorage and
* https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m
*/

#import "MigrateLocalStorage.h"

#define TAG @"\nMigrateLS"

#define ORIG_FOLDER @"WebKit/WebsiteData/LocalStorage"
#define ORIG_LS_FILEPATH @"WebKit/WebsiteData/LocalStorage/http_localhost_8080.localstorage"
#define ORIG_LS_CACHE @"Caches/http_localhost_8080.localstorage"
#define TARGET_LS_FILEPATH @"WebKit/WebsiteData/LocalStorage/file__0.localstorage"
#define ORIG_IDB_FILEPATH @"WebKit/WebsiteData/LocalStorage/___IndexedDB/http_localhost_8080"
#define TARGET_IDB_FILEPATH @"WebKit/WebsiteData/IndexedDB/file__0"

@implementation MigrateLocalStorage

/**
* Moves an item from src to dest. Works only if dest file has not already been created.
*/
- (BOOL) move:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // Bail out if source file does not exist // not really necessary <- error case already handle by fileManager copyItemAtPath
    if (![fileManager fileExistsAtPath:src]) {
        return NO;
    }

    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) { // not really necessary <- error case already handle by fileManager copyItemAtPath
        return NO;
    }

    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }

    // move src to dest
    return [fileManager moveItemAtPath:src toPath:dest error:nil];
}

/**
* Gets filepath of localStorage file we want to migrate from
*/
- (NSString*) resolveOriginalLSFile
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* original;
    NSString* originalLSFilePath = [appLibraryFolder stringByAppendingPathComponent:ORIG_LS_FILEPATH];

    if ([[NSFileManager defaultManager] fileExistsAtPath:originalLSFilePath]) {
        original = originalLSFilePath;
    } else {
        original = [appLibraryFolder stringByAppendingPathComponent:ORIG_LS_CACHE];
    }
    return original;
}

/**
* Gets filepath of localStorage file we want to migrate to
*/
- (NSString*) resolveTargetLSFile
{
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* target = [appLibraryFolder stringByAppendingPathComponent:TARGET_LS_FILEPATH];

    #if TARGET_IPHONE_SIMULATOR
        // the simulator squeezes the bundle id into the path
        NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        bundleIdentifier = [@"/" stringByAppendingString:bundleIdentifier];
            
        NSMutableString* targetMutable = [NSMutableString stringWithString:target];
        NSRange range = [targetMutable rangeOfString:@"WebKit"];
        long idx = range.location + range.length;
        [targetMutable insertString:bundleIdentifier atIndex:idx];
    
        return targetMutable;

    #endif

    return target;
}

/**
* Checks if localStorage file should be migrated. If so, migrate.
* NOTE: Will only migrate data if there is no localStorage data for the file:// protocol of WKWebView. This only happens when the file:// protocol is loaded in WKWebView for the first time.
*/
- (BOOL) migrateLocalStorage
{
    NSString* original = [self resolveOriginalLSFile];
    NSString* target = [self resolveTargetLSFile];
    
    // Only copy data if no target exists.
    if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSLog(@"%@ Migrating existing localstorage data from HTTP to FILE protocol.", TAG);
        BOOL success1 = [self move:original to:target];
        BOOL success2 = [self move:[original stringByAppendingString:@"-shm"] to:[target stringByAppendingString:@"-shm"]];
        BOOL success3 = [self move:[original stringByAppendingString:@"-wal"] to:[target stringByAppendingString:@"-wal"]];
        NSLog(@"%@ Migration status %d %d %d", TAG, success1, success2, success3);
        return success1 && success2 && success3;
    }
    else {
        return NO;
    }
}

- (void)pluginInitialize
{
    [self migrateLocalStorage];
}

@end
