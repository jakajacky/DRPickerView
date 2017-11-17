//
//  DRPickerView.m
//  LinkTop
//
//  Created by XiaoQiang on 2017/11/16.
//  Copyright © 2017年 XiaoQiang. All rights reserved.
//

#import "DRPickerView.h"
#import "TimeInterval2DateString.h"
#define kPickerMargin 10
#define kPickerHeight ((200.0/667)*self.height)
#define kCAAnimationDuration 0.5
#define kFadeInDuration 0.3

typedef void(^DismissDone)(void);
typedef void(^ConfirmDone)(id result);

@interface DRPickerView ()<CAAnimationDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *unit_l;

@property (copy,   nonatomic) DismissDone dismissDone;
@property (copy,   nonatomic) ConfirmDone confirmDone;

@end

@implementation DRPickerView

- (instancetype)initWithType:(PickerType)type completion:(void(^)(id result))complete {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _confirmDone = complete;
        _type = type;
        [self setupBackgroundView];
        [self setupContentView];
        [self setupActionView];
        if (type==PTDatePicker) {
            [self setupDatePickerviews];
        }
        else {
            [self setupPickerviews];
        }
    }
    return self;
}

- (void)setupBackgroundView {
    _backgroundView = [[UIView alloc] initWithFrame:self.frame];
    
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.3;
    [self addSubview:_backgroundView];
    
    [_backgroundView autoPinEdgesToSuperviewEdges];
}

- (void)setupContentView {
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(kPickerMargin, self.height-kPickerHeight-kPickerMargin, self.width-2*kPickerMargin, kPickerHeight)];
    _contentView.backgroundColor = UIColorHex(#ffffff);
    [self addSubview:_contentView];
    
    [_contentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kPickerMargin];
    [_contentView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kPickerMargin];
    [_contentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPickerMargin];
    [_contentView autoSetDimension:ALDimensionHeight toSize:kPickerHeight];
}

