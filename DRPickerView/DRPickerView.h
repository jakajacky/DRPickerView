//
//  DRPickerView.h
//  LinkTop
//
//  Created by XiaoQiang on 2017/11/16.
//  Copyright © 2017年 XiaoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PTDatePicker,
    PTPickerView,
} PickerType;

@interface DRPickerView : UIView

@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, assign, readonly) PickerType type;
@property (nonatomic, strong) NSString *unit; // 单位 type==PTPickerView时有用

- (instancetype)initWithType:(PickerType)type completion:(void(^)(id result))complete;
- (void)show;
- (void)hideWithCompletion:(void(^)(void))complete;
@end
