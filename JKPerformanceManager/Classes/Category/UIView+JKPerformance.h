//
//  UIView+JKPerformance.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JKPerformance)
@property (nonatomic, weak, nullable) __kindof UIViewController *track_containerVC;
@end

NS_ASSUME_NONNULL_END
