//
//  ProxyManager.h
//  Potatso
//
//  Created by LEI on 2/23/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HttpProxyCompletion)(int port, NSError *error);

@interface ProxyManager : NSObject

+ (ProxyManager *)sharedManager;
@property (nonatomic, readonly) BOOL httpProxyRunning;
@property (nonatomic, readonly) int httpProxyPort;
- (void)startHttpProxy: (HttpProxyCompletion)completion;
- (void)stopHttpProxy;
@end
