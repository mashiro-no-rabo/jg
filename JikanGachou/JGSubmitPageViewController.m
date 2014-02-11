//
//  JGSubmitPageViewController.m
//  JikanGachou
//
//  Created by AquarHEAD L. on 1/25/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGSubmitPageViewController.h"
#import <AFNetworking.h>
#import <NSString+MD5.h>
#import <YLProgressBar.h>

@interface JGSubmitPageViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *recpField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextview;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;

@property (weak, nonatomic) IBOutlet YLProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) NSFNanoObject *book;

@property (nonatomic) NSUInteger finished;

@end

@implementation JGSubmitPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.book = self.poolViewController.book;

    self.progressBar.type = YLProgressBarTypeFlat;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.progressBar.behavior = YLProgressBarBehaviorDefault;
    self.progressBar.hideStripes = YES;
    self.progressBar.progressTintColor = [UIColor colorWithRed:232/255.0f green:132/255.0f blue:12/255.0f alpha:1.0f];
    self.finished = 0;

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (IBAction)createPayment:(id)sender {
    self.paymentButton.enabled = NO;
    [self.recpField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.addressTextview resignFirstResponder];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{@"info": self.book.info, @"recp": self.recpField.text, @"phone": self.phoneField.text, @"address": self.addressTextview.text};
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book.key];
    [manager POST:addr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.paymentButton.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.paymentButton.enabled = YES;
    }];
}

- (IBAction)submit:(id)sender {
    if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        [self checkStatus];
    } else if ([AFNetworkReachabilityManager sharedManager].reachableViaWWAN) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有无线网络连接" message:@"上传照片会消耗很多流量，继续使用蜂窝数据网络上传吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有网络连接" message:@"请连接网络以上传照片" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)checkStatus
{
    self.submitButton.enabled = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *addr = [NSString stringWithFormat:@"http://jg.aquarhead.me/book/%@/", self.book.key];
    [manager GET:addr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqualToString:@"toupload"]) {
            [self doSubmit];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您还未付款" message:@"请先付款，如有其他问题请联系客服" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            self.submitButton.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.submitButton.enabled = YES;
    }];
}

- (void)doSubmit
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.operationQueue.maxConcurrentOperationCount = 1;

    for (ALAsset *p in self.photos) {
        ALAssetRepresentation *rep = p.defaultRepresentation;
        NSURL *data_url = rep.url;
        Byte *buffer = (Byte*)malloc((unsigned)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(unsigned)rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        NSMutableDictionary *options = [NSMutableDictionary new];
        options[@"bucket"] = @"jikangachou";
        options[@"expiration"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + 600];
        options[@"save-key"] = [NSString stringWithFormat:@"/%@/%@.JPG", self.book.key, [data_url query]];
        NSString *policy = [[NSJSONSerialization dataWithJSONObject:[options copy] options:0 error:nil] base64EncodedStringWithOptions:0];
        NSString *sig = [[NSString stringWithFormat:@"%@&DWAPWXDv2cLI7MuZmJRWq63r0T8=", policy] MD5Digest];
        NSDictionary *parameters = @{@"policy": policy, @"signature": sig};
        [manager POST:@"http://v0.api.upyun.com/jikangachou" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"file.JPG" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self finishOne];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.submitButton.enabled = YES;
        }];
    }
}

- (void)finishOne
{
    self.finished += 1;
    [self.progressBar setProgress:(1.0*self.finished / self.photos.count) animated:YES];
    if (self.finished == self.photos.count) {
        // set server status to toprint
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"照片上传完成" message:@"我们会立刻付印您的相册" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self checkStatus];
    }
}

@end
