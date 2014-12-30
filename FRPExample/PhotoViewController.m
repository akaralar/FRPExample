//
//  PhotoViewController.m
//  FRPExample
//
//  Created by Ahmet Karalar on 31/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "PhotoImporter.h"
#import "PhotoModel.h"
#import "PhotoViewController.h"
#import "SVProgressHUD.h"

@interface PhotoViewController ()

@property (nonatomic, readwrite) PhotoModel *photoModel;
@property (nonatomic, readwrite) NSInteger photoIndex;

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation PhotoViewController

- (instancetype)initWithModel:(PhotoModel *)model index:(NSInteger)index
{
    self = [self init];

    if (!self) {
        return nil;
    }

    self.photoModel = model;
    self.photoIndex = index;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    RAC(imageView, image) = [RACObserve(self.photoModel, fullSizedData) map:^id (id value) {
        return [UIImage imageWithData:value];
    }];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [SVProgressHUD show];

    [[PhotoImporter fetchPhotoDetails:self.photoModel] subscribeError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
    } completed:^{
        [SVProgressHUD dismiss];
    }];
}

@end
