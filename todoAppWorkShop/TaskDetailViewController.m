//
//  TaskDetailViewController.m
//  todoAppWorkShop
//
//  Created by Mina_Wagdy on 27/04/2026.
//

#import "TaskDetailViewController.h"
#import "Task.h"
#import <UserNotifications/UserNotifications.h>
@interface TaskDetailViewController () <UIDocumentInteractionControllerDelegate,
                                        UIDocumentPickerDelegate>
@property(weak, nonatomic) IBOutlet UITextField *nameTextField;
@property(weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property(weak, nonatomic)
    IBOutlet UISegmentedControl *prioritySegmentedControl;
@property(weak, nonatomic) IBOutlet UISegmentedControl *stateSegmentedControl;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property(nonatomic, assign) BOOL isEditingMode;

@property(weak, nonatomic) IBOutlet UIButton *viewFileButton;
@property(nonatomic, strong) UIDocumentInteractionController *docController;
@property(weak, nonatomic) IBOutlet UIDatePicker *reminderDatePicker;
@property(weak, nonatomic) IBOutlet UIButton *setNewFileButton;
@property(nonatomic, strong) NSString *updatedFileName;
@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateUIWithTaskData];
    [self lockUI];

    if (self.task.attachedFilePath.length == 0 ||
        self.task.attachedFilePath == nil) {
        self.viewFileButton.hidden = YES;
    }

    if (self.task.state == TaskStateDone) {
        self.editBarButtonItem.enabled = NO;
        self.editBarButtonItem.title = @"";
    }
}
- (void)populateUIWithTaskData {
    self.nameTextField.text = self.task.name;
    self.descriptionTextField.text = self.task.taskDescription;
    self.prioritySegmentedControl.selectedSegmentIndex = self.task.priority;
    self.stateSegmentedControl.selectedSegmentIndex = self.task.state;
    if (self.task.reminderDate) {
        self.reminderDatePicker.date = self.task.reminderDate;
    }
}

- (void)lockUI {
    self.isEditingMode = NO;
    self.nameTextField.enabled = NO;
    self.descriptionTextField.editable = NO;
    self.prioritySegmentedControl.enabled = NO;
    self.stateSegmentedControl.enabled = NO;
    self.reminderDatePicker.enabled = NO;
    self.setNewFileButton.hidden = YES;
    self.viewFileButton.hidden = NO;
    self.editBarButtonItem.title = @"Edit";
}

- (void)unlockUI {
    self.isEditingMode = YES;
    self.nameTextField.enabled = YES;
    self.descriptionTextField.editable = YES;
    self.prioritySegmentedControl.enabled = YES;
    self.stateSegmentedControl.enabled = YES;
    self.reminderDatePicker.enabled = YES;
    self.setNewFileButton.hidden = NO;
    self.viewFileButton.hidden = YES;
    self.editBarButtonItem.title = @"Done";

    if (self.task.state == TaskStateInProgress) {
        [self.stateSegmentedControl setEnabled:NO forSegmentAtIndex:0];
    }
}

- (IBAction)editButtonTapped:(id)sender {
    if (!self.isEditingMode) {
        [self unlockUI];
    } else {
        NSString *trimmedName = [self.nameTextField.text
            stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (trimmedName.length == 0) {
            UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"Invalid Name"
                                 message:@"The task name cannot be empty."
                          preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction =
                [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:nil];
            [alert addAction:okAction];

            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Confirm Edits"
                             message:
                                 @"Are you sure you want to save these changes?"
                      preferredStyle:UIAlertControllerStyleAlert];

        __weak typeof(self) weakSelf = self;

        UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *_Nonnull action) {
                                     [weakSelf populateUIWithTaskData];
                                     [weakSelf lockUI];
                                   }];

        UIAlertAction *confirmAction = [UIAlertAction
            actionWithTitle:@"Confirm"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *_Nonnull action) {
                      [weakSelf applyEditsAndSave];
                      [weakSelf lockUI];
                      if (weakSelf.task.state == TaskStateDone) {
                          weakSelf.editBarButtonItem.enabled = NO;
                          weakSelf.editBarButtonItem.title = @"";
                      }
                    }];

        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)applyEditsAndSave {
    self.task.name = [self.nameTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet
                                            whitespaceAndNewlineCharacterSet]];

    self.task.taskDescription = self.descriptionTextField.text;
    self.task.name = self.nameTextField.text;
    self.task.taskDescription = self.descriptionTextField.text;
    self.task.priority = self.prioritySegmentedControl.selectedSegmentIndex;
    self.task.state = self.stateSegmentedControl.selectedSegmentIndex;

    if (![self.task.reminderDate isEqualToDate:self.reminderDatePicker.date]) {
        self.task.reminderDate = self.reminderDatePicker.date;
        [self rescheduleNotification];
    }
    if (self.updatedFileName != nil) {
        self.task.attachedFilePath = self.updatedFileName;
        self.viewFileButton.hidden = NO;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *filePath =
        [documentsDirectory stringByAppendingPathComponent:@"tasks.plist"];

    NSData *existingData = [NSData dataWithContentsOfFile:filePath];
    if (existingData) {
        NSError *error;
        NSSet *classes =
            [NSSet setWithObjects:[NSArray class], [Task class], nil];
        NSArray *savedTasks =
            [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                                fromData:existingData
                                                   error:&error];

        NSMutableArray *mutableTasks =
            [NSMutableArray arrayWithArray:savedTasks];

        NSUInteger indexToReplace = [mutableTasks
            indexOfObjectPassingTest:^BOOL(Task *obj, NSUInteger idx,
                                           BOOL *stop) {
              return [obj.taskId isEqualToString:self.task.taskId];
            }];

        if (indexToReplace != NSNotFound) {
            [mutableTasks replaceObjectAtIndex:indexToReplace
                                    withObject:self.task];

            NSError *saveError;
            NSData *dataToSave =
                [NSKeyedArchiver archivedDataWithRootObject:mutableTasks
                                      requiringSecureCoding:YES
                                                      error:&saveError];
            [dataToSave writeToFile:filePath atomically:YES];
        }
    }
}

- (IBAction)viewFileTapped:(id)sender {
    if (self.task.attachedFilePath.length == 0)
        return;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *fullPath = [documentsDirectory
        stringByAppendingPathComponent:self.task.attachedFilePath];
    NSURL *fileURL = [NSURL fileURLWithPath:fullPath];

    self.docController =
        [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.docController.delegate = self;
    [self.docController presentPreviewAnimated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:
    (UIDocumentInteractionController *)controller {
    return self;
}
- (IBAction)setNewFileTapped:(id)sender {
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

    if (!error) {
        self.updatedFileName = uniqueName;
        NSLog(@"New file selected and staged for save: %@", uniqueName);
    }
}
- (void)rescheduleNotification {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];

    [center
        removePendingNotificationRequestsWithIdentifiers:@[ self.task.taskId ]];

    UNMutableNotificationContent *content =
        [[UNMutableNotificationContent alloc] init];
    content.title = @"Task Reminder (Updated)";
    content.body = [NSString
        stringWithFormat:@"It is time to work on: %@", self.task.name];
    content.sound = [UNNotificationSound defaultSound];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                              NSCalendarUnitDay | NSCalendarUnitHour |
                              NSCalendarUnitMinute)
                    fromDate:self.task.reminderDate];

    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
        triggerWithDateMatchingComponents:components
                                  repeats:NO];
    UNNotificationRequest *request =
        [UNNotificationRequest requestWithIdentifier:self.task.taskId
                                             content:content
                                             trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];
}
@end
