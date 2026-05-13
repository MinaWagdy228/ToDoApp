//
//  ViewController.m
//  todoAppWorkShop
//
//  Created by Mina_Wagdy on 27/04/2026.
//

#import "ViewController.h"
#import "Task.h"
#import "TaskDetailViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource,
                              UISearchResultsUpdating>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray<Task *> *tasksList;
@property(weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;

@property(nonatomic, strong) NSMutableArray<Task *> *allTasks;

@property(nonatomic, strong) NSMutableArray<Task *> *displayedTasks;
@property(nonatomic, strong)
    NSMutableArray<NSMutableArray<Task *> *> *priorityTasks;
@property(nonatomic, strong)
    NSMutableArray<NSMutableArray<Task *> *> *stateTasks;
@property(nonatomic, strong) UISearchController *searchController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchController =
        [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search tasks by name...";

    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;

    NSDictionary *fontAttributes = @{
        NSFontAttributeName : [UIFont systemFontOfSize:10.0
                                                weight:UIFontWeightRegular]
    };
    [self.filterSegmentedControl setTitleTextAttributes:fontAttributes
                                               forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTasks];
    [self.tableView reloadData];
}
- (void)updateSearchResultsForSearchController:
    (UISearchController *)searchController {
    [self applyCurrentFilter];
}
- (void)loadTasks {
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
        self.allTasks = [NSMutableArray arrayWithArray:savedTasks];
    } else {
        self.allTasks = [NSMutableArray array];
    }

    [self applyCurrentFilter];
}

