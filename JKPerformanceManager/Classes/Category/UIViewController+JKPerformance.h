//
//  UIViewController+JKPerformance.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/16.
//

#import <UIKit/UIKit.h>
#import "JKPagePerformanceModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JKPerformance)
@property (nonatomic, strong) JKPagePerformanceModel *firstScreen_pagePerformanceModel;
@property (nonatomic, strong) JKPagePerformanceModel *interactive_pagePerformanceModel;
@end

NS_ASSUME_NONNULL_END
