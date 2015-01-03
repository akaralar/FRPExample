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
#import "RACDelegateProxy.h"

@interface GalleryViewController ()

@property (nonatomic) NSArray *photosArray;

@property (nonatomic) id collectionViewDelegate;

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

    RACDelegateProxy *viewControllerDelegate =
        [[RACDelegateProxy alloc] initWithProtocol:@protocol(FullSizePhotoViewControllerDelegate)];
    [[viewControllerDelegate rac_signalForSelector:@selector(userDidScroll:toPhotoAtIndex:)
                                      fromProtocol:@protocol(FullSizePhotoViewControllerDelegate)]
     subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        [self.collectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[tuple.second integerValue]
                                                     inSection:0]
                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                        animated:NO];
    }];

    self.collectionViewDelegate =
        [[RACDelegateProxy alloc] initWithProtocol:@protocol(UICollectionViewDelegate)];

    [[self.collectionViewDelegate
      rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:)]
     subscribeNext:^(RACTuple *arguments) {
        @strongify(self);

        NSIndexPath *indexPath = arguments.second;
        FullSizePhotoViewController *controller =
            [[FullSizePhotoViewController alloc] initWithPhotoModels:self.photosArray
                                                   currentPhotoIndex:indexPath.item];
        controller.delegate = (id<FullSizePhotoViewControllerDelegate>)viewControllerDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    }];

    // long way to do things
//    RACSignal *photoSignal = [PhotoImporter importPhotos];
//    RACSignal *photosLoaded = [photoSignal catch:^RACSignal *(NSError *error) {
//        NSLog(@"Couldn't fetch photos from 500px: %@", error);
//        return [RACSignal empty];
//    }];
//
//    RAC(self, photosArray) = photosLoaded;
//    [photosLoaded subscribeCompleted:^{
//        @strongify(self);
//        [self.collectionView reloadData];
//    }];

    // shorthand for above commented code
    RAC(self, photosArray) = [[[[PhotoImporter importPhotos] doCompleted:^{
        @strongify(self);
        [self.collectionView reloadData];
    }] logError] catchTo:[RACSignal empty]];

    // load data
//    [self loadPopularPhotos];
}

//- (void)loadPopularPhotos
//{
//    [[PhotoImporter importPhotos] subscribeNext:^(id x) {
//        self.photosArray = x;
//    } error:^(NSError *error) {
//        NSLog(@"Couldn't fetch photos from 500px: %@", error);
//    }];
//}

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

@end
