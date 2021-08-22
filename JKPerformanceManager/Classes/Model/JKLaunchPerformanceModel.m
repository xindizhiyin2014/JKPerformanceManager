//
//  JKLaunchPerformanceModel.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKLaunchPerformanceModel.h"
@interface JKLaunchPerformanceModel()
/// 启动时长，单位毫秒
@property (nonatomic, assign) long long during;
@property (nonatomic, copy, readwrite) NSString *element_name;

@end

@implementation JKLaunchPerformanceModel
@synthesize element_type = _element_type;
@synthesize extra = _extra;

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"during"]
        || [propertyName isEqualToString:@"start_time"]
        || [propertyName isEqualToString:@"end_time"]) {
        return YES;
    }
    return NO;
}

#pragma mark - - setter - -
- (void)setElement_type:(NSString *)element_type
{
    if ([element_type isEqualToString:@"init"]
        || [element_type isEqualToString:@"cold"]
        || [element_type isEqualToString:@"hot"]) {
        
    } else {
#if DEBUG
        NSAssert(NO, @"please check element_type!");
#endif
    }
    _element_type = element_type;
}

- (void)setExtra:(NSMutableDictionary *)extra
{
    _extra = extra;
    _extra[@"during"] = @(self.during);
}

- (void)setDuring:(long long)during
{
    _during = during;
    self.extra[@"during"] = @(during);
}

- (void)setEnd_time:(NSTimeInterval)end_time
{
    _end_time = end_time;
    long long during = end_time - self.start_time;
    self.during = during;
}

#pragma mark - - getter - -
- (NSString *)element_name
{
    if (!_element_name) {
        _element_name = @"startup";
    }
    return _element_name;
}

- (NSString *)element_type {
    if (!_element_type) {
        _element_type = @"";
    }
    return _element_type;
}
- (NSMutableDictionary *)extra
{
    if (!_extra) {
        _extra = [NSMutableDictionary new];
    }
    return _extra;
}
@end
