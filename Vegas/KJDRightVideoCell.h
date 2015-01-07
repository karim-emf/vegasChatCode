//
//  KJDRightVideoCell.h
//  Vegas
//
//  Created by Karim Mourra on 1/3/15.
//  Copyright (c) 2015 Jan Roures Mintenig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface KJDRightVideoCell : UITableViewCell

@property (nonatomic, strong) UILabel* senderName;
@property (nonatomic, strong) UIView* videoView;
@property (nonatomic, strong) MPMoviePlayerController* player;

//-(void) setUpSenderNameLabelWithBlock:(void (^)())completionBlock;
-(void) setUpSenderNameLabel;
-(void) setUpVideoView;

-(void)tieVideo:(MPMoviePlayerController*)player;

@end
