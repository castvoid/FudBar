//
//  CircleButton.h
//  FudBar
//
//  Created by Harry Jones on 31/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToggleButtonDelegate <NSObject>

@optional
- (void)toggleButtonPressed:(UIButton*)button;

@end



@interface ToggleButton : UIButton

- (void)buttonPressed;
- (void)setColor:(UIColor *)color forState:(UIControlState)state;

@property (nonatomic) UIColor *deselectedBackgroundColor;
@property (nonatomic) UIColor *selectedBackgroundColor;
@property (nonatomic) NSObject<ToggleButtonDelegate> *delegate;

@end
