//
//  ViewController.m
//  Privoxy
//
//  Created by 韩肖杰 on 2019/5/6.
//  Copyright © 2019 xuqg. All rights reserved.
//

#import "ViewController.h"
#import "ProxyManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ProxyManager sharedManager] startHttpProxy:^(int port, NSError *error) {
        
    }];
    // Do any additional setup after loading the view.
}


@end