- (void)setupActionView {
    UIView *action_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
    action_bg.backgroundColor = UIColorHex(#ffffff);
    [_contentView addSubview:action_bg];
    action_bg.layer.shadowColor = UIColorHex(#000000).CGColor;
    action_bg.layer.shadowOpacity = 0.3;
    action_bg.layer.shadowOffset = CGSizeMake(0, 1);
    [action_bg autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [action_bg autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [action_bg autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [action_bg autoSetDimension:ALDimensionHeight toSize:30];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancel addTarget:self action:@selector(cancelDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame = CGRectMake(10, 5, 50, 20);
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:UIColorHex(#4A90E2) forState:UIControlStateNormal];
    [action_bg addSubview:cancel];
    [cancel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [cancel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [cancel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [cancel autoSetDimension:ALDimensionWidth toSize:50];
    
    UIButton *confirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirm addTarget:self action:@selector(confirmDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    confirm.frame = CGRectMake(10, 5, 50, 20);
    [confirm setTitle:@"确定" forState:UIControlStateNormal];
    [confirm setTitleColor:UIColorHex(#ffffff) forState:UIControlStateNormal];
    [confirm setBackgroundColor:UIColorHex(#4A90E2)];
    [action_bg addSubview:confirm];
    [confirm autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [confirm autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [confirm autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [confirm autoSetDimension:ALDimensionWidth toSize:50];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _title.text = @"";
    _title.font = [UIFont systemFontOfSize:14];
    _title.textColor = UIColorHex(#999999);
    [action_bg addSubview:_title];
    [_title autoCenterInSuperview];
}

- (void)setupDatePickerviews {
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, _contentView.width, _contentView.height-30)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
   
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger maxAge = 20;
    NSInteger minAge = 80;
    NSInteger currentYear = [[currentDateStr substringToIndex:4] integerValue];
    NSInteger maxYear = currentYear - maxAge;
    NSInteger minYear = currentYear - minAge;
    
    NSString *maxDateStr = [NSString stringWithFormat:@"%ld-01-01",maxYear];
    NSDate *maxDate = [dateFormatter dateFromString:maxDateStr];
    
    NSString *minDateStr = [NSString stringWithFormat:@"%ld-01-01",minYear];
    NSDate *minDate = [dateFormatter dateFromString:minDateStr];
    
    _datePicker.maximumDate = maxDate;
    _datePicker.minimumDate = minDate;
    
    [_contentView addSubview:_datePicker];
}

- (void)setupPickerviews {
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, _contentView.width, _contentView.height-30)];
    _picker.delegate = self;
    _picker.delegate = self;
    [_contentView addSubview:_picker];
    [_picker autoAlignAxis:ALAxisVertical toSameAxisOfView:_contentView withOffset:-10];
    [_picker autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_contentView withOffset:30];
    [_picker autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_contentView];
    [_picker autoSetDimension:ALDimensionWidth toSize:50];
    
    _unit_l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    _unit_l.text = self.unit;
    _unit_l.font = [UIFont systemFontOfSize:14];
    _unit_l.textColor = UIColorHex(#999999);
    [_contentView addSubview:_unit_l];
    
    [_unit_l autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_picker];
    [_unit_l autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_picker withOffset:5];
}

- (void)setUnit:(NSString *)unit {
    _unit = unit;
    _unit_l.text = self.unit;
}

/**
 * 弹出
 */
- (void)show {
    if (_picker) {
        [_picker selectRow:22 inComponent:0 animated:YES];
        _title.text = self.datasource[22];
    }
    else {
        _title.text = @"1997-01-01";
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0){
        
        NSInteger index;
        index = [windowViews count]-1;
    
        UIView *subView = [windowViews objectAtIndex:index];
        for(UIView *aSubView in subView.subviews)
        {
            [aSubView.layer removeAllAnimations];
        }
        
        [subView addSubview:self];
        [self autoPinEdgesToSuperviewEdges];
        [self showBackground];
        [self showAlertAnimation];
    }
}

/**
 * 隐藏
 */
- (void)hideWithCompletion:(void(^)(void))complete {
    _dismissDone = complete;
    [self hideAlertAnimation];
}

-(void)showAlertAnimation
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = kFadeInDuration;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight*2.0/3.0, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight*1.0/3.0, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -10, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0)]];
    animation.values = values;
    
    [_contentView.layer addAnimation:animation forKey:nil];
}

- (void)showBackground
{
    _backgroundView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:kFadeInDuration];
    _backgroundView.alpha = 0.6;
    [UIView commitAnimations];
}

- (void)hideAlertAnimation {
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = kFadeInDuration;
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    animation.fillMode = kCAFillModeRemoved;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -10, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight*1.0/3.0, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight*2.0/3.0, 0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, kPickerHeight, 0)]];
    animation.values = values;
    
    [_contentView.layer addAnimation:animation forKey:nil];
    
}

- (void)hideBackground
{
    NSTimeInterval animationDuration = kFadeInDuration;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:animationDuration];
    _contentView.alpha = 0.0;
    _backgroundView.alpha = 0.0;
    [UIView commitAnimations];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    [self hideBackground];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeAllSubviews];
    [self removeFromSuperview];
    _dismissDone();
}

#pragma mark - UIPickerView Delegate&DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.datasource.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.datasource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _title.text = self.datasource[row];
}

#pragma mark - 控件响应事件

- (void)cancelDidClicked:(UIButton *)sender {
    [self hideWithCompletion:^{
        
    }];
}

- (void)confirmDidClicked:(UIButton *)sender {
    if (_confirmDone) {
        if (_type==PTDatePicker) {
            _confirmDone(_datePicker.date);
        }
        else {
            _confirmDone(self.title.text);
        }
    }
    [self hideWithCompletion:^{
        
    }];
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
    _title.text = [TimeInterval2DateString TimeIntervalToDateString:[_datePicker.date timeIntervalSince1970] withFormatter:@"yyyy-MM-dd"];
}

- (void)dealloc {
    NSLog(@"DRPickerView 释放！");
    _backgroundView = nil;
    _contentView = nil;
    _datePicker = nil;
    _picker = nil;
}

@end
