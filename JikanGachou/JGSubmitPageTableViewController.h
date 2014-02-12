//
//  JGSubmitPageTableViewController.h
//  JikanGachou
//
//  Created by AquarHEAD L. on 2/12/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGSubmitPageTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *recpField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextview;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end
