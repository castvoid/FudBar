//
//  DKCircleButton.m
//  DKCircleButton
//
//  Created by Dmitry Klimkin on 23/4/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKCircleButton.h"

#define DKCircleButtonBorderWidth 3.0f

@interface DKCircleButton ()

@property (nonatomic, strong) UIView *highLightView;

@end

@implementation DKCircleButton

@synthesize highLightView = _highLightView;
@synthesize animateTap = _animateTap;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _highLightView = [[UIView alloc] initWithFrame:frame];
        
        _highLightView.userInteractionEnabled = YES;
        _highLightView.alpha = 0;
        _highLightView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        _animateTap = YES;
        
        self.clipsToBounds = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [self addSubview:_highLightView];        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateMaskToBounds:self.bounds];
}

- (void)updateMaskToBounds:(CGRect)maskBounds {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
    
    maskLayer.bounds = maskBounds;
    maskLayer.path = maskPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGPoint point = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
    maskLayer.position = point;
    
    [self.layer setMask:maskLayer];
    
    self.layer.cornerRadius = CGRectGetHeight(maskBounds) / 2.0;
    
    self.highLightView.frame = self.bounds;
}

- (void)triggerAnimateTap {
    
    if (self.animateTap == NO) {
        return;
    }
    
    
    
    // Emitted circle
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];

    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = self.backgroundColor.CGColor;
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
    animation.duration = 0.35f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

- (void)setImage:(UIImage *)image animated: (BOOL)animated {
    
    [super setImage:nil forState:UIControlStateNormal];
    [super setImage:image forState:UIControlStateSelected];
    [super setImage:image forState:UIControlStateHighlighted];
    
    if (animated) {
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        tmpImageView.image = image;
        tmpImageView.alpha = 0;
        tmpImageView.backgroundColor = [UIColor clearColor];
        tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:tmpImageView];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            tmpImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [super setImage:image forState:UIControlStateNormal];
            [tmpImageView removeFromSuperview];
        }];
    } else {
        [super setImage:image forState:UIControlStateNormal];
    }
}

@end
