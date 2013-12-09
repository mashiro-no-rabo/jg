//
//  JGImagePoolViewController.h
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGImagePoolViewController : UIViewController

- (void)addPhotoInfo:(NSDictionary *)photoInfo;
- (void)removePhotoInfo:(NSDictionary *)photoInfo;
- (BOOL)hasPhotoInfo:(NSDictionary *)photoInfo;

@end
