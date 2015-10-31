//
//  MNCChatMateListViewController.h
//  MiniChat
//
//  Created by xxx on 11/1/14.
//  Copyright (c) 2014 Sinch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MNCDialogViewController.h"

@interface MNCChatMateListViewController : UITableViewController <UITableViewDataSource>
@property (strong, nonatomic) NSString *myUserID;
@end