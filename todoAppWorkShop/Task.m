//
//  Task.m
//  todoAppWorkShop
//
//  Created by Mina_Wagdy on 27/04/2026.
// new comment for testing purposes
// pull request
//

#import "Task.h"

@implementation Task

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskId forKey:@"taskId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.taskDescription forKey:@"taskDescription"];
    [coder encodeInteger:self.priority forKey:@"priority"];
    [coder encodeInteger:self.state forKey:@"state"];
    [coder encodeObject:self.creationDate forKey:@"creationDate"];
    [coder encodeObject:self.reminderDate forKey:@"reminderDate"];
    [coder encodeObject:self.attachedFilePath forKey:@"attachedFilePath"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _taskId = [coder decodeObjectOfClass:[NSString class] forKey:@"taskId"];
        _name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _taskDescription = [coder decodeObjectOfClass:[NSString class] forKey:@"taskDescription"];
        _priority = [coder decodeIntegerForKey:@"priority"];
        _state = [coder decodeIntegerForKey:@"state"];
        _creationDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"creationDate"];
        _reminderDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"reminderDate"];
        _attachedFilePath = [coder decodeObjectOfClass:[NSString class] forKey:@"attachedFilePath"];
    }
    return self;
}

@end
