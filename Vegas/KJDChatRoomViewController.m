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


@interface KJDChatRoomViewController ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;
@property (strong, nonatomic) UILabel *subtitleView;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;

@property (strong,nonatomic) MPMoviePlayerController* playerController;

@property (nonatomic)CGRect keyBoardFrame;
@property(strong,nonatomic)NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray* usersInRoom;

@end

@implementation KJDChatRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    backgroundImage.frame=self.view.frame;
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
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
                  
                  //moved to chatRoom
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
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:tap];
    
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
    //do your stuff
    //but don't forget to dismiss the viewcontroller
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




    /*
     To ensure that when everybody leaves, chat room is deleted.
     potential problem: triggered when map opened
     ======
     potential solution:
     
     Another solution is to add a custom responder to the back button. You can modify your viewController's init method as follow:
     
     - (id)init {
     if (self = [super init]) {
     //other your stuff goes here
     //...
     //here we customize the target and action for the backBarButtonItem
     //every navigationController has one of this item automatically configured to pop back
     self.navigationItem.backBarButtonItem.target = self;
     self.navigationItem.backBarButtonItem.action = @selector(backButtonDidPressed:);
     }
     return self;
     }
     
     
     and then you can use a selector method as the following. Be sure to dismiss correctly the viewController, otherwise your navigation controller won't pop as wanted.
     
     - (void)backButtonDidPressed:(id)aResponder {
     //do your stuff
     //but don't forget to dismiss the viewcontroller
     [self.navigationController popViewControllerAnimated:TRUE];
     }
     ======
     
     count = count -1
     
     firebase set value count
     
     if count ==0, firebase remove
     
     */


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

-(void)dismissKeyboard {
    [self.inputTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
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

-(void)setViewMovedUp:(BOOL)moveUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect superViewRect = self.view.frame;
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height+self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    if (moveUp){
        self.tableView.contentInset = inset;
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
    }else{
        self.tableView.contentInset = afterInset;
        superViewRect.origin.y += self.keyBoardFrame.size.height;
    }
    self.view.frame = superViewRect;
    [UIView commitAnimations];
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupViewsAndConstraints {
    [self setupNavigationBar];
    [self setupTableView];
    [self setupTextField];
    [self setupSendButton];
    [self setupMediaButton];
    [self setUpSettingsButton];
}

-(void)setupNavigationBar{
//    self.navigationItem.title=self.chatRoom.firebaseRoomURL;
    


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
//    titleView.shadowColor = [UIColor darkGrayColor];
//    titleView.shadowOffset = CGSizeMake(0, -1);
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
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings18"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped)];
    rightButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void) settingsButtonTapped
{
    
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
//    self.tableView.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    [self.view sendSubviewToBack:self.tableView.backgroundView];
    self.tableView.clipsToBounds=YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellLeft" bundle:nil] forCellReuseIdentifier:@"normalCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellRight" bundle:nil] forCellReuseIdentifier:@"normalCellRight"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellLeft" bundle:nil] forCellReuseIdentifier:@"imageCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellRight" bundle:nil] forCellReuseIdentifier:@"imageCellRight"];
    
    self.tableView.scrollEnabled=YES;
    
    NSLog(@" titleView height : %f", self.navigationItem.titleView.frame.size.height);
    NSLog(@" navbar height : %f", self.navigationController.navigationBar.frame.size.height);
    
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

