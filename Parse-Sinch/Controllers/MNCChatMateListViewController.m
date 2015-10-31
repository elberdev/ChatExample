//
//  MNCChatMateListViewController.m
//  MiniChat
//
//  Created by xxx on 11/1/14.
//  Copyright (c) 2014 Sinch. All rights reserved.
//

#import "MNCChatMateListViewController.h"

@interface MNCChatMateListViewController ()
@property (strong, nonatomic) NSMutableArray *chatMatesArray;
@property (strong, nonatomic) MNCDialogViewController *activeDialogViewController;
@end

@implementation MNCChatMateListViewController

#pragma mark - Setup methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.myUserID;
    self.chatMatesArray = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activeDialogViewController = nil;
    // Make sure we get an up-to-date user list every time our view appears
    [self retrieveChatMatesFromParse];
}

// Make sure when the user clicks the logout button in the navigation bar
// that it actually logs him out before this view controller pops off the stack.
- (void)dealloc {
    [PFUser logOut];
}

#pragma mark - UITableViewDataSource protocol methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatMatesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMateListPrototypeCell" forIndexPath:indexPath];
    cell.textLabel.text = self.chatMatesArray[indexPath.row];
    
    return cell;
}

#pragma mark - Functional methods
- (void)retrieveChatMatesFromParse {
    // clear the array in order to have the most up-to-date information
    [self.chatMatesArray removeAllObjects];
    
    // create a query to retrieve app usernames (registered users), but excluding
    // our own username
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query whereKey:@"username" notEqualTo:self.myUserID];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *chatMateArray, NSError *error) {
        if (!error) {
            for (int i = 0; i < [chatMateArray count]; i++) {
                [weakSelf.chatMatesArray addObject:chatMateArray[i][@"username"]];
            }
            [weakSelf.tableView reloadData];
        } else {
            NSLog(@"Error %@", error.description);
        }
    }];
}

#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OpenDialogSegue"]) {
        
        // set active dialog vc to destination vc
        self.activeDialogViewController = segue.destinationViewController;
        
        // get the index of the cell
        NSInteger chatMateIndex = [[self.tableView indexPathForCell:(UITableViewCell *)sender] row];
        
        // set the user name of the person you are taling to according to the cell index. This will
        // be used for the navigation bar title of the destination tableview.
        self.activeDialogViewController.chatMateID = self.chatMatesArray[chatMateIndex];
        
        // pass our user name along as well
        self.activeDialogViewController.myUserID = self.myUserID;
        
        // ?
        return;
    }
}

@end
