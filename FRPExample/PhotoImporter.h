//
//  PhotoImporter.h
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoModel;

@interface PhotoImporter : NSObject

+ (RACSignal *)importPhotos;
+ (RACSignal *)fetchPhotoDetails:(PhotoModel *)model;

@end
