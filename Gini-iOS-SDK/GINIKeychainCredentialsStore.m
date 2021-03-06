/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

#import "GINIKeychainCredentialsStore.h"
#import "GINIKeychainManager.h"
#import "GINIKeychainItem.h"


NSString *const GINIRefreshTokenKey = @"refreshToken";
NSString *const GINIUserNameKey = @"userName";
NSString *const GINIPasswordKey = @"Password";


@implementation GINIKeychainCredentialsStore {
    GINIKeychainManager *_keychainManager;
}

+ (instancetype)credentialsStoreWithKeychainManager:(GINIKeychainManager *)keychainManager {
    return [[self alloc] initWithKeychainManager:keychainManager];
}

- (instancetype)initWithKeychainManager:(GINIKeychainManager *)keychainManager {
    NSParameterAssert([keychainManager isKindOfClass:[GINIKeychainManager class]]);

    if (self = [super init]) {
        _keychainManager = keychainManager;
    }
    return self;
}


- (BOOL)storeRefreshToken:(NSString *)refreshToken {
    NSParameterAssert([refreshToken isKindOfClass:[NSString class]]);

    GINIKeychainItem *refreshTokenItem = [GINIKeychainItem keychainItemWithIdentifier:GINIRefreshTokenKey value:refreshToken];
    return [_keychainManager storeItem:refreshTokenItem];
}

- (NSString *)fetchRefreshToken {
    return [[_keychainManager getItem:GINIRefreshTokenKey] value];
}

- (BOOL)storeUserCredentials:(NSString *)userName password:(NSString *)password {
    NSParameterAssert([userName isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);

    GINIKeychainItem *userItem = [GINIKeychainItem keychainItemWithIdentifier:GINIUserNameKey value:userName];
    GINIKeychainItem *passwordItem = [GINIKeychainItem keychainItemWithIdentifier:GINIPasswordKey value:password];

    return [_keychainManager storeItem:userItem] && [_keychainManager storeItem:passwordItem];
}

- (void)fetchUserCredentials:(NSString **)userName password:(NSString **)password {
    *userName = [[_keychainManager getItem:GINIUserNameKey] value];
    *password = [[_keychainManager getItem:GINIPasswordKey] value];
}

- (void)removeCredentials {
    [_keychainManager deleteItem:[GINIKeychainItem keychainItemWithIdentifier:GINIUserNameKey value:nil]];
    [_keychainManager deleteItem:[GINIKeychainItem keychainItemWithIdentifier:GINIPasswordKey value:nil]];
}

@end
