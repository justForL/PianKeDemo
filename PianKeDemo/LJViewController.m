//
//  LJViewController.m
//  PianKeDemo
//
//  Created by James on 16/4/22.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LJViewController.h"

@interface LJViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation LJViewController {
    /**
     *  目录Controller
     */
    UITableView   *_menuTableView;
    /**
     *  细节Controller
     */
    UITableView   *_detailTableView;
    /**
     *  原始frame,用于恢复detailController.view
     */
    CGRect         _detailOldFrame;
    
    UIButton      *_ClickBtn;
    /**
     *  判断按钮的点击状态,显示是否恢复初始位置
     */
    BOOL           _isClick;
    
    UITableViewCell   *_lastSelectedCell;
    
    NSString          *_buttonTitle;
}

  static NSString *ID = @"tableViewCell";
/**
 *  初始化对象
 *
 *  @return 初始化对象
 */
- (instancetype)initWithMenuControllerAndDetailControlerWithButtonTitle:(NSString *)buttonTitle {
    if (self = [super init]) {
        //ios9之后推荐的用法
        [self prefersStatusBarHidden];
        //保留用户设置的按钮文字
        _buttonTitle = buttonTitle;
        
        //待自定义cell的时候,动态的约束tablView的高度
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 4 / 5) style:UITableViewStylePlain];
        
        //设置_menuTableView代理数据源
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
        
        _menuTableView.tableFooterView = [[UIView alloc]init];
        [_menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _detailTableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        //设置_detailTableView代理数据源
        _detailTableView.delegate = self;
        _detailTableView.dataSource = self;
        [_detailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];

        //记录初始frame
        _detailOldFrame = _detailTableView.frame;
        //按先后顺序添加view
        [self.view addSubview:_menuTableView];
        [self.view addSubview:_detailTableView];
        
        //初始化button

        _ClickBtn = [[UIButton alloc]init];
        _ClickBtn.frame = CGRectMake(_detailTableView.bounds.size.width - 80, _detailTableView.bounds.size.height - 60, 80, 40);
        
        [_ClickBtn setTitle:_buttonTitle forState:UIControlStateNormal];
        [_ClickBtn sizeToFit];

        [_ClickBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_ClickBtn addTarget:self action:@selector(clickBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_ClickBtn];
        [self.view bringSubviewToFront:_ClickBtn];
        
        
    }
    return self;
}
/**
 *  按钮的点击事件
 */
- (void)clickBtnAction {
    NSLog(@"%s",__func__);
    
    if (!_isClick) {
        CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        [UIView animateWithDuration:0.75 animations:^{
            _detailTableView.frame = rect;
        }];
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _menuTableView.transform = CGAffineTransformIdentity;
        } completion:nil];
        _isClick = YES;
    }else {
        
        [self closeMenuTableView];
    }
    
}
/**
 *  关闭按钮操作
 */
- (void)closeMenuTableView {
    [UIView animateWithDuration:0.75 animations:^{
        _detailTableView.frame = _detailOldFrame;
    }];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _menuTableView.transform = CGAffineTransformMakeScale(1.75, 1.75);
    } completion:^(BOOL finished) {
        
    }];
    _isClick = NO;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:_menuTableView]) {
        
        return self.menuItems.count;
        
    }else if ([tableView isEqual:_detailTableView]) {
        
        return self.detailItems.count;
        
    }else {
        
       return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if ([tableView isEqual:_menuTableView]) {
        //设置cell的选中样式为None
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = self.menuItems[indexPath.row];
        
    }else if ([tableView isEqual:_detailTableView]) {
        
        cell.textLabel.text = self.detailItems[indexPath.row];

    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_menuTableView]) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.textLabel.textColor = [UIColor redColor];
        
        _lastSelectedCell.textLabel.textColor = _lastSelectedCell == cell ? [UIColor redColor] : [UIColor blackColor];
        
        _lastSelectedCell = cell;
        
        [self closeMenuTableView];
        
    }else if ([tableView isEqual:_detailTableView]) {
        
        
        
    }

    
    
    
}
/**
 *  隐藏状态栏
 *
 *  @return 隐藏状态栏
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
