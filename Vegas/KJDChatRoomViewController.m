//
//  ViewController.m
//  Vegas

#import "KJDChatRoomViewController.h"
#import "KJDImageDisplayViewController.h"
#import "KJDChatRoomTableViewCellRight.h"
#import "KJDChatRoomTableViewCellLeft.h"
#import "KJDChatRoomImageCellRight.h"
#import "KJDChatRoomImageCellLeft.h"
#import "AppDelegate.h"
#import <RNBlurModalView.h> 
#import "KJDMessageCell.h"
#import "KJDLeftMessageCell.h"
#import "KJDRightMediaCell.h"
#import "KJDLeftMediaCell.h"
#import "KJDRightVideoCell.h"
#import "KJDVideoDisplayer.h"
#import "KJDLeftVideoCell.h"




@interface KJDChatRoomViewController ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;
@property (strong, nonatomic) UILabel *subtitleView;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;

@property (strong, nonatomic) MPMoviePlayerController* playerController;
@property (strong, nonatomic) NSMutableArray* videos;
@property (strong, nonatomic) UIImage* thumbnail;

//jan
@property (strong, nonatomic) UIView *usernameView;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewTop;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewHeight;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewWidth;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewRight;

@property (nonatomic)CGRect keyBoardFrame;
@property(strong,nonatomic)NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray* usersInRoom;

@end

@implementation KJDChatRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
    [self.view addSubview: volumeView];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame=self.view.frame;
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    self.videos = [NSMutableArray new];
    
    //**************************
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.chatRoomVCDelegate = self;
    
    self.firstTimeInRoom = true;
    self.chatRoom.firstTimeInRoom= true;
    self.inputTextField.delegate=self;
    [self setupViewsAndConstraints];
    self.user=self.chatRoom.user;
    
    [self.chatRoom setupFirebaseWithCompletionBlock:^(BOOL completed)
     {
         if (completed)
         {
             [self.chatRoom setUpContentFirebaseWithCompletionBlock:^(BOOL completed) {
                 self.messages = self.chatRoom.messages;
                 self.user = self.chatRoom.user;
                 [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                     
                     [self.tableView reloadData];
                     if (![self.messages count] == 0)
                     {
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                     }
                 }];
             }];
             
             [self.chatRoom setUpUserCountFireBaseWithCompletionBlock:^(BOOL completedCount)
              {
                  self.userCount = self.chatRoom.userCount;
                  [self setupNavigationBar];
              }];
             
             [self.chatRoom setUpNameSwitchFireBaseWithCompletionBlock:^(NSDictionary *nameChange)
             {
                 if ([nameChange[@"oldName"] isEqual:self.user.name])
                 {
                     self.user.name = nameChange[@"newName"];
                 }
                 
                 for (NSMutableDictionary* message in self.messages)
                 {
                     if ([message[@"user"] isEqual:nameChange[@"oldName"]]) {
                         message[@"user"] = nameChange[@"newName"];
                     }
                 }
                 
             }];
         }
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailImageRetrieved:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

//jan
-(void)setViewMovedUp:(BOOL)moveUp
{
    CGRect superViewRect = self.view.frame;
    CGRect usernameViewFramePostKeyboardUp = self.usernameView.frame;
    usernameViewFramePostKeyboardUp.origin.y += self.keyBoardFrame.size.height;
    
    CGRect usernameViewFramePostKeyboardDown = self.usernameView.frame;
    usernameViewFramePostKeyboardDown.origin.y -= self.keyBoardFrame.size.height;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height+self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    
    if (moveUp){
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0.3
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            self.usernameView.frame = usernameViewFramePostKeyboardUp;
                        }
                        completion:nil];
        
    }else{
        superViewRect.origin.y += self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0.3
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            self.usernameView.frame = usernameViewFramePostKeyboardDown;
                        }
                        completion:nil];
        self.tableView.contentInset = afterInset;
    }
}

