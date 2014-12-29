//
//  GalleryFlowLayout.m
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "GalleryFlowLayout.h"

@implementation GalleryFlowLayout

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return nil;
    }

    self.itemSize = CGSizeMake(145, 145);
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    return self;
}

@end
