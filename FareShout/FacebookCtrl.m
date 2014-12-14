//
//  FaceBookController.m
//  Hyk-Hitch
//
//  Created by Kim Do-hyun on 2014. 8. 27..
//  Copyright (c) 2014년 Phempto. All rights reserved.
//

#import "FacebookCtrl.h"

static FacebookCtrl *appConfigInstance = nil;

@implementation FacebookCtrl

// Get the shared instance and create it if necessary.
+ (FacebookCtrl *)sharedInstance {
	 if (nil != appConfigInstance) {
		  return appConfigInstance;
	 }
	 
	 static dispatch_once_t onceToken;
	 dispatch_once(&onceToken, ^{
		  appConfigInstance = [[super allocWithZone:NULL] init];
	 });
	 
	 return appConfigInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
	 return [self sharedInstance];
}

- (instancetype)init
{
	 self = [super init];
	 if (self) {
		  //  Register for Account Change notification
		  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged:) name:ACAccountStoreDidChangeNotification object:nil];
	 }
	 
	 return self;
}

#pragma mark -
// Facebook 권한 체크
- (BOOL)checkUseEnableFacebook {
	 BOOL isEnable = NO;
	 ACAccountType *FBaccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
	 isEnable = FBaccountType.accessGranted;
	 NSLog(@"\n\t%@\n\t%@\n\t%@", FBaccountType.accountTypeDescription, FBaccountType.identifier, FBaccountType.accessGranted?@"접근 가능":@"접근 불가");
	 if (!FBaccountType.accessGranted) {
		  // Session Error
		  // @"Your current session is no longer valid. Please log in again.";
		  
		  // Facebook Setting Error
		  NSString *msg = @"To use your Facebook account with this app, open Settings > Facebook and make sure this app is turned on.";
		  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		  [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	 }
	 
	 return isEnable;
}

#pragma mark - Facebook Graph Api Request Methods

// 접근 토큰 얻어오기
- (void)requestAccessToFacebook {
	 [self requestAccessToFacebookWithPerms:true];
}

- (void)requestAccessToFacebookWithPerms:(BOOL)fullPerms {
	 self.accountStore = [[ACAccountStore alloc] init];
	 ACAccountType *FBaccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
	 NSLog(@"FB Grant: %@", FBaccountType.accessGranted ? @"Yes" : @"No");
	 
	 NSArray *perms = @[@"email", @"user_photos", @"user_friends"];
	 if (fullPerms == false) {
		  perms = @[@"email", @"user_friends"];
	 }
	 
	 NSDictionary *FBdict = [NSDictionary dictionaryWithObjectsAndKeys:FACEBOOK_APP_KEY, ACFacebookAppIdKey, perms, ACFacebookPermissionsKey, nil];
	 
	 [self.accountStore requestAccessToAccountsWithType:FBaccountType options:FBdict completion:^(BOOL granted, NSError *e) {
		  if (granted)
		  {
				NSArray *accounts = [self.accountStore accountsWithAccountType:FBaccountType];
				// it will always be the last object with single sign on
				self.facebookAccount = [accounts lastObject];
				
				ACAccountCredential *facebookCredential = [self.facebookAccount credential];
				NSLog(@"저장 토큰 : %@", [facebookCredential oauthToken]);
				if ([self.delegate respondsToSelector:@selector(onFinishedRequestAccessToken:)])
					 [self.delegate onFinishedRequestAccessToken:facebookCredential.oauthToken];
		  } else {
				// Fail
				NSLog(@"Grant Error : %@", e.localizedDescription);
		  }
	 }];
}

- (void)getInformationSelf {
	 [self getInformationSelfWithAccessToken:nil];
}

- (void)getInformationSelfWithAccessToken:(NSString *)token {
	 // https://graph.facebook.com/me?fields=email,first_name,last_name,name,picture.type(large),friends
	 
	 if (![self checkUseEnableFacebook]) return;
	 
	 NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FACEBOOK_HOST, @"me"]];
	 NSDictionary *parameters = @{
											@"fields": @"id,email,first_name,last_name,name,picture.type(large).width(1280),friends"
											};
	 
	 if (token != nil) {
		  parameters = @{
							  @"fields": parameters[@"fields"],
							  @"accessToken": token
							  };
	 }
	 
	 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
	 request.account = self.facebookAccount;
	 
	 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		  NSLog(@"%@", urlResponse);
		  NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
		  
		  if (!error) {
				NSDictionary *list = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
				NSLog(@"## JSON Data ##\n%@", list);
				
				if ([list objectForKey:@"error_user_msg"] != nil) {
					 NSString *msg = [list objectForKey:@"error_user_msg"];
					 NSString *title = [list objectForKey:@"error_user_title"];
					 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					 [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
					 return;
				} else if ([list objectForKey:@"error"] != nil) {
					 [self attemptRenewCredentials];
				} else if ([self.delegate respondsToSelector:@selector(onFinishedGetInformationSelf:)]) {
					 [self.delegate onFinishedGetInformationSelf:list];
				}
		  }
		  else {
				NSLog(@"error from get%@",error);
				[self attemptRenewCredentials];
		  }
	 }];
}

#pragma mark - Account Changed Notification Method
-(void)accountChanged:(NSNotification *)notif
{
	 NSLog(@"\n\t\t\t## 계정 정보 변경됨 ##");
	 if (self.facebookAccount!=nil) {
		  NSLog(@"갱신");
		  [self attemptRenewCredentials];
	 }
	 else {
		  NSLog(@"재요청");
		  [self requestAccessToFacebook];
	 }
}

#pragma mark - Social, Accounts Framework Methods
// 계정 갱신
-(void)attemptRenewCredentials
{
	 [[NSNotificationCenter defaultCenter] removeObserver:self name:ACAccountStoreDidChangeNotification object:nil];
	 if (!self.facebookAccount) {
		  NSLog(@"계정 정보 없음");
		  return;
	 }
	 
	 [self.accountStore renewCredentialsForAccount:(ACAccount *)self.facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
		  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged:) name:ACAccountStoreDidChangeNotification object:nil];
		  if(!error)
		  {
				[self requestAccessToFacebook];
				switch (renewResult) {
					 case ACAccountCredentialRenewResultRenewed:
						  NSLog(@"계정 갱신 완료, Good to go");
						  NSLog(@"갱신토큰 : %@", self.facebookAccount.credential.oauthToken);
						  break;
					 case ACAccountCredentialRenewResultRejected:
						  NSLog(@"계정 거절, User declined permission");
						  break;
					 case ACAccountCredentialRenewResultFailed:
						  NSLog(@"계정 갱신 실패, non-user-initiated cancel, you may attempt to retry");
						  break;
					 default:
						  break;
				}
		  } else {
				NSLog(@"error from renew credentials : %@",error);
		  }
	 }];
}

- (void)deletePermissions {
	 NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", FACEBOOK_HOST, @"me/permissions"]];
	 
	 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodDELETE URL:requestURL parameters:nil];
	 request.account = self.facebookAccount;
	 
	 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		  NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
		  
		  if (!error) {
				NSDictionary *list = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
				NSLog(@"## JSON Data ##\n%@", list);
				self.facebookAccount = nil;
		  }
		  else {
				NSLog(@"error from get%@",error);
		  }
	 }];
}

@end
