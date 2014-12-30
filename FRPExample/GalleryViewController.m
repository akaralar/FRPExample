//
//  GalleryViewController.m
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "Cell.h"
#import "FullSizePhotoViewController.h"
#import "GalleryFlowLayout.h"
#import "GalleryViewController.h"
#import "PhotoImporter.h"

@interface GalleryViewController () <FullSizePhotoViewControllerDelegate>

@property (nonatomic) NSArray *photosArray;

@end

@implementation GalleryViewController

- (instancetype)init
{
    GalleryFlowLayout *layout = [[GalleryFlowLayout alloc] init];

    self = [self initWithCollectionViewLayout:layout];

    if (!self) {
        return nil;
    }

    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configure self
    self.title = @"Popular on 500px";

    // configure view
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:CellIdentifier];

    // Reactive stuff
    @weakify(self);
    [RACObserve(self, photosArray) subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];

    // load data
    [self loadPopularPhotos];
}

- (void)loadPopularPhotos
{
    [[PhotoImporter importPhotos] subscribeNext:^(id x) {
        self.photosArray = x;
    } error:^(NSError *error) {
        NSLog(@"Couldn't fetch photos from 500px: %@", error);
    }];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                           forIndexPath:indexPath];

    [cell setPhotoModel:self.photosArray[indexPath.item]];

    return cell;
}

- (void)      collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FullSizePhotoViewController *controller =
        [[FullSizePhotoViewController alloc] initWithPhotoModels:self.photosArray
                                               currentPhotoIndex:indexPath.item];

    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - FullSizePhotoViewControllerDelegate

- (void)userDidScroll:(FullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
}

@end
