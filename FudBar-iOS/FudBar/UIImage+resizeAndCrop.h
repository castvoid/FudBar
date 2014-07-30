//
//  UIImage+resizeAndCrop.h
//  FudBar
//
//  Created by Harry Jones on 30/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (resizeAndCrop)


- (UIImage *)imageByCroppingToSize:(CGSize)size;
- (UIImage *) resizeToSize:(CGSize) newSize thenCropWithRect:(CGRect) cropRect;

@end