- (IBAction)filterChanged:(id)sender {
    [self applyCurrentFilter];
}
- (void)applyCurrentFilter {
    NSInteger selectedIndex = self.filterSegmentedControl.selectedSegmentIndex;

    self.displayedTasks = [NSMutableArray array];
    self.stateTasks = nil;
    self.priorityTasks = nil;

    NSString *searchText =
    [self.searchController.searchBar.text
     stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isSearching = self.searchController.isActive && searchText.length > 0;

    if (selectedIndex == 0) {
        self.stateTasks = [NSMutableArray arrayWithObjects:
                           [NSMutableArray array],
                           [NSMutableArray array],
                           [NSMutableArray array], nil];
    } else if (selectedIndex == 4) {
        self.priorityTasks = [NSMutableArray arrayWithObjects:
                              [NSMutableArray array],
                              [NSMutableArray array],
                              [NSMutableArray array], nil];
    }

    for (Task *task in self.allTasks) {

        if (isSearching &&
            ![task.name localizedCaseInsensitiveContainsString:searchText]) {
            continue;
        }

        switch (selectedIndex) {

            case 0:
                [self.stateTasks[task.state] addObject:task];
                break;

            case 1:
                if (task.state == TaskStateToDo) {
                    [self.displayedTasks addObject:task];
                }
                break;

            case 2:
                if (task.state == TaskStateInProgress) {
                    [self.displayedTasks addObject:task];
                }
                break;

            case 3:
                if (task.state == TaskStateDone) {
                    [self.displayedTasks addObject:task];
                }
                break;

            case 4:
                [self.priorityTasks[task.priority] addObject:task];
                break;

            default:
                break;
        }
    }

    [self updateEmptyStateUI];
    [self.tableView reloadData];
    
}

- (void)updateEmptyStateUI {
    BOOL hasResults = NO;
    NSInteger selectedIndex = self.filterSegmentedControl.selectedSegmentIndex;

    switch (selectedIndex) {

        case 0: {
            for (NSArray *section in self.stateTasks) {
                if (section.count > 0) {
                    hasResults = YES;
                    break;
                }
            }
            break;
        }

        case 4: {
            for (NSArray *section in self.priorityTasks) {
                if (section.count > 0) {
                    hasResults = YES;
                    break;
                }
            }
            break;
        }

        default:
            hasResults = self.displayedTasks.count > 0;
            break;
    }

    if (hasResults) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return;
    }

    UILabel *emptyLabel = (UILabel *)self.tableView.backgroundView;

    if (![emptyLabel isKindOfClass:[UILabel class]]) {
        emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.textColor = [UIColor secondaryLabelColor];
        emptyLabel.font =
            [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    }

    emptyLabel.text = @"No tasks found 🕵️‍♂️";

    self.tableView.backgroundView = emptyLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)saveCurrentTasksToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *filePath =
        [documentsDirectory stringByAppendingPathComponent:@"tasks.plist"];

    NSError *saveError;
    NSData *dataToSave =
        [NSKeyedArchiver archivedDataWithRootObject:self.allTasks
                              requiringSecureCoding:YES
                                              error:&saveError];
    [dataToSave writeToFile:filePath atomically:YES];
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath {
    Task *taskToDelete;

    if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
        taskToDelete = self.stateTasks[indexPath.section][indexPath.row];
    } else if (self.filterSegmentedControl.selectedSegmentIndex == 4) {
        taskToDelete = self.priorityTasks[indexPath.section][indexPath.row];
    } else {
        taskToDelete = self.displayedTasks[indexPath.row];
    }

    [self.allTasks removeObject:taskToDelete];
    [self saveCurrentTasksToDisk];
    [self applyCurrentFilter];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.filterSegmentedControl.selectedSegmentIndex == 0 ||
        self.filterSegmentedControl.selectedSegmentIndex == 4) {
        return 3;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
        if (self.stateTasks[section].count == 0) {
            return nil;
        }
        
        if (section == 0) return @"To-Do";
        if (section == 1) return @"In Progress";
        if (section == 2) return @"Done";
        
    } else if (self.filterSegmentedControl.selectedSegmentIndex == 4) {
        if (self.priorityTasks[section].count == 0) {
            return nil;
        }
        
        if (section == 0) return @"Low Priority";
        if (section == 1) return @"Medium Priority";
        if (section == 2) return @"High Priority";
    }
    
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
        return self.stateTasks[section].count;
    } else if (self.filterSegmentedControl.selectedSegmentIndex == 4) {
        return self.priorityTasks[section].count;
    }
    return self.displayedTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"TaskCell"
                                        forIndexPath:indexPath];

    Task *currentTask;
    if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
        currentTask = self.stateTasks[indexPath.section][indexPath.row];
    } else if (self.filterSegmentedControl.selectedSegmentIndex == 4) {
        currentTask = self.priorityTasks[indexPath.section][indexPath.row];
    } else {
        currentTask = self.displayedTasks[indexPath.row];
    }

    cell.textLabel.text = currentTask.name;
    cell.detailTextLabel.text = currentTask.taskDescription;

    if (currentTask.priority == TaskPriorityHigh) {
        cell.imageView.image = [UIImage imageNamed:@"high"];
    } else if (currentTask.priority == TaskPriorityMedium) {
        cell.imageView.image = [UIImage imageNamed:@"medium"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"low"];
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Delete Task"
                             message:@"Are you sure you want to permanently "
                                     @"delete this task?"
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction
            actionWithTitle:@"Cancel"
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *_Nonnull action) {
                      [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                                       withRowAnimation:
                                           UITableViewRowAnimationAutomatic];
                    }];

        __weak typeof(self) weakSelf = self;
        UIAlertAction *deleteAction =
            [UIAlertAction actionWithTitle:@"Delete"
                                     style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *_Nonnull action) {

                                     [weakSelf deleteTaskAtIndexPath:indexPath];
                                   }];

        [alert addAction:cancelAction];
        [alert addAction:deleteAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTaskDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Task *selectedTask;

        if (self.filterSegmentedControl.selectedSegmentIndex == 0) {
            selectedTask = self.stateTasks[indexPath.section][indexPath.row];
        } else if (self.filterSegmentedControl.selectedSegmentIndex == 4) {
            selectedTask = self.priorityTasks[indexPath.section][indexPath.row];
        } else {
            selectedTask = self.displayedTasks[indexPath.row];
        }

        TaskDetailViewController *detailVC = segue.destinationViewController;
        detailVC.task = selectedTask;
    }
}
@end
