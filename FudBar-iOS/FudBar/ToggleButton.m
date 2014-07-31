//
//  CircleButton.m
//  FudBar
//
//  Created by Harry Jones on 31/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "ToggleButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation ToggleButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
    self.backgroundColor = self.deselectedBackgroundColor;
}

- (void)buttonPressed{
    self.selected = !self.selected;
    
    
    if ([self.delegate respondsToSelector:@selector(toggleButtonPressed:)]){
        [self.delegate performSelector:@selector(toggleButtonPressed:) withObject:self];
    }
    
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = self.selected ? self.selectedBackgroundColor.CGColor : self.deselectedBackgroundColor.CGColor;
    circleShape.lineWidth = 2.0;
    
    [self.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

- (void)setColor:(UIColor *)color forState:(UIControlState)state
{
    if (state == UIControlStateNormal){
        _deselectedBackgroundColor = color;
    }else if (state == UIControlStateSelected){
        _selectedBackgroundColor = color;
    }
    UIView *colorView = [[UIView alloc] initWithFrame:self.frame];
    colorView.backgroundColor = color;
    
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:colorImage forState:state];
}

@end
