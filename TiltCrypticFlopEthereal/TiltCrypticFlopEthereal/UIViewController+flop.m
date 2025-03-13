//
//  UIViewController+flop.m
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/13.
//

#import "UIViewController+flop.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation UIViewController (flop)
- (void)saveAFStringId:(NSString *)recordID
{
    if (recordID.length) {
        [NSUserDefaults.standardUserDefaults setValue:recordID forKey:@"RecordID"];
    }
}

- (NSDictionary *)getAFDic
{
    NSString *recordID = [[NSUserDefaults standardUserDefaults] stringForKey:@"RecordID"];
    if (recordID.length) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:recordID options:0];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

        if (!error) {
            NSLog(@"Dictionary: %@", jsonDict);
            return jsonDict;
        } else {
            NSLog(@"Error parsing JSON: %@", error.localizedDescription);
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSString *)getAFIDStr
{
    return [[self getAFDic] objectForKey:@"recordID"];
}

- (NSNumber *)getNumber
{
    NSNumber *number = [[self getAFDic] objectForKey:@"number"];
    return number;
}

- (NSNumber *)getAFString
{
    NSNumber *number = [[self getAFDic] objectForKey:@"adjust"];
    return number;
}

- (NSNumber *)getStatus
{
    NSNumber *status = [NSUserDefaults.standardUserDefaults valueForKey:@"status"];
    return status;
}

- (void)saveStatus:(NSNumber *)status
{
    if (status) {
        [NSUserDefaults.standardUserDefaults setValue:status forKey:@"status"];
    }
}
- (NSString *)getad
{
    return [[self getAFDic] objectForKey:@"ad"];
}

- (NSArray *)adParams
{
    return [[self getAFDic] objectForKey:@"params"];
}
- (NSString *)gethostUrl{
    return @"https://findu";
}
- (void)showHandData
{
    id adsView = [self.storyboard instantiateViewControllerWithIdentifier:@"FlopPrivacyPolicyWebVC"];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString *keyId = [NSString stringWithFormat:@"%@&ver=%.0f&lg=%@&ct=%@", [self getAFIDStr], NSDate.date.timeIntervalSince1970,languageCode,currentLocale];
    [adsView setValue:keyId forKey:@"policyUrl"];
    NSLog(@"%@", keyId);
    ((UIViewController *)adsView).modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:(UIViewController *)adsView animated:NO completion:nil];
}

- (void)postLog:(NSString *)eventName
{
    [FBSDKAppEvents.shared logEvent:eventName];
}

- (void)postLogDic:(NSDictionary *)dic
{
    [self postLog:dic[@"event"] value:dic[@"value"] jsonStr:dic[@"jsonstr"]];
}

- (void)postLog:(NSString *)event value:(NSString *)value jsonStr:(NSString *)jsonstr
{
    NSError *error = nil;
    NSData *jsonData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return;
    }
    double valueToSum = -1;
    BOOL reportValueToSum = NO;

    NSArray *arr = [self adParams];
    if (arr.count<5) {
        return;
    }
    
    if (jsonDict[arr[4]] != nil) {
        valueToSum = [jsonDict[arr[4]] doubleValue];
        reportValueToSum = YES;
    }
    
    if (value.length > 0 && [value doubleValue]) {
        valueToSum = [value doubleValue];
        reportValueToSum = YES;
    }

    if (reportValueToSum) {
        [FBSDKAppEvents.shared logEvent:event valueToSum:valueToSum parameters:jsonDict];
    } else {
        [FBSDKAppEvents.shared logEvent:event parameters:jsonDict];
    }
}
- (NSArray *)mergeAndSortArrays:(NSArray *)array1 secondArray:(NSArray *)array2 {
    // 合并两个数组
    NSMutableArray *mergedArray = [NSMutableArray arrayWithArray:array1];
    [mergedArray addObjectsFromArray:array2];

    // 去重
    NSSet *uniqueSet = [NSSet setWithArray:mergedArray];
    NSArray *uniqueArray = [uniqueSet allObjects];

    // 排序
    NSArray *sortedArray = [uniqueArray sortedArrayUsingSelector:@selector(compare:)];

    return sortedArray;
}
@end
