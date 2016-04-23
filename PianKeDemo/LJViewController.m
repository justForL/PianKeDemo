//
//  LJViewController.m
//  PianKeDemo
//
//  Created by James on 16/4/22.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LJViewController.h"

@interface LJViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation LJViewController {
    UIView        *_dvc;
    /**
     *  目录Controller
     */
    UITableView   *_menuTableView;
    /**
     *  细节Controller
     */
    UITableView   *_detailTableView;
    
    UICollectionView  *_collectionView;
    /**
     *  原始frame,用于恢复detailController.view
     */
    CGRect         _dvcOldFrame;
    
    UIButton      *_ClickBtn;
    
    UIView        *_textView;
    /**
     *  判断按钮的点击状态,显示是否恢复初始位置
     */
    BOOL           _isClick;
    
    UITableViewCell   *_lastSelectedCell;
    
    NSString          *_buttonTitle;
}

  static NSString *ID = @"tableViewCell";
  static NSString *CollectionViewID = @"CollectionViewID";
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
        

        [self prepareMenuView];
        
        [self prepareDetailView];

        //记录初始frame
        _dvcOldFrame = _dvc.frame;
        //按先后顺序添加view
        [self.view addSubview:_menuTableView];
        [self.view addSubview:_dvc];
        
        //初始化button

        [self prepareTriggerButton];

        [self.view addSubview:_ClickBtn];
        [self.view bringSubviewToFront:_ClickBtn];
        
        
    }
    return self;
}

- (void)prepareMenuView {
    //待自定义cell的时候,动态的约束tablView的高度
    _menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 4 / 5) style:UITableViewStylePlain];
    
    //设置_menuTableView代理数据源
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    _menuTableView.tableFooterView = [[UIView alloc]init];
    [_menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

- (void)prepareDetailView {
    
    _dvc = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 45, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 45) style:UITableViewStylePlain];
    
    //flowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(_detailTableView.bounds.size.width, _detailTableView.bounds.size.height);
    
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    //collectionView
    _collectionView = [[UICollectionView alloc]initWithFrame:_detailTableView.frame collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewID];
    
    
    
//    _dvc.backgroundColor = [UIColor greenColor];
    
    _textView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
            _textView.backgroundColor = [UIColor whiteColor];
    [_dvc addSubview: _textView];
    [self addTextLabelToSuperView:_textView];
    

    
    [_dvc addSubview:_collectionView];
    
    [_collectionView addSubview:_detailTableView];
    //设置_detailTableView代理数据源
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    [_detailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
}

- (void)prepareTriggerButton {
    _ClickBtn = [[UIButton alloc]init];
    _ClickBtn.frame = CGRectMake(_detailTableView.bounds.size.width - 80, _detailTableView.bounds.size.height - 60, 80, 40);
    
    [_ClickBtn setTitle:_buttonTitle forState:UIControlStateNormal];
    [_ClickBtn sizeToFit];
    
    [_ClickBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_ClickBtn addTarget:self action:@selector(clickBtnAction) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  添加label到superView
 *
 *  @param superView 父视图
 */
- (void)addTextLabelToSuperView:(UIView *)superView {
    
    NSArray *items = @[@"碎片",@"今日",@"动态",];
    
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 3;
    
    for (int i = 0; i < items.count; ++i) {
        UILabel *textLabel = [[UILabel alloc]init];
        textLabel.text = items[i];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.frame = CGRectMake(itemWidth * i, 0, itemWidth, 45);
        textLabel.tag = i ;
        textLabel.userInteractionEnabled = YES;
        [superView addSubview:textLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        [textLabel addGestureRecognizer:tap];
        
    }
}


- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    NSLog(@"%zd",tap.view.tag);
    

    [self textLabelColorWithNum:tap.view.tag];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:tap.view.tag inSection:0];
    
    [_collectionView selectItemAtIndexPath:indexpath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
}


/**
 *  按钮的点击事件
 */
- (void)clickBtnAction {
    NSLog(@"%s",__func__);
    
    if (!_isClick) {
        CGRect rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        [UIView animateWithDuration:0.75 animations:^{
            _dvc.frame = rect;
        }];
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _menuTableView.transform = CGAffineTransformIdentity;
        } completion:nil];
        _dvc.userInteractionEnabled = NO;
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
        _dvc.frame = _dvcOldFrame;
    }];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _menuTableView.transform = CGAffineTransformMakeScale(1.75, 1.75);
    } completion:^(BOOL finished) {
        _dvc.userInteractionEnabled = YES;
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

#pragma  mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];

    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger num = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    [self textLabelColorWithNum:num];
    
    
}

- (void)textLabelColorWithNum:(NSInteger)num {
    for (UILabel *label in _textView.subviews) {
        if (label.tag == num) {
            label.textColor = [UIColor greenColor];
        }else {
            label.textColor = [UIColor blackColor];
        }
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
