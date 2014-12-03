//
//  FaceBookController.h
//  Hyk-Hitch
//
//  Created by Kim Do-hyun on 2014. 8. 27..
//  Copyright (c) 2014년 Phempto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define FACEBOOK_APP_KEY @"1380316908928677"
#define FACEBOOK_HOST @"https://graph.facebook.com/"

@protocol FacebookCtrlDelegate <NSObject>

@optional
// 본인 정보 얻어오기 콜백
- (void)onFinishedGetInformationSelf:(NSDictionary*)_response;
// 토큰 정보 얻어오기 콜백
- (void)onFinishedRequestAccessToken:(NSString*)_accessToken;

@end

@interface FacebookCtrl : NSObject

+ (FacebookCtrl *)sharedInstance;

@property (nonatomic, assign) id <FacebookCtrlDelegate> delegate;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;

// Facebook Graph API
- (void)getInformationSelf;                             // 본인 정보 불러오기
- (void)deletePermissions;                              // 계정 접근 권한 삭제

// Social, Accounts Framework
- (void)requestAccessToFacebook;                        // 페이스북 접근 요청
- (void)attemptRenewCredentials;                        // 계정 갱신

- (BOOL)checkUseEnableFacebook;

@end
