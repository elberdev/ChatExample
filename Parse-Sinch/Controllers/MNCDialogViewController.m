//
//  MNCDialogViewController.m
//  MiniChat
//
//  Created by xxx on 11/2/14.
//  Copyright (c) 2014 Sinch. All rights reserved.
//

#import "MNCDialogViewController.h"
#import "MNCChatMessageCell.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface MNCDialogViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *messageEditField;
@property (strong, nonatomic) IBOutlet UITableView *historicalMessagesTableView;
@property (strong, nonatomic) UITextField *activeTextField;
@end

@implementation MNCDialogViewController

#pragma mark - Setup methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.chatMateID;
    self.messageArray = [NSMutableArray new];
    [self retrieveMessagesFromParseWithChatMateID:self.chatMateID];
    
    UIGestureRecognizer *tapTableGR = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.historicalMessagesTableView addGestureRecognizer:tapTableGR];
    [self registerForKeyboardNotifications];
}

- (void)retrieveMessagesFromParseWithChatMateID:(NSString *)chatMateID {
    NSArray *userNames = @[self.myUserID, chatMateID];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SinchMessage"];
    [query whereKey:@"senderId" containedIn:userNames];
    [query whereKey:@"recipientId" containedIn:userNames];
    [query orderByAscending:@"timestamp"];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *chatMessageArray, NSError *error) {
        if (!error) {
            // store all retrieved messages into the message array
            for (int i = 0; i < [chatMessageArray count]; i++) {
                MNCChatMessage *chatMessage = [MNCChatMessage new];
                [chatMessage setMessageId:chatMessageArray[i][@"messageId"]];
                [chatMessage setSenderId:chatMessageArray[i][@"senderId"]];
                [chatMessage setRecipientIds:[NSArray arrayWithObject:chatMessageArray[i][@"recipientId"]]];
                [chatMessage setText:chatMessageArray[i][@"text"]];
                [chatMessage setTimestamp:chatMessageArray[i][@"timestamp"]];
                
                [weakSelf.messageArray addObject:chatMessage];
            }
            NSLog(@"%@", self.messageArray);
            [weakSelf.historicalMessagesTableView reloadData];
            [weakSelf scrollTableToBottom];
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

// setup keyboard notifications
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - Interface behavior
- (void)didTapOnTableView {
    [self.activeTextField resignFirstResponder];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // if active text field is hidden by the keyboard, scroll the view so the
    // text field is visible
    CGRect rect = self.view.frame;
    rect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(rect, self.activeTextField.frame.origin)) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Functional methods
- (IBAction)sendMessage:(id)sender {
    // Send the message to the server
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendTextMessage:self.messageEditField.text toRecipient:self.chatMateID];
    
    // Update the message on the screen without contacting server?
    MNCChatMessage *outgoingMessage = [MNCChatMessage new];
    outgoingMessage.text = self.messageEditField.text;
    outgoingMessage.senderId = self.myUserID;
    [self.messageArray addObject:outgoingMessage];
    [self.historicalMessagesTableView reloadData];
    [self scrollTableToBottom];
    
    // Clear text in textfield
    self.messageEditField.text = @"";
    [self.messageEditField setNeedsDisplay];
}

- (void)scrollTableToBottom {
    NSInteger rowNumber = [self.historicalMessagesTableView numberOfRowsInSection:0];
    if (rowNumber > 0) {
        [self.historicalMessagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber - 1 inSection:0]
                                                atScrollPosition:UITableViewScrollPositionBottom
                                                        animated:YES];
    }
}

#pragma mark - UITableViewSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNCChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"MessageListPrototypeCell"
                                                                      forIndexPath:indexPath];
    [self configureCell:messageCell forIndexPath:indexPath];
    
    return messageCell;
}

- (void)configureCell:(MNCChatMessageCell *)messageCell forIndexPath:(NSIndexPath *)indexPath {
    MNCChatMessage *chatMessage = self.messageArray[indexPath.row];
    
    if ([chatMessage.senderId isEqualToString:self.myUserID]) {
        // if the message was sent by myself
        messageCell.chatMateMessageLabel.text = @"";
        messageCell.myMessageLabel.text = chatMessage.text;
    } else {
        // if the message was sent by the chat mate
        messageCell.chatMateMessageLabel.text = chatMessage.text;
        messageCell.myMessageLabel.text = @"";
    }
}

#pragma mark - UIScrollViewDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

@end;