//
//  KJDImageDisplayViewController.m
//  Vegas
//
//  Created by Karim Mourra on 12/10/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import "KJDImageDisplayViewController.h"
#import "KJDChatRoomImageCellLeft.h"
#import "KJDChatRoomImageCellRight.h"
#import "KJDLoginViewController.h"
#import <RNBlurModalView.h>

@interface KJDImageDisplayViewController ()

@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *vegasLabel;

@end

@implementation KJDImageDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame=self.view.frame;
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [self setUpDisplay];
    [self setUpVegasLabel];
//    [self setUpDoneButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissImageView)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self presentIntroMessage];
}

-(void) presentIntroMessage
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Hey!" message:@"To return to the Chat Room, simply tap the screen!"];
        [modal show];
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) setUpVegasLabel
{
    self.vegasLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, 20)];
    NSMutableAttributedString *attributedVegas = [[NSMutableAttributedString alloc]initWithString:@"Vegas!"];
    [attributedVegas addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15] range:NSMakeRange(0, [attributedVegas length])];
    self.vegasLabel.attributedText = attributedVegas;
    self.vegasLabel.textAlignment = NSTextAlignmentCenter;
    self.vegasLabel.backgroundColor = [UIColor clearColor];
    self.vegasLabel.textColor = [UIColor colorWithRed:4/255.0f green:74/255.0f blue:11/255.0f alpha:1];
    [self.view addSubview:self.vegasLabel];
}

-(void) setUpDisplay
{
    self.map = [[UIImageView alloc]initWithImage:self.mapImage];
    CGFloat ratio = self.mapImage.size.height/self.mapImage.size.width;
    CGFloat scaledHeight = ratio * self.view.frame.size.width;
    self.map.frame = CGRectMake(self.view.center.x - self.view.frame.size.width/2.0f, self.view.center.y - scaledHeight/2.0f, self.view.frame.size.width, scaledHeight);
    
    [self.view addSubview:self.map];
//    self.map.translatesAutoresizingMaskIntoConstraints = NO;
    
//    NSLayoutConstraint *mapViewTop = [NSLayoutConstraint constraintWithItem:self.map
//                                                                  attribute:NSLayoutAttributeTop
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:self.view
//                                                                  attribute:NSLayoutAttributeTop
//                                                                 multiplier:1.0
//                                                                   constant:0.0];
//    
//    NSLayoutConstraint *mapViewBottom = [NSLayoutConstraint constraintWithItem:self.map
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:self.view
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                    multiplier:1.0
//                                                                      constant:-60.0];
//    
//    NSLayoutConstraint *mapViewWidth = [NSLayoutConstraint constraintWithItem:self.map
//                                                                    attribute:NSLayoutAttributeWidth
//                                                                    relatedBy:NSLayoutRelationEqual
//                                                                       toItem:self.view
//                                                                    attribute:NSLayoutAttributeWidth
//                                                                   multiplier:1.0
//                                                                     constant:0.0];
//    
//    NSLayoutConstraint *mapViewLeft = [NSLayoutConstraint constraintWithItem:self.map
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.view
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                  multiplier:1.0
//                                                                    constant:0.0];
//    
//    [self.view addConstraints:@[mapViewTop, mapViewBottom, mapViewWidth, mapViewLeft]];
}

-(void) dismissImageView
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void) setUpDoneButton
{
    self.doneButton = [[UIButton alloc] init];
    [self.view addSubview:self.doneButton];
    self.doneButton.backgroundColor=[UIColor colorWithRed:4/255.0f green:74/255.0f blue:11/255.0f alpha:1];
    self.doneButton.layer.cornerRadius=10.0f;
    self.doneButton.layer.masksToBounds=YES;
    [self.doneButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Done!" attributes:nil] forState:UIControlStateNormal];
    self.doneButton.titleLabel.textColor=[UIColor whiteColor];
    [self.doneButton addTarget:self action:@selector(doneButtonNormal) forControlEvents:UIControlEventTouchDown];
    [self.doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint* doneButtonHeight = [NSLayoutConstraint constraintWithItem:self.doneButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0
                                                                         constant:60];
    
//    NSLayoutConstraint *doneButtonTop = [NSLayoutConstraint constraintWithItem:self.doneButton
//                                                                   attribute:NSLayoutAttributeTop
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.map
//                                                                   attribute:NSLayoutAttributeBottom
//                                                                  multiplier:1.0
//                                                                    constant:4.0];
    
    NSLayoutConstraint *doneButtonBottom = [NSLayoutConstraint constraintWithItem:self.doneButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:-4.0];
    
    NSLayoutConstraint *doneButtonRight = [NSLayoutConstraint constraintWithItem:self.doneButton
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:-4.0];
    
    NSLayoutConstraint *doneButtonLeft = [NSLayoutConstraint constraintWithItem:self.doneButton
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:4.0];
    
    [self.view addConstraints:@[doneButtonHeight, doneButtonBottom, doneButtonRight, doneButtonLeft]];
}

- (void)doneButtonTapped
{
    self.doneButton.backgroundColor=[UIColor colorWithRed:4/255.0f green:74/255.0f blue:11/255.0f alpha:1];
    self.doneButton.titleLabel.textColor=[UIColor whiteColor];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(void)doneButtonNormal
{
    self.doneButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:.5];
}

@end
