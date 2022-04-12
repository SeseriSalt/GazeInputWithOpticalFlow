//
//  openCV.h
//  Vision Face Detection
//
//  Created by 雑賀友 on 2020/10/22.
//  Copyright © 2020 Droids On Roids. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface openCV : NSObject
-(void)avop:(UIImage *)previmg :(UIImage *)nextimg :(double *)array;
-(void)avopLR:(UIImage *)previmg :(UIImage *)nextimg :(double *)array;
@end

NS_ASSUME_NONNULL_END

