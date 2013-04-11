#import <Foundation/Foundation.h>

@interface ZBFacebookTestUserManager : NSObject

- (id)initWithAppID:(NSString *)inAppID appSecret:(NSString *)inAppSecret;
- (NSDictionary *)createTestAccountWithName:(NSString *)inUsername error:(NSError **)outError;
- (BOOL)deleteTestAccountWithUserID:(NSString *)inUserID error:(NSError **)outError;

@property (readonly) NSString *appID;
@property (readonly) NSString *appSecret;
@end
