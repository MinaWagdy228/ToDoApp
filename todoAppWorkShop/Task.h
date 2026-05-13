//
//  Task.h
//  todoAppWorkShop
//
//  Created by Mina_Wagdy on 27/04/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow = 0,
    TaskPriorityMedium,
    TaskPriorityHigh
};

typedef NS_ENUM(NSInteger, TaskState) {
    TaskStateToDo = 0,
    TaskStateInProgress,
    TaskStateDone
};

@interface Task : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, assign) TaskPriority priority;
@property (nonatomic, assign) TaskState state;
@property (nonatomic, strong) NSDate *creationDate;


@property (nonatomic, strong) NSDate *reminderDate;
@property (nonatomic, strong) NSString *attachedFilePath;

@end

NS_ASSUME_NONNULL_END
