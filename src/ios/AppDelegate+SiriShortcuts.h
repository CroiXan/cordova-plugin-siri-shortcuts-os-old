#import "AppDelegate.h"
#import <Cordova/CDVPlugin.h>

@interface AppDelegate (siriShortcuts)
    - (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler;
    @property (nonatomic, strong) IBOutlet NSUserActivity* userActivity;
@end
