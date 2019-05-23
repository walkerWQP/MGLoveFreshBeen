//
//  HomeCollectionHeaderView.h
//  MGLoveFreshBeen
//
//  Created by ming on 16/7/17.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - HomeCollectionHeaderView
@interface HomeCollectionHeaderView : UICollectionReusableView

/** 头部标题 */
@property (nonatomic,weak) UILabel *sectionHTitleLabel;

@end



#pragma mark - HomeCollectionFooterView
@interface HomeCollectionFooterView : UICollectionReusableView

/** 尾部标题 */
@property (nonatomic,weak) UIButton *lookMoreBtn;

@end