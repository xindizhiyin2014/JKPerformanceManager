//
//  JKPerformanceManager.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#ifndef JKPerformanceManager_h
#define JKPerformanceManager_h

typedef id (^PerformanceWeakReference)(void);

static inline PerformanceWeakReference performance_delay(id object)
{
    __weak id weakReference = object;
    return ^{
        return weakReference;
    };
}

static inline id performance_force(PerformanceWeakReference weakReference)
{
    return weakReference ? weakReference() : nil;
}

#endif /* JKPerformanceManager_h */
