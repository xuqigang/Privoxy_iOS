//
//  ProxyManager.m
//  Potatso
//
//  Created by LEI on 2/23/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

#import "ProxyManager.h"
#import <netinet/in.h>
#import "jcc.h"
#import "project.h"
//#import "AntinatServer.h"
@interface ProxyManager ()
@property (nonatomic) BOOL httpProxyRunning;
@property (nonatomic) int httpProxyPort;
@property (nonatomic, copy) HttpProxyCompletion httpCompletion;

- (void)onHttpProxyCallback: (int)fd;
@end
int sock_port (int fd) {
    struct sockaddr_in sin;
    socklen_t len = sizeof(sin);
    if (getsockname(fd, (struct sockaddr *)&sin, &len) < 0) {
        NSLog(@"getsock_port(%d) error: %s",
              fd, strerror (errno));
        return 0;
    }else{
        return ntohs(sin.sin_port);
    }
}
void http_proxy_handler(int fd, void *udata) {
    ProxyManager *provider = (__bridge ProxyManager *)udata;
    [provider onHttpProxyCallback:fd];
}

@implementation ProxyManager

+ (ProxyManager *)sharedManager {
    static dispatch_once_t onceToken;
    static ProxyManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [ProxyManager new];
        [manager generateHttpProxyConfig];
    });
    return manager;
}

# pragma mark - Http Proxy

- (void)startHttpProxy:(HttpProxyCompletion)completion {
    self.httpCompletion = [completion copy];
    NSString *configPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"privoxy/config.txt"];
    [NSThread detachNewThreadSelector:@selector(_startHttpProxy:) toTarget:self withObject:configPath];
}

- (void)_startHttpProxy: (NSString *)configPath {

    char *parameter[3];
    char *config = (char*)[configPath UTF8String];
    char *model = "--no-daemon";
    parameter[0] = "";
    parameter[1] = model;
    parameter[2] = config;
    NSLog(@"ifeng - configPath %s",config);
    privoxy_main(3, parameter);
    NSLog(@"ifeng - privoxy_main");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.httpCompletion(8118, nil);
    });
}

- (void)stopHttpProxy {
    
}

- (void)onHttpProxyCallback:(int)fd {
    NSError *error;
    if (fd > 0) {
        self.httpProxyPort = sock_port(fd);
        self.httpProxyRunning = YES;
    }else {
        error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:100 userInfo:@{NSLocalizedDescriptionKey: @"Fail to start http proxy"}];
    }
    if (self.httpCompletion) {
        self.httpCompletion(self.httpProxyPort, error);
    }
}

- (void)generateHttpProxyConfig{
    NSString *rootUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"privoxy"];
    NSLog(@"ifeng - rootURL = %@",rootUrl);
    NSString *confDirurl = rootUrl;
    NSString *templatesDirPath = [confDirurl stringByAppendingPathComponent:@"templates"];
    NSString *logDirPath = [templatesDirPath stringByAppendingPathComponent:@"logs"];
    NSString *userActionUrl = [confDirurl stringByAppendingPathComponent:@"user.action"];
    [self createDicr:rootUrl];
    [self createDicr:confDirurl];
    [self createDicr:templatesDirPath];
    [self createDicr:logDirPath];
    NSMutableString *mainConf = [NSMutableString stringWithCapacity:10000];
    [mainConf appendFormat:@"confdir %@\n",confDirurl];
    [mainConf appendFormat:@"templdir %@\n",templatesDirPath];
    [mainConf appendFormat:@"logdir %@\n",logDirPath];
    [mainConf appendFormat:@"logfile logfile.log\n"];
    [mainConf appendFormat:@"actionsfile %@\n",userActionUrl];
    [mainConf appendFormat:@"debug 131071\n"];
    [mainConf appendFormat:@"listen-address  0.0.0.0:8118\n"];
    
    NSString *configPath = [rootUrl stringByAppendingPathComponent:@"config.txt"];
    NSFileManager *file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:configPath]) {
        [file removeItemAtPath:configPath error:nil];
    }
    [file createFileAtPath:configPath contents:nil attributes:@{}];
    NSError *error;
    [mainConf writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [self copyAction];
}
- (void)copyAction{
    NSString *rootUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"privoxy"];
    NSFileManager *file = [NSFileManager defaultManager];
    NSString *defaultFilterPath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"filter"];
    NSString *defaultActionPath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"action"];
    NSString *userFilterPath = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"filter"];
    NSString *userActionPath = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"action"];
    NSString *trustPath = [[NSBundle mainBundle] pathForResource:@"trust" ofType:@""];
    NSString *matchallPath = [[NSBundle mainBundle] pathForResource:@"match-all" ofType:@"action"];
    NSArray <NSString*> *path = @[defaultActionPath,defaultFilterPath,userActionPath,userFilterPath,trustPath,matchallPath];
    [path enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = obj.lastPathComponent;
        NSString *filePath = [rootUrl stringByAppendingPathComponent:fileName];
     
        NSString *contents = [[NSString alloc] initWithContentsOfFile:obj encoding:NSUTF8StringEncoding error:nil];
        
        
        if ([file fileExistsAtPath:filePath]) {
            [file removeItemAtPath:filePath error:nil];
        }
        [file createFileAtPath:filePath contents:nil attributes:@{}];
        NSError *error;
        [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"error = %@",error);
        } else {
            NSLog(@"copy success");
        }
    }];
}

- (void)createDicr:(NSString*)path{
    NSFileManager *file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:path] == NO) {
        NSError *error;
        [file createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{} error:&error];
        NSLog(@"%@",error);
    }
}

@end

