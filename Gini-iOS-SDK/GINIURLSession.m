/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import <Bolts/Bolts.h>
#import <UIKit/UIImage.h>
#import "GINIURLSession.h"
#import "GINIURLResponse.h"


#define GINI_DEFAULT_ENCODING NSUTF8StringEncoding


/**
 * Helper function that determines if a content type is a valid JSON content type.
 */
BOOL GINIIsJSONContent(NSString *contentType) {
    static NSSet *knownContentTypes;
    if (!knownContentTypes) {
        knownContentTypes = [NSSet setWithObjects:@"application/json", @"application/vnd.gini.v1+json", @"application/vnd.gini.incubator+json", nil];
    }
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return ([knownContentTypes containsObject:contentTypeComponents.firstObject]);
}

/**
 * Helper function that determines if a content type is a valid image content type.
 */
BOOL GINIIsImageContent(NSString *contentType) {
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return [[[contentTypeComponents firstObject] substringToIndex:6] isEqualToString:@"image/"];
}

/**
 * Helper function that determines if a content type is a valid text content type.
 */
BOOL GINIIsTextContent(NSString *contentType) {
    NSArray *contentTypeComponents = [contentType componentsSeparatedByString:@";"];
    return [[[contentTypeComponents firstObject] substringToIndex:5] isEqualToString:@"text/"];
}

@implementation GINIURLSession {
    NSURLSession *_nsURLSession;
}

+ (instancetype)urlSessionWithNSURLSession:(NSURLSession *)urlSession {
    return [[GINIURLSession alloc] initWithNSURLSession:urlSession];
}

+ (instancetype)urlSession {
    return [GINIURLSession urlSessionWithNSURLSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]];
}

- (instancetype)initWithNSURLSession:(NSURLSession *)urlSession {
    self = [super init];
    if (self) {
        _nsURLSession = urlSession;
    }
    return self;
}


#pragma mark - Public Methods
- (BFTask *)BFDataTaskWithRequest:(NSURLRequest *)request{
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionDataTask *task = [_nsURLSession dataTaskWithRequest:request completionHandler:^void(NSData *data, NSURLResponse *response, NSError *error) {
        // If there has been an error in the HTTP communication, transparently pass-through the error.
        if (error) {
            return [completionSource setError:error];
        }
        [self deserializeResponse:response withData:data completingTaskSource:completionSource];
    }];
    [task resume];
    return completionSource.task;
}

- (BFTask *)BFDownloadTaskWithRequest:(NSURLRequest *)request {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionDownloadTask *downloadTask = [_nsURLSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // If there has been an error in the HTTP communication, transparently pass-through the error.
        if (error) {
            return [completionSource setError:error];
        }
        [completionSource setResult:[GINIURLResponse urlResponseWithResponse:(NSHTTPURLResponse *)response data:location]]; // TODO: downcast
    }];
    [downloadTask resume];
    return completionSource.task;
}

- (BFTask *)BFUploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)uploadData {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionUploadTask *uploadTask = [_nsURLSession uploadTaskWithRequest:request fromData:uploadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            return [completionSource setError:error];
        }
        [self deserializeResponse:response withData:data completingTaskSource:completionSource];
    }];
    [uploadTask resume];
    return completionSource.task;
}

#pragma mark - Private methods
- (void)deserializeResponse:(NSURLResponse *)response withData:(NSData *)rawData completingTaskSource:(BFTaskCompletionSource *)completionSource {
    // TODO: Refactor this method so it is understandable more easily.
    GINIURLResponse *httpResult = [GINIURLResponse new];

    // Usually the response object is actually an instance of the sub class NSHTTPURLResponse, but we check to be
    // sure instead of doing a simple downcast.
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSError *error;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        httpResult.response = httpResponse;
        NSString *contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
        if (GINIIsJSONContent(contentType) && [rawData length] > 0) {
            id deserializedData = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                return [completionSource setError:error];
            } else {
                httpResult.data = deserializedData;
            }
        } else if (GINIIsImageContent(contentType)) {
            UIImage *image = [UIImage imageWithData:rawData];
            if (image) {
                httpResult.data = image;
            }
        } else if (GINIIsTextContent(contentType)) {
            httpResult.data = [[NSString alloc] initWithData:rawData encoding:GINI_DEFAULT_ENCODING];
        }
    }
    // If the response could not be deserialized, just set the data as the result.
    if (!httpResult.data) {
        httpResult.data = rawData;
    }

    return [completionSource setResult:httpResult];
}

@end