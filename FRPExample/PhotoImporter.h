//
//  PhotoImporter.h
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoImporter : NSObject

+ (RACSignal *)importPhotos;
@end