//jan
-(void)enterUserName
{
    if (![self.usernameTextField.text isEqualToString:@""])
    {
        NSString* oldName= self.user.name;
        NSString* newName = self.usernameTextField.text;
        
        [self.chatRoom.nameSwitchFireBase setValue:@{@"newName":newName,@"oldName":oldName} withCompletionBlock:^(NSError *error, Firebase *ref)
        {
            [self.tableView reloadData];
        }];
        
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=YES;
                        }
                        completion:nil];
        
        [self dismissKeyboard];
    }
    else
    {
        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Username field is empty" message:@"Please insert a valid username"];
        [modal show];
    }
}

//jan
-(void)toggleUsernameView{
    if (self.usernameView.hidden) {
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=NO;
                        }
                        completion:nil];
    }else{
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=YES;
                        }
                        completion:nil];
    }
}

//jan
-(void)setupUsernameView{
    self.usernameView=[[UIView alloc]init];
    UIColor *backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.usernameView.backgroundColor=backgroundColor;
    self.usernameView.layer.cornerRadius=10;
    self.usernameView.hidden=YES;
    self.usernameView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:self.usernameView];

    self.usernameViewTop=[NSLayoutConstraint constraintWithItem:self.usernameView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                       constant:self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height];

    self.usernameViewHeight=[NSLayoutConstraint constraintWithItem:self.usernameView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.15
                                                          constant:0.0];

    self.usernameViewWidth=[NSLayoutConstraint constraintWithItem:self.usernameView
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.view
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:2/3.0f
                                                        constant:0.0];

    self.usernameViewRight=[NSLayoutConstraint constraintWithItem:self.usernameView
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:0.0];

    [self.view addConstraints:@[self.usernameViewTop, self.usernameViewHeight, self.usernameViewWidth, self.usernameViewRight]];


    self.usernameTextField=[[UITextField alloc]init];
    self.usernameTextField.delegate=self;
    self.usernameTextField.layer.borderWidth=1;
    self.usernameTextField.layer.cornerRadius=7;
    self.usernameTextField.backgroundColor=[UIColor whiteColor];
    self.usernameTextField.textAlignment=NSTextAlignmentCenter;
    self.usernameTextField.placeholder=@"Set username";
    self.usernameTextField.translatesAutoresizingMaskIntoConstraints=NO;
    [self.usernameView addSubview:self.usernameTextField];

    NSLayoutConstraint *textFieldTop=[NSLayoutConstraint constraintWithItem:self.usernameTextField
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.usernameView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:10];

    NSLayoutConstraint *textFieldHeight=[NSLayoutConstraint constraintWithItem:self.usernameTextField
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.inputTextField
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0.0];

    NSLayoutConstraint *textFieldLeft=[NSLayoutConstraint constraintWithItem:self.usernameTextField
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.usernameView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:20.0];

    NSLayoutConstraint *textFieldRight=[NSLayoutConstraint constraintWithItem:self.usernameTextField
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.usernameView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:-20.0];

    [self.view addConstraints:@[textFieldTop, textFieldHeight, textFieldLeft, textFieldRight]];

    self.doneButton=[[UIButton alloc]init];
    [self.doneButton addTarget:self action:@selector(enterUserName) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.layer.cornerRadius=7;
    self.doneButton.translatesAutoresizingMaskIntoConstraints=NO;
    [self.usernameView addSubview:self.doneButton];

    NSLayoutConstraint *buttonTop=[NSLayoutConstraint constraintWithItem:self.doneButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.usernameTextField
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:25.0];
    
    NSLayoutConstraint *buttonBottom=[NSLayoutConstraint constraintWithItem:self.doneButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.usernameView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:-15.0];
    
    NSLayoutConstraint *buttonLeft=[NSLayoutConstraint constraintWithItem:self.doneButton
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.usernameTextField
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *buttonRight=[NSLayoutConstraint constraintWithItem:self.doneButton
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.usernameTextField
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0.0];
    
    [self.view addConstraints:@[buttonTop, buttonBottom, buttonLeft, buttonRight]];
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController])
    {
        [self removeUserFromChatRoom];
    }
}

