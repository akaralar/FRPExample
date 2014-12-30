//
//  PhotoViewController.h
//  FRPExample
//
//  Created by Ahmet Karalar on 31/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoModel;

@interface PhotoViewController : UIViewController

@property (nonatomic, readonly) PhotoModel *photoModel;
@property (nonatomic, readonly) NSInteger photoIndex;

- (instancetype)initWithModel:(PhotoModel *)model index:(NSInteger)index;

@end
