//
//  MNCChatMessage.h
//  ios-sinch-messaging-tutorial
//
//  Created by Elber Carneiro on 9/14/15.
//  Copyright © 2015 christian jensen. All rights reserved.
//

// We will use this custom class to hold the Sinch messages, by adopting
// the Sinch message protocol

#import <Foundation/Foundation.h>
#import <Sinch/Sinch.h>

@interface MNCChatMessage : NSObject <SINMessage>
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSArray *recipientIds;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDictionary *headers;
@property (strong, nonatomic) NSDate *timestamp;
@end