-(void)removeUserFromChatRoom
{
    NSInteger integerCount = [self.chatRoom.userCount integerValue] - 1;
    self.chatRoom.userCount = [NSNumber numberWithInteger:integerCount];
    
    self.userCount = self.chatRoom.userCount;
    [self.chatRoom.userCountFireBase onDisconnectSetValue:@{@"userCount":self.userCount}];
    [self.chatRoom.userCountFireBase setValue:@{@"userCount":self.userCount}];
    
    if ([self.userCount isEqual:@0])
    {
        [self.chatRoom.firebase onDisconnectRemoveValue];
        [self.chatRoom.firebase removeValue];
    }
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

-(void)dismissKeyboard {
    [self.inputTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.navigationController setNavigationBarHidden:NO];
    [UIView commitAnimations];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyBoardFrame = [keyboardFrameBegin CGRectValue];
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification{
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupViewsAndConstraints
{
    [self setupNavigationBar];
    [self setupTableView];
    [self setupTextField];
    [self setupSendButton];
    [self setupMediaButton];
    [self setUpSettingsButton];
    [self setupUsernameView];
}

-(void)setupNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    self.navigationItem.backBarButtonItem.enabled = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //form stackOF
    // Replace titleView
    CGRect headerTitleSubtitleFrame = self.navigationController.navigationBar.frame;
    UIView* headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 2, 200, 24);
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20];
    titleView.textAlignment = UITextAlignmentCenter;
    titleView.textColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1.0];
    titleView.text = self.chatRoom.firebaseRoomURL;
    titleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:titleView];
    
    CGRect subtitleFrame = CGRectMake(0, 24, 200, 44-24);
    self.subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    self.subtitleView.backgroundColor = [UIColor clearColor];
    self.subtitleView.font = [UIFont boldSystemFontOfSize:13];
    self.subtitleView.textAlignment = UITextAlignmentCenter;
    self.subtitleView.textColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1.0];
    self.subtitleView.shadowColor = [UIColor darkGrayColor];
//    self.subtitleView.shadowOffset = CGSizeMake(0, -1);
    [self setUserCountInSubtitle];
    self.subtitleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:self.subtitleView];
    
    headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.titleView = headerTitleSubtitleView;
}

-(void) setUserCountInSubtitle
{
    if (! self.userCount)
    {
        self.subtitleView.text = [NSString stringWithFormat:@""];
    }
    else if ([self.userCount isEqualToValue:@1] || [self.userCount isEqualToValue:@0])
    {
        self.subtitleView.text = [NSString stringWithFormat:@"No one else in this room"];
    }
    else
    {
        self.subtitleView.text = [NSString stringWithFormat:@"%@ users in this room", self.userCount];
    }
}

-(void) setUpSettingsButton
{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings18"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleUsernameView)];//settingsButtonTapped)];
    rightButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void) setHeaderTitle:(NSString*)headerTitle andSubtitle:(NSString*)headerSubtitle {
    assert(self.navigationItem.titleView != nil);
    UIView* headerTitleSubtitleView = self.navigationItem.titleView;
    UILabel* titleView = [headerTitleSubtitleView.subviews objectAtIndex:0];
    UILabel* subtitleView = [headerTitleSubtitleView.subviews objectAtIndex:1];
    assert((titleView != nil) && (subtitleView != nil) && ([titleView isKindOfClass:[UILabel class]]) && ([subtitleView isKindOfClass:[UILabel class]]));
    titleView.text = headerTitle;
    subtitleView.text = headerSubtitle;
}

- (void)setupTableView
{
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view sendSubviewToBack:self.tableView.backgroundView];
    self.tableView.clipsToBounds=YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellLeft" bundle:nil] forCellReuseIdentifier:@"normalCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellRight" bundle:nil] forCellReuseIdentifier:@"normalCellRight"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellLeft" bundle:nil] forCellReuseIdentifier:@"imageCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellRight" bundle:nil] forCellReuseIdentifier:@"imageCellRight"];
    
    self.tableView.scrollEnabled=YES;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height];
    
    NSLayoutConstraint *tableViewBottom = [NSLayoutConstraint constraintWithItem:self.tableView
                                           
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-40.0];
    
    NSLayoutConstraint *tableViewWidth = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *tableViewLeft = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    [self.view addConstraints:@[tableViewTop, tableViewBottom, tableViewWidth, tableViewLeft]];
    
}

