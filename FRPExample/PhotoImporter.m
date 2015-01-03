//
//  PhotoImporter.m
//  FRPExample
//
//  Created by Ahmet Karalar on 29/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "PhotoImporter.h"
#import "PhotoModel.h"

@implementation PhotoImporter

+ (RACSignal *)importPhotos
{
    NSURLRequest *request = [self popularURLRequest];

    return [[[[[[NSURLConnection rac_sendAsynchronousRequest:request]
                reduceEach:^id (NSURLResponse *response, NSData *data) {
        return data;
    }] deliverOn:[RACScheduler mainThreadScheduler]] map:^id (id value) {
        id results = [NSJSONSerialization JSONObjectWithData:value options:0 error:nil];
        return [[[results[@"photos"] rac_sequence] map:^id (NSDictionary *photoDictionary) {
            PhotoModel *model = [PhotoModel new];
            [self configurePhotoModel:model withDictionary:photoDictionary];
            [self downloadThumbnailForPhotoModel:model];
            return model;
        }] array];
    }] publish] autoconnect];
}

+ (NSURLRequest *)popularURLRequest
{
    return [APPDELEGATE.apiHelper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular
                                             resultsPerPage:100
                                                       page:0
                                                 photoSizes:PXPhotoModelSizeThumbnail
                                                  sortOrder:PXAPIHelperSortOrderRating
                                                     except:PXPhotoModelCategoryNude];
}

+ (void)configurePhotoModel:(PhotoModel *)model withDictionary:(NSDictionary *)dictionary
{
    model.photoName = dictionary[@"name"];
    model.identifier = dictionary[@"id"];
    model.photographerName = dictionary[@"user"][@"username"];
    model.rating = dictionary[@"rating"];
    model.thumbnailURL = [self urlForImageSize:3 inArray:dictionary[@"images"]];

    if (dictionary[@"comments_count"]) {

        model.fullSizedURL = [self urlForImageSize:4 inArray:dictionary[@"images"]];
    }
}

+ (NSString *)urlForImageSize:(NSInteger)size inArray:(NSArray *)array
{
    return [[[[[array rac_sequence] filter:^BOOL (NSDictionary *value) {
        return [value[@"size"] integerValue] == size;
    }] map:^id (id value) {
        return value[@"url"];
    }] array] firstObject];
}

+ (void)downloadThumbnailForPhotoModel:(PhotoModel *)model
{
    NSAssert(model.thumbnailURL, @"Thumbnail URL must not be nil");
    RAC(model, thumbnailData) = [self download:model.thumbnailURL];
}

+ (void)downloadFullSizedImageForPhotoModel:(PhotoModel *)model
{
    NSAssert(model.thumbnailURL, @"FullSize URL must not be nil");
    RAC(model, fullSizedData) = [self download:model.fullSizedURL];
}

+ (RACSignal *)download:(NSString *)urlString
{
    NSAssert(urlString, @"URL can't be nil");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [[[NSURLConnection rac_sendAsynchronousRequest:request]
             map:^id (RACTuple *tuple) {
        return tuple.second;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (NSURLRequest *)photoURLRequest:(PhotoModel *)model
{
    return [APPDELEGATE.apiHelper urlRequestForPhotoID:model.identifier.integerValue];
}

+ (RACSignal *)fetchPhotoDetails:(PhotoModel *)model
{
    NSURLRequest *request = [self photoURLRequest:model];

    return [[[[[[NSURLConnection rac_sendAsynchronousRequest:request]
                reduceEach:^id (NSURLResponse *response, NSData *data) {
        return data;
    }] deliverOn:[RACScheduler mainThreadScheduler]] map:^id (NSData *data) {
        id results =
            [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
        [self configurePhotoModel:model withDictionary:results];
        [self downloadFullSizedImageForPhotoModel:model];
        return model;
    }] publish] autoconnect];
}

@end
