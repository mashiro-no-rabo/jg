//
//  JGImagePoolViewController.m
//  JikanGachou
//
//  Created by Xhacker Liu on 12/6/2013.
//  Copyright (c) 2013 TeaWhen. All rights reserved.
//

#import "JGImagePoolViewController.h"

@interface JGImagePoolViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;

@property (nonatomic) NSMutableArray *selectedPhotoInfos;

@end

@implementation JGImagePoolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedPhotoInfos = [@[] mutableCopy];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedPhotoInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photoInfo = self.selectedPhotoInfos[indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = photoInfo[@"image"];
    
    return cell;
}

- (void)reload
{
    [self.collectionView reloadData];
    self.selectedCountLabel.text = [NSString stringWithFormat:@"已选 %u 张", self.selectedPhotoInfos.count];
}

- (void)addPhotoInfo:(NSDictionary *)photoInfo
{
    [self.selectedPhotoInfos addObject:photoInfo];
    
    [self reload];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPhotoInfos.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removePhotoInfo:(NSDictionary *)photoInfo
{
    [self.selectedPhotoInfos removeObject:photoInfo];
    
    [self reload];
}

@end
