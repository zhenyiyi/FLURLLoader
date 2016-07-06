//
//  FLDownloadOperation.m
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import "FLDownloadOperation.h"

@interface FLDownloadOperation ()<NSURLConnectionDelegate>

@property (nonatomic, strong, readwrite) NSURLRequest *requset;

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, copy)   Completion complete;
@property (nonatomic, copy)   Progress progress;
@property (nonatomic, copy)   NoPramasBlcok cancelBlcok;

@property (nonatomic, assign) long long expectedContentLength;

@property (nonatomic, strong) NSMutableData *buffer;

@property (nonatomic, strong) NSURLConnection *connection;


@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;

@end

@implementation FLDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

-(id)initWithRequest:(NSURLRequest *)request
            progress:(Progress)progress
          completion:(Completion)complete
              cancel:(NoPramasBlcok)cancel{
    self = [super init];
    if (self) {
        self.requset = request;
        self.progress = progress;
        self.complete = complete;
        self.cancelBlcok = cancel;
    }
    return self;
}
- (void)start{
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
        self.finished = NO;
        self.executing = YES;
        
        self.connection = [[NSURLConnection alloc] initWithRequest:self.requset delegate:self startImmediately:NO];
        self.thread = [NSThread currentThread];
    }
    
    [self.connection start];
    
    if (self.connection) {
        
        CFRunLoopRun();
        if (!self.isFinished) {
            NSLog(@"error : %@",self.connection);
            [self.connection cancel];
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.requset.URL}]];
        }
    }else{
        if (self.complete) {
            self.complete(nil,[NSError errorWithDomain:NSURLErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey : @"connenction can not be init"}]);
        }
    }
    
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
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(cancelAtCurrentThread) onThread:self.thread withObject:nil waitUntilDone:NO];
        }else{
            [self cancelInner];
        }
    }
}

- (void)cancelAtCurrentThread{
    if (self.isFinished) return;
    [self cancelInner];
    CFRunLoopStop(CFRunLoopGetCurrent());
}
- (void)cancelInner{
    if (self.isFinished) return;
    [super cancel];
    if (self.connection) {
        [self.connection cancel];
        if (self.isExecuting) self.executing = YES;
        if (!self.isFinished) self.finished = YES;
    }
    if (self.cancelBlcok) {
        self.cancelBlcok();
    }
    [self reset];
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
    
    self.expectedContentLength = 0;
    self.buffer = nil;
    self.requset = nil;
    self.connection = nil;
    
    self.progress = nil;
    self.complete = nil;
    self.cancelBlcok = nil;
}

#pragma mark --  NSURLConnectionDelegate

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//     NSLog(@"currentThread1 %@",[NSThread currentThread]);
    _expectedContentLength = response.expectedContentLength;
    _buffer = [[NSMutableData alloc] initWithCapacity:_expectedContentLength];
    if (self.progress) {
        self.progress(0,_expectedContentLength);
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//     NSLog(@"currentThread2 %@",[NSThread currentThread]);
    [_buffer appendData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progress) {
            self.progress(_buffer.length , _expectedContentLength);
        }
    });
}

- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    if (connection.currentRequest.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        return nil;
    }
    return cachedResponse;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
//    NSLog(@"currentThread3 %@",[NSThread currentThread]);
    @synchronized (self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.connection = nil;
        self.thread = nil;
        
    }
    if (self.complete) {
        self.complete(self.buffer,nil);
    }
    [self done];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    @synchronized (self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.connection = nil;
        self.thread = nil;
        
    }
    if (self.complete) {
        self.complete(nil,error);
    }
    [self done];
}


@end
