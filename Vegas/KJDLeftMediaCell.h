//
//  KJDLeftMediaCell.h
//  Vegas
//
//  Created by Karim Mourra on 12/30/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJDLeftMediaCell : UITableViewCell

@property (nonatomic, strong) UILabel* senderName;
@property (nonatomic, strong) UIImageView* media;

-(void) setUpSenderNameLabel;
-(void) setUpMediaView;

@end
