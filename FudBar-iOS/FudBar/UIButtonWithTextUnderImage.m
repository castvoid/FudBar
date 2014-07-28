//
//  UIButtonWithTextUnderImage.m
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "UIButtonWithTextUnderImage.h"

@implementation UIButtonWithTextUnderImage

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), 0.0f, frame.size.width, frame.size.height);
    self.imageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), self.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
}

@end
