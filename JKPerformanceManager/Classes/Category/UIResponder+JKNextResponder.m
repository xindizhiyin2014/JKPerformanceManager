//
//  UIResponder+JKNextResponder.m
//  Pods
//
//  Created by admin on 2020/7/13.
//

#import "UIResponder+JKNextResponder.h"
#import <objc/runtime.h>
#import "JKPerformanceMacro.h"

static const void *kJKNextResponder = &kJKNextResponder;

@implementation UIResponder (JKNextResponder)

- (void)setJK_nextResponder:(UIResponder *)JK_nextResponder
{
#if DEBUG
    // 在设置JK_nextResponder，不希望为空，也不应该为空
    // 如果后续出现设置为空，可考虑将此断言去掉
    NSAssert(JK_nextResponder, @"设置的JK_nextResponder不能为空哦");
#endif
    objc_setAssociatedObject(self, kJKNextResponder, performance_delay(JK_nextResponder), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable UIResponder *)JK_nextResponder
{
    if (self.nextResponder) {
        return self.nextResponder;
    } else {
        return performance_force(objc_getAssociatedObject(self, kJKNextResponder));
    }
}

@end
