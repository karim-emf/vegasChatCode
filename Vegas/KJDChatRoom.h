//
//  KJDChatRoom.h
//  Vegas


#import <Foundation/Foundation.h>
#import "KJDUser.h"
#import <Firebase/Firebase.h>
#import <QuickLook/QuickLook.h>

@interface KJDChatRoom : NSObject

@property(strong,nonatomic)KJDUser *user;
@property(strong,nonatomic)NSMutableArray *messages;
@property(strong,nonatomic)NSString *firebaseRoomName;
@property(strong,nonatomic)NSString *firebaseURL;
@property(strong,nonatomic)Firebase *firebase;

@property(strong,nonatomic)Firebase *userCountFireBase;
@property(strong,nonatomic)Firebase *contentFireBase;
@property(strong,nonatomic)Firebase *nameSwitchFireBase;
@property(strong,nonatomic)NSNumber* userCount;
@property(nonatomic) BOOL firstTimeInRoom;
@property(nonatomic, strong) UILocalNotification* chatNotification;
 
-(instancetype)initWithUser:(KJDUser *)user;
-(instancetype)init;

-(void)setupFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock;
-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock;
-(void)setUpUserCountFireBaseWithCompletionBlock:(void (^)(BOOL completedCount))completionBlock;
- (void)setUpContentFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock;

-(void)fetchNameSwitchFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSDictionary* nameChange))isCompleted;
-(void)setUpNameSwitchFireBaseWithCompletionBlock:(void (^)(NSDictionary* nameChange))completionBlock;

@end