- (void)sendButtonTapped{
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

- (void)setupSendButton{
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

-(void)setupMediaButton{
    self.mediaButton = [[UIButton alloc] init];
    [self.view addSubview:self.mediaButton];
    self.mediaButton.backgroundColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    [self.mediaButton setImage:[UIImage imageNamed:@"photo-abstract-7"] forState:UIControlStateNormal];
//    [self.mediaButton setAttributedTitle :[[NSAttributedString alloc] initWithString:@"M"
//                                                                          attributes:nil]
//                                 forState:UIControlStateNormal];
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
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/vid1.mp4"];
    
    BOOL success = [videoData writeToFile:tempPath atomically:NO];
    
    NSURL* pathURL = [[NSURL alloc] initFileURLWithPath:tempPath];
    
    MPMoviePlayerController* player = [[MPMoviePlayerController alloc]initWithContentURL:pathURL];
    
    player.shouldAutoplay = NO;
    
    return player;
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
 
    if (![self.messages count]==0) {
        NSMutableDictionary *message=self.messages[indexPath.row];
        if ([message objectForKey:@"message"]!=nil) {
            NSDictionary *message=self.messages[indexPath.row];
            NSString * yourText = message[@"message"]; // or however you are getting the text
            return 51 + [self heightForText:yourText];
        }else{
            return 180;
        }
    }
    return 0;
}

//from jan
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
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [textView sizeToFit];
    return textView.frame.size.height;
}

//from Jan
- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *content=self.messages[indexPath.row];
    
        
        if (content[@"video"])
        {
            MPMoviePlayerController* player = [self stringToVideo:content[@"video"]];
            
            self.playerController = player;
            
            UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            
            if ([content[@"user"] isEqualToString:self.user.name]) {
                KJDChatRoomImageCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellRight"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                rightCell.usernameLabel.attributedText=muAtrStr;
                rightCell.backgroundColor=[UIColor clearColor];
                [rightCell.mediaImageView setBackgroundColor:[UIColor clearColor]];
                
                NSLog(@"cell content view subviws BEFORE: %@", rightCell.contentView.subviews);
                [rightCell.mediaImageView removeFromSuperview];
                                NSLog(@"cell content view subviws AFTER: %@", rightCell.contentView.subviews);
                
                player.view .frame = CGRectMake(170, 30, 141, 142);
                if ([rightCell.contentView.subviews count] == 1)
                {
                    [rightCell.contentView addSubview:player.view];
                }
                
                player.scalingMode = MPMovieScalingModeAspectFit;
                [player setControlStyle:MPMovieControlStyleDefault];
                player.repeatMode = MPMovieRepeatModeNone;
                [player play];
                
                return rightCell;
            }
            else
            {
                KJDChatRoomImageCellLeft *leftCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellLeft"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];

                leftCell.usernameLabel.attributedText=muAtrStr;
                leftCell.backgroundColor=[UIColor clearColor];
                [leftCell.mediaImageView setBackgroundColor:[UIColor clearColor]];
                
                [leftCell.mediaImageView removeFromSuperview];
                
                player.view .frame = CGRectMake(8, 30, 141, 142);
                
                if ([leftCell.contentView.subviews count] == 1)
                {
                    [leftCell.contentView addSubview:player.view];
                }
                
                player.scalingMode = MPMovieScalingModeAspectFit;
                [player setControlStyle:MPMovieControlStyleDefault];
                player.repeatMode = MPMovieRepeatModeNone;
                [player play];
                
                return leftCell;
            }
        }
         if (content[@"map"])
        {
            NSString* imageInCode = content[@"map"];
            UIImage* imageToDisplay = [self stringToUIImage:imageInCode];
            
            if ([content[@"user"] isEqualToString:self.user.name])
            {
                KJDChatRoomImageCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellRight"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                rightCell.usernameLabel.attributedText=muAtrStr;
                rightCell.backgroundColor=[UIColor clearColor];
                rightCell.mediaImageView.image=imageToDisplay;
                
                return rightCell;
            }
            else
            {
                KJDChatRoomImageCellLeft *leftCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellLeft"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                leftCell.usernameLabel.attributedText=muAtrStr;
                leftCell.backgroundColor=[UIColor clearColor];
                leftCell.mediaImageView.image=imageToDisplay;
                
                return leftCell;
            }
        }
        else if (content[@"image"])
        {
            
            NSString* imageInCode = content[@"image"];
            UIImage* imageToDisplay = [self stringToUIImage:imageInCode];
            
            if ([content[@"user"] isEqualToString:self.user.name])
            {
                KJDChatRoomImageCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellRight"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                rightCell.usernameLabel.attributedText=muAtrStr;
                rightCell.backgroundColor=[UIColor clearColor];
                rightCell.mediaImageView.image=imageToDisplay;
                
                return rightCell;
            }
            else
            {
                KJDChatRoomImageCellRight *leftCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellLeft"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                leftCell.usernameLabel.attributedText=muAtrStr;
                leftCell.backgroundColor=[UIColor clearColor];
                leftCell.mediaImageView.image=imageToDisplay;
                
                return leftCell;
           }
        }
        else if (content[@"message"])
        {
            NSString *messageTyped=[NSString stringWithFormat:@"\n%@", content[@"message"]];
            if ([content[@"user"] isEqualToString:self.user.name])
            {
                KJDChatRoomTableViewCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"normalCellRight"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:self.user.name];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                
                rightCell.usernameLabel.attributedText = muAtrStr;
                rightCell.usernameLabel.textAlignment = NSTextAlignmentRight;
                rightCell.backgroundColor=[UIColor clearColor];
                rightCell.userMessageTextView.text=messageTyped;
                rightCell.userMessageTextView.textAlignment=NSTextAlignmentRight;
                rightCell.userMessageTextView.backgroundColor=[UIColor clearColor];
                [rightCell.userMessageTextView sizeToFit];
                [rightCell.userMessageTextView layoutIfNeeded];
                
                return rightCell;
            }
            else
            {
                KJDChatRoomTableViewCellLeft *leftCell=[tableView dequeueReusableCellWithIdentifier:@"normalCellLeft"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [muAtrStr length])];
                leftCell.backgroundColor=[UIColor clearColor];
                leftCell.usernameLabel.attributedText=muAtrStr;
                leftCell.userMessageTextView.text=messageTyped;
                leftCell.userMessageTextView.backgroundColor=[UIColor clearColor];
                [leftCell.userMessageTextView sizeToFit];
                [leftCell.userMessageTextView layoutIfNeeded];
                
                return leftCell;
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
        //fix this!!!!!!!
        UITableViewCell* mapCell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        KJDImageDisplayViewController* imageDisplayVC = [[KJDImageDisplayViewController alloc]init];
        
        imageDisplayVC.map = mapCell.contentView.subviews[0];
        
        [imageDisplayVC setModalPresentationStyle:UIModalPresentationFullScreen];
        
        [self presentViewController:imageDisplayVC animated:YES completion:^{
            
        }];
    }
}

@end
