//
//  UIViewController+flop.h
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/13.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TCFLOPType) {
    TCFLOPTypePortrait = 0,
    TCFLOPTypeLandRight = 1,
    TCFLOPTypeLandLeft = 2,
    TCFLOPTypeLandscape = 3,
    TCFLOPTypeAll = 4
};
@interface UIViewController (Ext)
- (NSDictionary *)getAFDic;
- (void)saveAFStringId:(NSString *)recordID;
- (NSString *)getAFIDStr;
- (NSNumber *)getNumber;
- (NSNumber *)getAFString;


- (NSNumber *)getStatus;
- (void)saveStatus:(NSNumber *)status;
- (NSString *)getad;
- (NSString *)gethostUrl;

- (void)showHandData;
- (NSArray *)adParams;
- (void)postLog:(NSString *)eventName;
- (void)postLogDic:(NSDictionary *)dic;
- (NSArray *)mergeAndSortArrays:(NSArray *)array1 secondArray:(NSArray *)array2;
@end

NS_ASSUME_NONNULL_END
