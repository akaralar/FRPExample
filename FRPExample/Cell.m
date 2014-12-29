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
@property (nonatomic) RACDisposable *subscription;

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

    return self;
}

- (void)setPhotoModel:(PhotoModel *)model
{
    self.subscription = [[[RACObserve(model, thumbnailData) filter:^BOOL (id value) {
        return value != nil;
    }] map:^id (id value) {

        return [UIImage imageWithData:value];
    }] setKeyPath:@keypath(self.imageView, image) onObject:self.imageView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.subscription dispose];
    self.subscription = nil;
}

@end
