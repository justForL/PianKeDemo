//
//  LJViewController.h
//  PianKeDemo
//
//  Created by James on 16/4/22.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJViewController : UIViewController
/**
 *  menu的条数
 */
@property (nonatomic, strong) NSArray<NSString *> *menuItems;

@property (nonatomic, strong) NSArray *detailItems;



- (instancetype)initWithMenuControllerAndDetailControlerWithButtonTitle:(NSString *)buttonTitle;


@end
