#import "ZBFacebookTestUserManager.h"

@interface ZBFacebookTestUserManager ()
{
    NSString *appID;
    NSString *appSecret;
    NSString *appAccessToken;
}

- (void)obtainAppAccessToken;

@end

@implementation ZBFacebookTestUserManager

- (void)dealloc
{
    [appID release];
    [appSecret release];
    [appAccessToken release];
    [super dealloc];
}

- (id)initWithAppID:(NSString *)inAppID appSecret:(NSString *)inAppSecret
{
    self = [super init];
    if (self) {
        appID = [inAppID retain];
        appSecret = [inAppSecret retain];
        appAccessToken = nil;
    }
    return self;
}

- (void)obtainAppAccessToken
{
    NSString *URLString = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials", appID, appSecret];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:&response error:&error];
    if (data) {
        NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

        NSString *prefix = @"access_token=";
        if (response && [response hasPrefix:prefix]) {
            appAccessToken = [[response substringFromIndex:[prefix length]] retain];
        }
    }
}

- (NSDictionary *)createTestAccountWithName:(NSString *)inUsername error:(NSError **)outError
{
    if (!appAccessToken) {
        [self obtainAppAccessToken];
    }
    if (!appAccessToken) {
        return nil;
    }
    NSArray *permissions = [NSArray arrayWithObjects:@"email", @"publish_stream", @"user_about_me", @"publish_actions", nil];
    NSString *joinedPermissions = [permissions componentsJoinedByString:@","];

    NSString *URLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/accounts/test-users?installed=true&name=%@&locale=en_US&method=post&access_token=%@&permissions=%@",
                           [appID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [inUsername stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [appAccessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [joinedPermissions stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                        ];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:&response error:&error];
    if (error) {
        if (outError) {
            *outError = error;
        }
        return nil;
    }
    if (data) {
        NSError *error = nil;
        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            if (outError) {
                *outError = error;
            }
            return nil;
        }
        return response;
    }
    return nil;
}

- (BOOL)deleteTestAccountWithUserID:(NSString *)inUserID error:(NSError **)outError
{
    if (!appAccessToken) {
        [self obtainAppAccessToken];
    }
    if (!appAccessToken) {
        return NO;
    }

    NSString *URLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/?method=delete&access_token=%@",
                           [inUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [appAccessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:&response error:&error];
    if (error) {
        if (outError) {
            *outError = error;
        }
        return NO;
    }
    if (data) {
        NSError *error = nil;
        NSString *rtn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        if (error) {
            NSLog(@"error:%@", error);
            if (outError) {
                *outError = error;
            }
            return NO;
        }
        return [rtn isEqualToString:@"true"];
    }
    return NO;
}

@synthesize appID;
@synthesize appSecret;

@end
