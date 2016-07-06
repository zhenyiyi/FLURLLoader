//
//  ViewController.m
//  FLURLLoader
//
//  Created by fenglin on 7/6/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import "ViewController.h"
#import "DownloadOperation.h"


@interface ViewController ()
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) DownloadOperation *operation;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (IBAction)download:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://download.alicdn.com/dingtalk-desktop/Release/install/DingTalk_v1.12.0.dmg"];
    
    self.operation = [[DownloadOperation alloc] initWithURL:url downloadProgress:^(NSInteger downloadLength, NSInteger expectedLength) {
        self.progressView.progress = (CGFloat)downloadLength/expectedLength;
    } completion:^(id data, NSError *error) {
        NSLog(@"%@ : %@",data ,error);
    }];
    
    [self.queue addOperation:self.operation];
}
- (IBAction)cancel:(id)sender {
    [self.operation cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = [[NSOperationQueue alloc] init];

}

@end
