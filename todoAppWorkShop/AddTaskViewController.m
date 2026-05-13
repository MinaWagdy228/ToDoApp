//
//  AddTaskViewController.m
//  todoAppWorkShop
//
//  Created by Mina_Wagdy on 27/04/2026.
//

#import "AddTaskViewController.h"
#import "Task.h"
#import <UserNotifications/UserNotifications.h>

@interface AddTaskViewController () <UIDocumentPickerDelegate>
@property(weak, nonatomic) IBOutlet UITextField *nameTextField;
@property(weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property(weak, nonatomic)
    IBOutlet UISegmentedControl *prioritySegmentedControl;
@property(weak, nonatomic) IBOutlet UIDatePicker *reminderDatePicker;
@property(nonatomic, strong) NSString *savedFileName;
@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)saveButtonTapped:(id)sender {
    NSString *trimmedName = [self.nameTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet
                                            whitespaceAndNewlineCharacterSet]];

    if (trimmedName.length == 0) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Invalid Name"
                             message:@"A task must have a name."
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:nil];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    Task *newTask = [[Task alloc] init];
    newTask.taskId = [[NSUUID UUID] UUIDString];
    newTask.name = self.nameTextField.text;
    newTask.taskDescription = self.descriptionTextField.text;
    newTask.priority = self.prioritySegmentedControl.selectedSegmentIndex;
    newTask.state = TaskStateToDo;
    newTask.creationDate = [NSDate date];

    newTask.reminderDate = self.reminderDatePicker.date;
    newTask.attachedFilePath = self.savedFileName;
    [self scheduleNotificationForTask:newTask];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *filePath =
        [documentsDirectory stringByAppendingPathComponent:@"tasks.plist"];

    NSMutableArray *tasksArray = [NSMutableArray array];
    NSData *existingData = [NSData dataWithContentsOfFile:filePath];
    if (existingData) {
        NSError *error;
        NSSet *classes =
            [NSSet setWithObjects:[NSArray class], [Task class], nil];
        NSArray *savedTasks =
            [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                                fromData:existingData
                                                   error:&error];
        if (savedTasks) {
            [tasksArray addObjectsFromArray:savedTasks];
        }
    }

    [tasksArray addObject:newTask];

    NSError *saveError;
    NSData *dataToSave =
        [NSKeyedArchiver archivedDataWithRootObject:tasksArray
                              requiringSecureCoding:YES
                                              error:&saveError];
    [dataToSave writeToFile:filePath atomically:YES];

    NSLog(@"Saved a task! Total tasks in array before saving to disk: %lu",
          (unsigned long)tasksArray.count);
    if (saveError) {
        NSLog(@"Error saving to disk: %@", saveError.localizedDescription);
    } else {
        NSLog(@"Successfully wrote to disk at path: %@", filePath);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scheduleNotificationForTask:(Task *)task {
    UNMutableNotificationContent *content =
        [[UNMutableNotificationContent alloc] init];
    content.title = @"Task Reminder";
    content.body =
        [NSString stringWithFormat:@"It is time to work on: %@", task.name];
    content.sound = [UNNotificationSound defaultSound];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                              NSCalendarUnitDay | NSCalendarUnitHour |
                              NSCalendarUnitMinute)
                    fromDate:task.reminderDate];

    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
        triggerWithDateMatchingComponents:components
                                  repeats:NO];

    UNNotificationRequest *request =
        [UNNotificationRequest requestWithIdentifier:task.taskId
                                             content:content
                                             trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request
         withCompletionHandler:^(NSError *_Nullable error) {
           if (error) {
               NSLog(@"Error scheduling notification: %@",
                     error.localizedDescription);
           } else {
               NSLog(@"Notification successfully scheduled for %@",
                     task.reminderDate);
           }
         }];
}

- (IBAction)attachFileTapped:(id)sender {
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc]
            initWithDocumentTypes:@[ @"public.data" ]
                           inMode:UIDocumentPickerModeImport];
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *sourceURL = urls.firstObject;
    if (!sourceURL)
        return;

    BOOL secured = [sourceURL startAccessingSecurityScopedResource];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];

    NSString *uniqueName =
        [NSString stringWithFormat:@"%@_%@", [[NSUUID UUID] UUIDString],
                                   sourceURL.lastPathComponent];
    NSString *destinationPath =
        [documentsDirectory stringByAppendingPathComponent:uniqueName];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];

    NSError *error;
    [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:&error];

    if (secured) {
        [sourceURL stopAccessingSecurityScopedResource];
    }

    if (error) {
        NSLog(@"Error saving file: %@", error.localizedDescription);
    } else {
        NSLog(@"Successfully saved file: %@", uniqueName);
        self.savedFileName = uniqueName;
    }
}
@end
