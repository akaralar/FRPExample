//
//  Cell.m
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "Cell.h"
#import "PhotoModel.h"

@interface Cell ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation Cell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    self.backgroundColor = [UIColor darkGrayColor];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.contentView addSubview:imageView];
    self.imageView = imageView;

    RAC(self.imageView, image) = [[RACObserve(self, photoModel.thumbnailData) ignore:nil]
                                  map:^id (id value) {
        return [UIImage imageWithData:value];
    }];

    return self;
}

@end
