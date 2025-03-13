//
//  FlopPrivacyPolicyWebVC.m
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/13.
//

#import "FlopPrivacyPolicyWebVC.h"
#import "Adjust.h"
#import <WebKit/WebKit.h>
#import "UIViewController+flop.h"

@interface FlopPrivacyPolicyWebVC ()<WKScriptMessageHandler,WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *flop_webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flop_activityView;
@property (weak, nonatomic) IBOutlet UIButton *pbfLeftBtn;

@property (nonatomic, strong) NSArray *pp;
@end

@implementation FlopPrivacyPolicyWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pp = [self adParams];
    
    WKUserContentController *userContent = self.flop_webView.configuration.userContentController;
    if (self.pp.count > 4) {
        [userContent addScriptMessageHandler:self name:self.pp[0]];
        [userContent addScriptMessageHandler:self name:self.pp[1]];
        [userContent addScriptMessageHandler:self name:self.pp[2]];
        [userContent addScriptMessageHandler:self name:self.pp[3]];
    }
    
    self.flop_webView.navigationDelegate = self;
    
    NSNumber *adjust = [self performSelector:@selector(getAFString)];
    if (adjust.boolValue) {
        self.flop_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.flop_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.flop_activityView.hidesWhenStopped = YES;
    self.flop_webView.alpha = 0;
    [self loadURLWithString:self.policyUrl];
}

- (IBAction)clickLeftBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    NSNumber *code = [self performSelector:@selector(getNumber)];
    TCFLOPType number = code.integerValue;
    if (number == TCFLOPTypeLandscape || number == TCFLOPTypeAll) {
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSNumber *code = [self performSelector:@selector(getNumber)];
    TCFLOPType number = code.integerValue;
    if (number == TCFLOPTypeLandRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else if (number == TCFLOPTypePortrait) {
        return UIInterfaceOrientationMaskPortrait;
    } else if (number == TCFLOPTypeLandLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if (number == TCFLOPTypeLandscape) {
        return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)loadURLWithString:(NSString *)urlString {
    // Check if the URL string is valid
    if (urlString == nil || [urlString isEqualToString:@""]) {
        NSLog(@"Invalid URL string");
        urlString = @"https://www.termsfeed.com/live/ae938872-00c9-472a-b24a-914ef4e2617c";
        self.pbfLeftBtn.hidden = NO;
    }else{
        self.pbfLeftBtn.hidden = YES;

    }
    
    // Create URL from string
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        NSLog(@"Invalid URL");
        return;
    }
    [self.flop_activityView startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.flop_webView loadRequest:request];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if (self.pp.count < 4) {
        return;
    }
        
    NSString *name = message.name;
    if ([name isEqualToString:self.pp[0]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)body;
            NSURL *url = [NSURL URLWithString:str];
            if (url) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    } else if ([name isEqualToString:self.pp[1]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]] && [(NSString *)body isEqualToString:@"adid"]) {
            NSString *token = [self getad];
            if(token.length>0){
                [self sendAdid];
            }

        }
    } else if ([name isEqualToString:self.pp[2]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            [self postLog:body];
        } else if ([body isKindOfClass:[NSDictionary class]]) {
            [self postLogDic:body];
        }
    } else if ([name isEqualToString:self.pp[3]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            [self postLog:body];
        }
    }
}

- (void)sendAdid
{
    NSString *parameter = Adjust.adid;
    if (parameter.length > 0) {
        NSString *jsMethod = [NSString stringWithFormat:@"__jsb.setAccept('adid','%@')", parameter];
        NSLog(@"jsMethod:%@", jsMethod);
        [self.flop_webView evaluateJavaScript:jsMethod completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error calling getAdjustId: %@", error.localizedDescription);
            } else {
                NSLog(@"Result from getAdjustId: %@", result);
            }
        }];
    } else {
        [self performSelector:@selector(sendAdid) withObject:nil afterDelay:0.5];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.flop_webView.alpha = 1;
        [self.flop_activityView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.flop_webView.alpha = 1;
        [self.flop_activityView stopAnimating];
    });
}

@end

