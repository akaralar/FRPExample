//
//  PhotoModel.h
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModel : NSObject

@property (nonatomic) NSString *photoName;
@property (nonatomic) NSNumber *identifier;
@property (nonatomic) NSString *photographerName;
@property (nonatomic) NSNumber *rating;
@property (nonatomic) NSString *thumbnailURL;
@property (nonatomic) NSData *thumbnailData;
@property (nonatomic) NSString *fullSizedURL;
@property (nonatomic) NSData *fullSizedData;

@end
