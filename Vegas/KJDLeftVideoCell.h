//
//  KJDLeftVideoCell.h
//  Vegas
//
//  Created by Karim Mourra on 1/7/15.
//  Copyright (c) 2015 Jan Roures Mintenig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJDLeftVideoCell : UITableViewCell

@property (nonatomic, strong) UILabel* senderName;
@property (nonatomic, strong) UIView* videoView;

-(void) setUpSenderNameLabel;
-(void) setUpVideoView;

@end
