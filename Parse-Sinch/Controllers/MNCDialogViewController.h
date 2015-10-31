//
//  MNCDialogViewController.h
//  MiniChat
//
//  Created by xxx on 11/2/14.
//  Copyright (c) 2014 Sinch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNCChatMessage.h"

@interface MNCDialogViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) NSString *myUserID;
@property (strong, nonatomic) NSString *chatMateID;
@property (strong, nonatomic) NSMutableArray *messageArray;
@end
