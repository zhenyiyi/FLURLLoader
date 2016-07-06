//
//  DownloadOperation.m
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import "DownloadOperation.h"

@interface DownloadOperation ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURL *downloadURL;

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, copy)   Completion complete;
@property (nonatomic, copy)   Progress progress;

@property (nonatomic, assign) long long expectedContentLength;

@property (nonatomic, strong) NSMutableData *buffer;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite, getter=isConcurrent) BOOL concurrent;
@end

@implementation DownloadOperation

@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize concurrent = _concurrent;


#pragma mark -- life sytle

-(id)initWithURL:(NSURL *)url downloadProgress:(Progress)progress completion:(Completion)complete{
    
   self = [super init];
    if (self) {
        self.downloadURL = url;
        self.complete = complete;
        self.progress = progress;
    }
    return self;
}

- (void)main{
    
    self.executing = YES;
    self.finished = NO;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.downloadURL];
    if (!_connection) {
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    
    [[NSRunLoop currentRunLoop] run];
}


- (void)setExecuting:(BOOL)executing{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel{
    [super cancel];
    [self.connection cancel];
    [self done];
}

-(BOOL)isConcurrent{
    return YES;
}

- (void)done{
    self.executing = NO;
    self.finished = YES;
    [self reset];
}

- (void)reset{
    
    self.buffer = nil;
    self.connection = nil;
    
    self.progress = nil;
    self.complete = nil;
}

#pragma mark --  NSURLConnectionDelegate

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _expectedContentLength = response.expectedContentLength;
    _buffer = [[NSMutableData alloc] initWithCapacity:_expectedContentLength];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_buffer appendData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progress) {
            self.progress(_buffer.length , _expectedContentLength);
        }
    });
}

- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return cachedResponse;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self done];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.complete) {
            self.complete(self.buffer,nil);
        }
    });
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self done];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.complete) {
            self.complete(nil,error);
        }
    });
}

@end
