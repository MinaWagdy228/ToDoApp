TODO List App

A native iOS Todo List application built using UIKit + Storyboard following the MVC architectural pattern.
The app helps users organize, prioritize, and track tasks with support for task states, filtering, searching, and local persistence.

Based on the provided project specifications.

Features
Task Management
Add new tasks
Edit existing tasks
Delete tasks
View task details
Mark tasks as:
To-Do
In Progress
Done
Priority System

Each task supports:

High Priority
Medium Priority
Low Priority

Each priority level has its own dedicated visual indicator/icon.

Search
Search tasks by name
Empty-state UI when no results are found
Filtering

Tasks can be filtered using segmented controls:

All Tasks
To-Do
In Progress
Done
Priority-based grouping
Local Persistence
Tasks are stored locally
Data persists between app launches
Tech Stack
Language: Swift
UI Framework: UIKit
Interface Builder: Storyboard
Architecture: MVC (Model-View-Controller)
Persistence: UserDefaults / Local Storage
Design Pattern: Delegation & MVC communication
Architecture

The project follows the traditional MVC Architecture:

Model

Responsible for:

Task data structure
Persistence logic
Business rules
View

Responsible for:

Storyboards
XIBs / Custom Cells
UI rendering
Controller

Responsible for:

Handling user interactions
Updating views
Managing application flow
Screens
Task List Screen
Displays all tasks
Supports filtering and searching
Segmented control navigation
Add/Edit Task Screen
Create new tasks
Edit existing tasks
Confirmation before saving edits
Task Details Screen
Shows full task information
Displays attached reminder/file if available
Task States Rules

The app enforces state transition rules:

Current State	Allowed Transition
To-Do	In Progress
In Progress	Done
Done	Final State

Invalid reverse transitions are prevented.

Local Storage

All tasks are saved locally to ensure:

Offline access
Persistence after app restart
Fast retrieval
Future Improvements

Possible enhancements:

Notification reminders
File attachments
CoreData persistence
Dark mode support
Drag & drop task sorting
Cloud synchronization
MVVM or Clean Architecture refactor
Project Structure
TODOListApp
│
├── Models
├── Views
├── Controllers
├── Resources
├── Helpers
├── Extensions
└── Assets
Installation
Clone the repository
git clone <repo-url>
Open the project
open TODOListApp.xcodeproj
Run the app using Xcode
Requirements
Xcode 15+
iOS 16+
Swift 5+
Author

Developed as an individual iOS project using UIKit and MVC architecture.
