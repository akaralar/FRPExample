//
//  FullSizePhotoViewController.m
//  FRPExample
//
//  Created by Ahmet Karalar on 30/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "FullSizePhotoViewController.h"
#import "PhotoModel.h"
#import "PhotoViewController.h"

@interface FullSizePhotoViewController () <UIPageViewControllerDelegate,
                                           UIPageViewControllerDataSource>

@property (nonatomic, readwrite) NSArray *photoModelArray;
@property (nonatomic) UIPageViewController *pageViewController;

@end

@implementation FullSizePhotoViewController

- (instancetype)initWithPhotoModels:(NSArray *)photoModelArray currentPhotoIndex:(NSInteger)index
{
    self = [self init];

    if (!self) {
        return nil;
    }

    self.photoModelArray = photoModelArray;
    self.title = [self.photoModelArray[index] photoName];

    self.pageViewController =
        [[UIPageViewController alloc]
         initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                         options:@{ UIPageViewControllerOptionInterPageSpacingKey : @30 }];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];

    [self.pageViewController setViewControllers:@[[self photoViewControllerForIndex:index]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.pageViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.pageViewController.view];
}

- (PhotoViewController *)photoViewControllerForIndex:(NSInteger)index
{
    if (index >= 0 && index < self.photoModelArray.count) {
        PhotoModel *photoModel = self.photoModelArray[index];
        PhotoViewController *photoController = [[PhotoViewController alloc] initWithModel:photoModel
                                                                                    index:index];

        return photoController;
    }

    return nil;
}

#pragma mark - UIPageViewController, Delegate and DataSource

- (void) pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed
{
    self.title = [[self.pageViewController.viewControllers.firstObject photoModel] photoName];

    [self.delegate userDidScroll:self
                  toPhotoAtIndex:[self.pageViewController.viewControllers.firstObject photoIndex]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    PhotoViewController *controller = (PhotoViewController *)viewController;

    return [self photoViewControllerForIndex:controller.photoIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    PhotoViewController *controller = (PhotoViewController *)viewController;

    return [self photoViewControllerForIndex:controller.photoIndex + 1];
}

@end
