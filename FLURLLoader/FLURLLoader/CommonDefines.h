//
//  CommonDefines.h
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Completion)(id data , NSError * error);

typedef void (^Progress)(NSInteger downloadLength, NSInteger expectedLength);

typedef void (^NoPramasBlcok) ();

@interface CommonDefines : NSObject

@end
