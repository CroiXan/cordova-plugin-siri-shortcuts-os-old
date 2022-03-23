#import "AppDelegate+SiriShortcuts.h"
#import <objc/runtime.h>

static void * UserActivityPropertyKey = &UserActivityPropertyKey;
static NSString *const PLUGIN_NAME = @"SiriShortcuts";

@implementation AppDelegate (siriShortcuts)

- (NSUserActivity *)userActivity {
    return objc_getAssociatedObject(self, UserActivityPropertyKey);
}

- (void)setUserActivity:(NSUserActivity *)activity {
    objc_setAssociatedObject(self, UserActivityPropertyKey, activity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(application:openURL:options:)];
        [self swizzleMethod:@selector(application:continueUserActivity:restorationHandler:)];
    });
}

+ (void)swizzleMethod:(SEL)originalSelector {
    Class class = [self class];
    NSString *selectorString = NSStringFromSelector(originalSelector);
    SEL newSelector = NSSelectorFromString([@"swizzled_" stringByAppendingString:selectorString]);
    SEL defaultSelector = NSSelectorFromString([@"default_" stringByAppendingString:selectorString]);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    Method noopMethod = class_getInstanceMethod(class, defaultSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(originalMethod ?: noopMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (BOOL)default_application:(UIApplication *)app continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    return FALSE;
}

- (BOOL)swizzled_application:(UIApplication *)app continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    BOOL handled = [self swizzled_application:app continueUserActivity:userActivity restorationHandler:restorationHandler];
    NSLog(@"SiriDelegate continueUserActivity");
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"SiriDelegate continueUserActivity bundleIdentifier %@",bundleIdentifier);
    if ([userActivity.activityType isEqualToString:[NSString stringWithFormat:@"%@.shortcut", bundleIdentifier]])
    {
        self.userActivity = userActivity;

        return YES;
    }
}

@end
