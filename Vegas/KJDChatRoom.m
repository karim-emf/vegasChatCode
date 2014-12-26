//
//  KJDChatRoom.m
//  Vegas

#import "KJDChatRoom.h"
#import <Firebase/Firebase.h>
#import "KJDChatRoomViewController.h"


@implementation KJDChatRoom

-(instancetype)initWithUser:(KJDUser *)user{
    self=[super init];
    if (self) {
        _user=user;
        _messages=[[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)init{
    return [self initWithUser:self.user];
}

-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock{
   

    NSMutableArray *messagesArray=[[NSMutableArray alloc]init];
   if ([snapshot.value isKindOfClass:[NSArray class]])
   {
      [messagesArray addObjectsFromArray:snapshot.value];

   }
   else if ([snapshot.value isKindOfClass:[NSDictionary class]])
   {
      [messagesArray addObject:snapshot.value];
      NSLog(@"ocurrio");

   }
   else if ([snapshot.value isKindOfClass:[NSString class]])
   {
      [messagesArray addObject:snapshot.value];
   }
    completionBlock(messagesArray);
}

-(void)fetchUserCountFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSNumber *count))completionBlock
{
   if (self.firstTimeInRoom)
   {
      if (snapshot.value == [NSNull null])
      {
         self.userCount = @1;
      }
      else
      {
         NSNumber* previousCount = snapshot.value[@"userCount"];
         self.userCount = [NSNumber numberWithInteger:([previousCount integerValue] +1)];
      }
      [self.userCountFireBase setValue:@{@"userCount":self.userCount}];
      self.firstTimeInRoom = false;
   }
   else
   {
      if (snapshot.value != [NSNull null])
      {
         self.userCount = snapshot.value[@"userCount"];
         
      }
   }
   completionBlock(self.userCount);
}

-(void)setUpUserCountFireBaseWithCompletionBlock:(void (^)(BOOL completedCount))completionBlock
{
   self.userCountFireBase= [self.firebase childByAppendingPath:@"userCount"];
   
   [self.userCountFireBase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
    {
       //did not get called!
       
       [self fetchUserCountFromCloud:snapshot withBlock:^(NSNumber *count)
       {
          self.userCount = count;
          completionBlock(YES);
       }];
    }];
}

- (void)setupFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock
{
   self.firebaseURL = [NSString stringWithFormat:@"https://vivid-inferno-6756.firebaseio.com/%@", self.firebaseRoomURL];
   
   self.firebase = [[Firebase alloc] initWithUrl:self.firebaseURL];
   
   completionBlock(YES);
}

- (void)setUpContentFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock
{
   
   self.contentFireBase = [self.firebase childByAppendingPath:@"content"];
   
   [self.contentFireBase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
         [self fetchMessagesFromCloud:snapshot withBlock:^(NSMutableArray *messages)
          {
             [self.messages addObjectsFromArray:messages];
             
             completionBlock(YES);
          }];
      }];
}


@end