- (void)sendButtonTapped
{
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:1];

}

-(void)sendButtonNormal
{
    [self dismissKeyboard];
    
    if (![self.inputTextField.text isEqualToString:@""] && ![self.inputTextField.text isEqualToString:@" "]) {
        NSString *message = self.inputTextField.text;
        self.sendButton.titleLabel.textColor=[UIColor grayColor];
        [self.chatRoom.contentFireBase setValue:@{@"user":self.user.name,
                                           @"message":message
                                           }];
        self.inputTextField.text = @"";
    }
    self.sendButton.backgroundColor=[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
}

- (void)setupSendButton
{
    self.sendButton = [[UIButton alloc] init];
    [self.view addSubview:self.sendButton];
    self.sendButton.backgroundColor=[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.sendButton.layer.cornerRadius=10.0f;
    self.sendButton.layer.masksToBounds=YES;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:nil] forState:UIControlStateNormal];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(sendButtonNormal) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    NSLayoutConstraint *sendButtonTop = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:4.0];
    
    NSLayoutConstraint *sendButtonBottom = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-4.0];
    
    NSLayoutConstraint *sendButtonLeft = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:4.0];
    
    NSLayoutConstraint *sendButtonRight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.tableView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-4.0];
    
    [self.view addConstraints:@[sendButtonTop, sendButtonBottom, sendButtonLeft, sendButtonRight]];
}

-(void)setupMediaButton
{
    self.mediaButton = [[UIButton alloc] init];
    [self.view addSubview:self.mediaButton];
    self.mediaButton.backgroundColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    [self.mediaButton setImage:[UIImage imageNamed:@"photo-abstract-7"] forState:UIControlStateNormal];

    [self.mediaButton addTarget:self action:@selector(mediaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.mediaButton.titleLabel.textColor = [UIColor whiteColor];
    self.mediaButton.layer.cornerRadius=10.0f;
    self.mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mediaButtonTop = [NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0];
    
    NSLayoutConstraint *mediaButtonBottom =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.inputTextField
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    
    NSLayoutConstraint *mediaButtonLeft =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:4];
    
    NSLayoutConstraint *mediaButtonRight =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:-4];
    
    [self.view addConstraints:@[mediaButtonTop, mediaButtonBottom, mediaButtonLeft, mediaButtonRight]];
}

- (void)setupTextField{
    self.inputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.inputTextField];
    self.inputTextField.layer.cornerRadius=10.0f;
    self.inputTextField.layer.masksToBounds=YES;
    UIColor *borderColor=[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.inputTextField.layer.borderColor=[borderColor CGColor];
    self.inputTextField.layer.borderWidth=1.5f;
    self.inputTextField.backgroundColor=[UIColor clearColor];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.inputTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.inputTextField setLeftView:spacerView];
    
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *textFieldTop = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.tableView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:4.0];
    
    NSLayoutConstraint *textFieldBottom = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-4.0];
    
    NSLayoutConstraint *textFieldLeft = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:40.0];
    
    NSLayoutConstraint *textFieldRight = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-80.0];
    
    [self.view addConstraints:@[textFieldTop, textFieldBottom, textFieldLeft, textFieldRight]];
}

-(void)summonMap
{
    KJDMapKitViewController* mapKitView = [[KJDMapKitViewController alloc] init];
    mapKitView.user = self.user;
    mapKitView.chatRoom = self.chatRoom;
    
    [self presentViewController:mapKitView animated:YES completion:^{
        
    }];
}

