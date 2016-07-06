//
//  DownloadOperation.h
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^Completion)(id data , NSError * error);
typedef void (^Progress)(NSInteger downloadLength, NSInteger expectedLength);

@interface DownloadOperation : NSOperation

-(id)initWithURL:(NSURL *)url downloadProgress:(Progress)progress completion:(Completion)complete;

@end
