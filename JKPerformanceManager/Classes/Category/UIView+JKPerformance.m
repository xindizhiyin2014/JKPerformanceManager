//
//  UIView+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "UIView+JKPerformance.h"
#import "JKPerformanceMacro.h"
#import <objc/runtime.h>

static const void *track_containerVCKey = &track_containerVCKey;

@implementation UIView (JKPerformance)

- (void)setTrack_containerVC:(__kindof UIViewController *)track_containerVC
{
    objc_setAssociatedObject(self, track_containerVCKey, performance_delay(track_containerVC), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (__kindof UIViewController *)track_containerVC
{
    return performance_force(objc_getAssociatedObject(self, track_containerVCKey));
}
@end
