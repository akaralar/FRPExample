//
//  FullSizePhotoViewController.h
//  FRPExample
//
//  Created by Ahmet Karalar on 30/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FullSizePhotoViewControllerDelegate;

@interface FullSizePhotoViewController : UIViewController

@property (nonatomic, readonly) NSArray *photoModelArray;
@property (nonatomic, weak) id<FullSizePhotoViewControllerDelegate> delegate;

- (instancetype)initWithPhotoModels:(NSArray *)photoModelArray currentPhotoIndex:(NSInteger)index;

@end

@protocol FullSizePhotoViewControllerDelegate <NSObject>

- (void)userDidScroll:(FullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index;

@end