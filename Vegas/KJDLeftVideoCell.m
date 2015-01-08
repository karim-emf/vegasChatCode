//
//  KJDLeftVideoCell.m
//  Vegas
//
//  Created by Karim Mourra on 1/7/15.
//  Copyright (c) 2015 Jan Roures Mintenig. All rights reserved.
//

#import "KJDLeftVideoCell.h"

@implementation KJDLeftVideoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.senderName = [[UILabel alloc] init];
        self.senderName.textColor = [UIColor blackColor];
        self.senderName.backgroundColor = [UIColor clearColor];
        self.senderName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.senderName];
        
        self.videoView = [[UIView alloc] init];
        [self.videoView sizeToFit];
        self.videoView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.videoView];
    }
    return self;
}

-(void) setUpSenderNameLabel
{
    
    self.senderName.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:4.0];
    
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0.0
                                                                    constant:17];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:5/8.0f
                                                                   constant:4.0];
    
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:4.0];
    
    [self addConstraints:@[labelTop, labelHeight, labelWidth, labelRight]];
    
    
}

-(void) setUpVideoView
{
    
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *videoViewTop = [NSLayoutConstraint constraintWithItem:self.videoView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.senderName
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:4.0];
    
    NSLayoutConstraint *videoViewBottom = [NSLayoutConstraint constraintWithItem:self.videoView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-4.0];
    
    NSLayoutConstraint *videoViewWidth = [NSLayoutConstraint constraintWithItem:self.videoView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.senderName
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *videoViewRight = [NSLayoutConstraint constraintWithItem:self.videoView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.senderName
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    [self addConstraints:@[videoViewTop, videoViewBottom, videoViewWidth, videoViewRight]];
    
}

@end
