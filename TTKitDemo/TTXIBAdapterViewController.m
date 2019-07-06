//
//  TTXIBAdapterViewController.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/27.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTXIBAdapterViewController.h"
#import "TTLayoutAdapter.h"

@interface TTXIBAdapterViewController ()
@property (weak, nonatomic) IBOutlet UIView *customAdaptLine;

@end

@implementation TTXIBAdapterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ]) {
        self.customAdaptLine.tt_adaptsLayoutHandler = ^TTLayoutAdaptsResult(NSLayoutConstraint * _Nonnull constraint) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = [UIScreen mainScreen].scale;
                return TTLayoutAdaptsResultDone;
            }
            return TTLayoutAdaptsResultIgnore;
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
