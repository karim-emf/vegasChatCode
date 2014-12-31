//
//  KJDLeftMediaCell.m
//  Vegas
//
//  Created by Karim Mourra on 12/30/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import "KJDLeftMediaCell.h"

@implementation KJDLeftMediaCell

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
        
        self.media = [[UIImageView alloc] init];
        [self.media sizeToFit];
        self.media.backgroundColor = [UIColor clearColor];
        [self addSubview:self.media];
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
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:4.0];
    
    [self addConstraints:@[labelTop, labelHeight, labelWidth, labelLeft]];
    
    
}

-(void) setUpMediaView
{
    
    self.media.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mediaTop = [NSLayoutConstraint constraintWithItem:self.media
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.senderName
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:4.0];
    
    NSLayoutConstraint *mediaBottom = [NSLayoutConstraint constraintWithItem:self.media
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-12.0];
    
    NSLayoutConstraint *mediaWidth = [NSLayoutConstraint constraintWithItem:self.media
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.senderName
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    NSLayoutConstraint *mediaRight = [NSLayoutConstraint constraintWithItem:self.media
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.senderName
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self addConstraints:@[mediaTop, mediaBottom, mediaWidth, mediaRight]];
}

@end
