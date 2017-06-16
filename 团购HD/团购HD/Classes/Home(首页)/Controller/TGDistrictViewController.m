//
//  TGDistrictViewController.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIView+Extension.h"

#import "TGDistrictViewController.h"
#import "TGHomeDropDownMenu.h"
#import "TGCityViewController.h"
#import "TGNavigationController.h"

@interface TGDistrictViewController ()
- (IBAction)switchCity;

@end

@implementation TGDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *title = [self.view.subviews firstObject];
    
    TGHomeDropDownMenu *dropDownMenu = [TGHomeDropDownMenu dropDownMenu];
    [self.view addSubview:dropDownMenu];
    dropDownMenu.y = CGRectGetMaxY(title.frame);
    
    self.preferredContentSize = CGSizeMake(dropDownMenu.width, CGRectGetMaxY(dropDownMenu.frame));
    
}


- (IBAction)switchCity {
    
    TGCityViewController *cityVc = [[TGCityViewController alloc] init];
    TGNavigationController *navCityVc = [[TGNavigationController alloc] initWithRootViewController:cityVc];
    navCityVc.modalPresentationStyle =  UIModalPresentationFormSheet;
    [self presentViewController:navCityVc animated:YES completion:nil];

}
@end
