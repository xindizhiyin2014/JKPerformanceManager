//
//  JKPagePerformanceModel.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKPerformanceModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * _Nonnull const JKPageTypeFirstScreen = @"firstScreen";
static NSString * _Nonnull const JKPageTypeInteractive = @"interactive";

@interface JKPagePerformanceModel : JKPerformanceModel

/// 元素名称，唯一标识
@property (nonatomic, copy, readonly) NSString *element_name;

/// 首屏"firstScreen", 可交互"interactive"
@property (nonatomic, copy) NSString *element_type;

// 辅助字段,会自动封装进extra内

/// iOS 为：VC的名称
@property (nonatomic, copy) NSString *page;

/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval start_time;
/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval end_time;

@end


NS_ASSUME_NONNULL_END
