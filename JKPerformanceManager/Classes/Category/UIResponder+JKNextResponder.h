//
//  UIResponder+JKNextResponder.h
//  Pods
//
//  Created by admin on 2020/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (JKNextResponder)

@property (nonatomic, weak, nullable) UIResponder *JK_nextResponder;

@end

NS_ASSUME_NONNULL_END
