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

+ (RACReplaySubject *)importPhotos
{
    RACReplaySubject *subject = [RACReplaySubject subject];

    NSURLRequest *request = [self popularURLRequest];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {

        if (data) {
            id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            [subject sendNext:[[[results[@"photos"] rac_sequence]
                                map:^id (NSDictionary *photoDictionary) {

                PhotoModel *model = [PhotoModel new];
                [self configurePhotoModel:model withDictionary:photoDictionary];
                [self downloadThumbnailForPhotoModel:model];
                return model;
            }] array]];

            [subject sendCompleted];
        }
        else {
            [subject sendError:connectionError];
        }
    }];

    return subject;
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

    [self download:model.thumbnailURL withCompletion:^(NSData *data) {
        model.thumbnailData = data;
    }];
}

+ (void)downloadFullSizedImageForPhotoModel:(PhotoModel *)model
{
    NSAssert(model.thumbnailURL, @"FullSize URL must not be nil");
    [self download:model.fullSizedURL withCompletion:^(NSData *data) {
        model.fullSizedData = data;
    }];
}

+ (void)download:(NSString *)urlString withCompletion:(void (^)(NSData *data))completion
{
    NSAssert(urlString, @"URL can't be nil");

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {

        if (completion && data) {
            completion(data);
        }
    }];
}

+ (NSURLRequest *)photoURLRequest:(PhotoModel *)model
{
    return [APPDELEGATE.apiHelper urlRequestForPhotoID:model.identifier.integerValue];
}

+ (RACSignal *)fetchPhotoDetails:(PhotoModel *)model
{
    RACReplaySubject *subject = [RACReplaySubject subject];

    NSURLRequest *request = [self photoURLRequest:model];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {

        if (data) {

            id results =
                [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
            [self configurePhotoModel:model withDictionary:results];
            [self downloadFullSizedImageForPhotoModel:model];

            [subject sendNext:model];
            [subject sendCompleted];
        }
        else {
            [subject sendError:connectionError];
        }
    }];

    return subject;
}

@end
