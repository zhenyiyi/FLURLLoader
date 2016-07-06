//
//  FLDownloadOperation.h
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDefines.h"


/**
 *  模仿SDWebImageOperation 改的。
 */
@interface FLDownloadOperation : NSOperation

@property (nonatomic, strong, readonly) NSURLRequest *requset;

-(id)initWithRequest:(NSURLRequest *)request
            progress:(Progress)progress
          completion:(Completion)complete
              cancel:(NoPramasBlcok)cancel;

@end
