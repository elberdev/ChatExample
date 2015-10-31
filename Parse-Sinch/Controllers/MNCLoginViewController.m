//
//  MNCLoginViewController.m
//  MiniChat
//
//  Created by xxx on 11/1/14.
//  Copyright (c) 2014 Sinch. All rights reserved.
//

#import "MNCLoginViewController.h"
#import "MNCChatMateListViewController.h"
#import "AppDelegate.h"

@interface MNCLoginViewController ()
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation MNCLoginViewController

#pragma mark - Setup methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set navigation bar title
    self.navigationItem.title = @"Chat";
    
    // set prompt label to hidden
    self.promptLabel.hidden = YES;
    
    // set up gesture to hide keyboard when user taps outside the text fields
    UITapGestureRecognizer *tapViewGR = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(didTapOnView)];
    [self.view addGestureRecognizer:tapViewGR];
}

#pragma mark - User interface behavioral methods
// if you tap outside the text fields, this method will be used to hide the keyboard
- (void)didTapOnView {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark - Functional methods
- (IBAction)signup:(id)sender {
    // Parse SDK user class
    PFUser *pfUser = [PFUser user];
    pfUser.username = self.usernameField.text;
    pfUser.password = self.passwordField.text;
    
    // This block of code will only be used after the signup process finishes so
    // we create a weak reference to the view controller to be used after signup
    // to handle the success or failure of the process. One should usually use weak
    // references to self in a callback block.
    __weak typeof(self) weakSelf = self;
    [pfUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            weakSelf.promptLabel.textColor = [UIColor greenColor];
            weakSelf.promptLabel.text = @"Signup successful!";
            weakSelf.promptLabel.hidden = NO;
        } else {
            weakSelf.promptLabel.textColor = [UIColor redColor];
            weakSelf.promptLabel.text = [error userInfo][@"error"];
            weakSelf.promptLabel.hidden = NO;
        }
    }];
}

- (IBAction)login:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [PFUser logInWithUsernameInBackground:self.usernameField.text
                                 password:self.passwordField.text
                                    block:^(PFUser *pfUser, NSError *error) {
                                        
        if (pfUser && !error) {
            // proceed to next screen after successful login
            weakSelf.promptLabel.hidden = YES;
            
            // only initialize the sinch client after a successful login to Parse
            // I suppose we are implementing this functionality inside of AppDelegate.m b/c
            // we only want to handle the Config constants through there? Not sure why we
            // wouldn't just set up this method here...
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate initSinchClient:self.usernameField.text];
            //[appDelegate initSinchClient:@"Clara"];
            
            [weakSelf performSegueWithIdentifier:@"LoginSegue" sender:self];
            
        } else {
            // the login failed, show error
            weakSelf.promptLabel.textColor = [UIColor redColor];
            weakSelf.promptLabel.text = [error userInfo][@"error"];
            weakSelf.promptLabel.hidden = NO;
        }
    }];
}

#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // make sure user list view controller has your user name
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        MNCChatMateListViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.myUserID = self.usernameField.text;
    }
}

@end