-(NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);

    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(NSString*)videoToNSString:(NSURL*)video
{
    NSData* videoData =[NSData dataWithContentsOfURL:video options:NSDataReadingMappedAlways error:nil];
    
    return [videoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [UIImage imageWithData:data];
}

-(MPMoviePlayerController*)stringToVideo:(NSString*)string
{
    NSData* videoData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%@.mp4", [self currentTime]];
    
    BOOL success = [videoData writeToFile:tempPath atomically:NO];
    
    NSURL* pathURL = [[NSURL alloc] initFileURLWithPath:tempPath];
    
    MPMoviePlayerController* player = [[MPMoviePlayerController alloc]initWithContentURL:pathURL];
    
    return player;
}

-(NSString*)currentTime
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    return [outputFormatter stringFromDate:now];
}


-(NSURL*) obtainVideoURL:(NSString*)encodedVideo At:(NSIndexPath*)indexPath
{
    NSData* videoData = [[NSData alloc] initWithBase64EncodedString:encodedVideo options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%ld.mp4", (long)indexPath.row];
    
    BOOL success = [videoData writeToFile:tempPath atomically:NO];
    
    NSURL* pathURL = [[NSURL alloc] initFileURLWithPath:tempPath];
    return pathURL;
}

-(BOOL)systemVersionLessThan8
{
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return deviceVersion < 8.0f;
}

-(void) sendMapImage:(UIImage*)map
{
    NSString* photoInString = [self imageToNSString:map];
    
    [self.chatRoom.contentFireBase setValue:@{@"user":self.user.name,
                                       @"image":photoInString}];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString* mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    
    if([mediaType isEqualToString:@"public.image"])
    {
        UIImage* extractedPhoto = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSString* photoInString = [self imageToNSString:extractedPhoto];

        
        [self.chatRoom.contentFireBase setValue:@{@"user":self.user.name,
                                           @"image":photoInString}];
        
    }
    else if([mediaType isEqualToString:@"public.movie"])
    {
        
        NSURL* videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString* videoInString = [self videoToNSString:videoURL];
        
        [self.chatRoom.contentFireBase setValue:@{@"user":self.user.name,
                                           @"video":videoInString}];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) mediaButtonTapped
{
    if ([self systemVersionLessThan8])
    {
        UIAlertView* mediaAlert = [[UIAlertView alloc] initWithTitle:@"Share something!" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a Picture or Video", @"Choose an existing Photo or Video", @"Share location", nil];
        
        [mediaAlert show];
    }
    else
    {
        UIAlertController* mediaAlert = [UIAlertController alertControllerWithTitle:@"Share something!" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"Take a Picture or Video"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){[self obtainImageFrom:UIImagePickerControllerSourceTypeCamera];
                                                          }];
        [mediaAlert addAction:takePhoto];
        
        UIAlertAction* chooseExistingPhoto = [UIAlertAction actionWithTitle:@"Choose an existing Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self obtainImageFrom:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        
        [mediaAlert addAction:chooseExistingPhoto];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        
        [mediaAlert addAction:cancel];
        
        UIAlertAction* showLocation = [UIAlertAction actionWithTitle:@"Share Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self summonMap];
        }];
        
        [mediaAlert addAction:showLocation];
        
        [self presentViewController:mediaAlert animated:YES completion:^{
            
        }];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self obtainImageFrom:UIImagePickerControllerSourceTypeCamera];
    }else if (buttonIndex == 2){
        [self obtainImageFrom:UIImagePickerControllerSourceTypePhotoLibrary];
    }else if (buttonIndex == 3){
        [self summonMap];
    }
}

-(void) obtainImageFrom:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.mediaTypes = mediaTypesAllowed;
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:^{
                         
                     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 //height in points
    if ([self.messages count] !=0)
    {
        NSMutableDictionary *message=self.messages[indexPath.row];
        
        if ([message objectForKey:@"message"]!=nil)
        {
            NSDictionary *message=self.messages[indexPath.row];
            NSString * yourText = message[@"message"];
            return 21 + [self heightForText:yourText];
        }
        else
        {
            if (message[@"image"])
            {
                UIImage* picture = [self stringToUIImage:message[@"image"]];
                return [self cellHeightForImage:picture] + 21;
            }
            else if (message[@"map"])
            {
                UIImage* picture = [self stringToUIImage:message[@"map"]];
                return [self cellHeightForImage:picture] + 21;
            }
            else if (message[@"video"])
            {
                return (self.tableView.frame.size.width *5/8.0f -4) + 21;
            }
        }
    }
    return 0;
}

-(CGFloat) cellHeightForImage:(UIImage*)picture
{
    CGFloat ratio = picture.size.height/picture.size.width;
    CGFloat cellHeight = ratio * self.tableView.frame.size.width * (5/8.0f);
    return cellHeight;
}

//from jan - not called
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

//from jan
-(CGFloat)heightForText:(NSString *)text
{
    NSInteger MAX_HEIGHT = 9999;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width * (5/8.0f), MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    [textView sizeToFit];
    return textView.frame.size.height;
}

//from Jan - not called
- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width
{
    UILabel* calculationLabel = [[UILabel alloc]init];
    [calculationLabel setAttributedText:text];
    CGSize size = [calculationLabel sizeThatFits:CGSizeMake(width, FLT_MAX)];
    
//    UITextView *calculationView = [[UITextView alloc] init];
//    [calculationView setAttributedText:text];
//    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

-(void)changeVolumeTo:(CGFloat)level
{
    MPVolumeView* volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    
    for (UIView *view in [volumeView subviews])
    {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    [volumeViewSlider setValue:level animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

//-(void)thumbnailImageRetrieved:(NSNotification*)notification
//{
//    NSDictionary *userInfo = [notification userInfo];
//    UIImage *image = [userInfo valueForKey:MPMoviePlayerThumbnailImageKey];
//    self.thumbnail = image;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *content=self.messages[indexPath.row];
    
    if (content[@"video"])
    {
        MPMoviePlayerController* player = [self stringToVideo:content[@"video"]];
        
        UIImage* thumbnail = [player thumbnailImageAtTime:1.0f timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:thumbnail];
        UIImageView* playIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play"]];
        
        player.view.frame = CGRectMake(0, 0, self.tableView.frame.size.width * 5/8.0f - 4, self.tableView.frame.size.width * 5/8.0f-8);
        thumbnailView.frame = player.view.frame;
        playIcon.frame = CGRectMake(0, 0, 100, 100);
        playIcon.backgroundColor = [UIColor clearColor];
        [self changeVolumeTo:0];
    
        if ([content[@"user"] isEqualToString:self.user.name])
        {
            KJDRightVideoCell* cell = (KJDRightVideoCell*)[tableView dequeueReusableCellWithIdentifier:@"rightVideoCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDRightVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rightVideoCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpVideoView];
            
            cell.senderName.attributedText = attributedUserName;
            
            if ([cell.videoView.subviews count] == 0)
            {
                [player.backgroundView addSubview:thumbnailView];
                [player.backgroundView addSubview:playIcon];
                [cell.videoView addSubview:player.view];
                player.shouldAutoplay = YES;
                player.allowsAirPlay = YES;
                player.scalingMode = MPMovieScalingModeAspectFill;
                player.repeatMode = MPMovieRepeatModeNone;
                [player play];
            }
            else
            {
                [player pause];
            }

            
            return cell;
        }
        else
        {
            KJDLeftVideoCell* cell = (KJDLeftVideoCell*)[tableView dequeueReusableCellWithIdentifier:@"leftVideoCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDLeftVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftVideoCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpVideoView];
            
            cell.senderName.attributedText = attributedUserName;
            
            if ([cell.videoView.subviews count] == 0)
            {
                [player.backgroundView addSubview:thumbnailView];
                [player.backgroundView addSubview:playIcon];
                [cell.videoView addSubview:player.view];
                player.shouldAutoplay = YES;
                player.allowsAirPlay = YES;
                player.scalingMode = MPMovieScalingModeAspectFill;
                player.repeatMode = MPMovieRepeatModeNone;
                [player play];
            }
            else
            {
                [player pause];
            }
            return cell;
        }
    }
    if (content[@"map"])
    {
        NSString* imageInCode = content[@"map"];
        UIImage* imageToDisplay = [self stringToUIImage:imageInCode];
        
        if ([content[@"user"] isEqualToString:self.user.name])
        {
            KJDRightMediaCell* cell = (KJDRightMediaCell*)[tableView dequeueReusableCellWithIdentifier:@"rightMediaCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDRightMediaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rightMediaCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMediaView];
            cell.media.contentMode = UIViewContentModeScaleAspectFit;
            cell.media.image = imageToDisplay;
            cell.senderName.attributedText = attributedUserName;
            
            return cell;
        }
        else
        {
            KJDLeftMediaCell* cell = (KJDLeftMediaCell*)[tableView dequeueReusableCellWithIdentifier:@"leftMediaCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDLeftMediaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMediaCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMediaView];
            cell.media.contentMode = UIViewContentModeScaleAspectFit;
            cell.media.image = imageToDisplay;
            cell.senderName.attributedText = attributedUserName;
            
            return cell;
        }
    }
    else if (content[@"image"])
    {
        
        NSString* imageInCode = content[@"image"];
        UIImage* imageToDisplay = [self stringToUIImage:imageInCode];
        
        if ([content[@"user"] isEqualToString:self.user.name])
        {
            KJDRightMediaCell* cell = (KJDRightMediaCell*)[tableView dequeueReusableCellWithIdentifier:@"rightMediaCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDRightMediaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rightMediaCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMediaView];
            cell.media.contentMode = UIViewContentModeScaleAspectFit;
            cell.media.image = imageToDisplay;
            cell.senderName.attributedText = attributedUserName;
            
            return cell;
        }
        else
        {
            KJDLeftMediaCell* cell = (KJDLeftMediaCell*)[tableView dequeueReusableCellWithIdentifier:@"leftMediaCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            if (cell == nil)
            {
                cell = [[KJDLeftMediaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMediaCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMediaView];
            cell.media.contentMode = UIViewContentModeScaleAspectFit;
            cell.media.image = imageToDisplay;
            cell.senderName.attributedText = attributedUserName;
            
            return cell;
        }
    }
    else if (content[@"message"])
    {
        NSString *messageTyped=[NSString stringWithFormat:@"%@", content[@"message"]];
        
        if ([content[@"user"] isEqualToString:self.user.name])
        {
            KJDMessageCell* cell = (KJDMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"messageCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc]initWithString:messageTyped];
            [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0] range:NSMakeRange(0, [attributedMessage length])];
            
            if (cell == nil)
            {
                cell = [[KJDMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMessageLabel];
            cell.senderName.attributedText = attributedUserName;
            cell.message.attributedText = attributedMessage;
            
            return cell;
        }
        else
        {
            KJDLeftMessageCell* cell = (KJDLeftMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"leftMessageCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc]initWithString:messageTyped];
            [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0] range:NSMakeRange(0, [attributedMessage length])];
            
            if (cell == nil)
            {
                cell = [[KJDLeftMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMessageCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMessageLabel];
            cell.senderName.attributedText = attributedUserName;
            cell.message.attributedText = attributedMessage;
            
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *content=self.messages[indexPath.row];
    
    if (content[@"map"])
    {
        UITableViewCell* mapCell = [self.tableView cellForRowAtIndexPath:indexPath];
        KJDImageDisplayViewController* imageDisplayVC = [[KJDImageDisplayViewController alloc]init];
        
        //in future might cause trouble bc we use leftCell for both right and left scenario.
        imageDisplayVC.mapImage = ((KJDLeftMediaCell*)mapCell).media.image;
        [imageDisplayVC setModalPresentationStyle:UIModalPresentationFullScreen];
        
        [self presentViewController:imageDisplayVC animated:YES completion:^
        {
        }];
    }
    else if (content[@"video"])
    {
        NSURL* videoURL = [self obtainVideoURL:content[@"video"] At:indexPath];
        KJDVideoDisplayer* videoDisplay = [[KJDVideoDisplayer alloc]initWithContentURL:videoURL];
        [self changeVolumeTo:1.0f];
        [self presentMoviePlayerViewControllerAnimated:videoDisplay];
    }
}


@end
