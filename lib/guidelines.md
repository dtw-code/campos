CampusOS Frontend — Agent Guidelines
1. Project Overview
This is the Flutter frontend for the CampusOS hackathon project.
The application helps students discover campus events, view event details, manage personalized tasks, and interact with structured campus information produced by the backend.
The frontend currently runs on an Android emulator. The Node.js backend runs locally on the developer machine.
2. Tech Stack
Frontend
- Flutter
- Dart
- Provider — application/state management
- Material UI / Flutter widgets
Authentication
- Supabase Auth
- Supabase Flutter SDK
Backend
- Node.js
- Local REST API
- The Flutter app communicates with the Node.js backend through HTTP APIs.
Current Development Environment
- Flutter app → Android Emulator
- Node.js backend → Local machine
- For Android Emulator access to the host machine's localhost backend, use:
http://10.0.2.2:<PORT>
Do NOT use localhost or 127.0.0.1 from the Android emulator to reach the local Node.js server.
3. Core Architecture
Use this basic flow:
Flutter UI
    ↓
Provider / State
    ↓
Service Layer
    ↓
Node.js Backend
    ↓
Supabase / AI / Notion
Authentication is handled through Supabase Auth.
The Flutter frontend should NOT contain backend business logic, AI logic, Notion API logic, or database administration logic.
The frontend should communicate with the Node.js backend through the service layer.
4. Required Folder Structure
Keep the project structure simple and consistent.
lib/
│
├── main.dart
│
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── calendar_screen.dart
│   │   ├── tasks_screen.dart
│   │   ├── saved_events_screen.dart
│   │   └── event_details_screen.dart
│   │
│   └── components/
│       ├── event_card.dart
│       ├── task_card.dart
│       ├── app_bottom_nav.dart
│       └── ...
│
├── state/
│   ├── event_provider.dart
│   ├── task_provider.dart
│   ├── auth_provider.dart
│   └── ...
│
├── service/
│   ├── event_service.dart
│   ├── task_service.dart
│   ├── auth_service.dart
│   └── ...
│
└── models/
    ├── event.dart
    ├── task.dart
    └── ...
Folder responsibilities
/ui/screens
Contains the main screen-level widgets.
Examples:
- home_screen.dart
- calendar_screen.dart
- tasks_screen.dart
- event_details_screen.dart
A screen should primarily compose UI and consume state from Providers.
Do not put API calls directly inside screens.
/ui/components
Contains reusable UI widgets.
Examples:
- event_card.dart
- task_card.dart
- event_chip.dart
- app_bottom_nav.dart
- loading_indicator.dart
If a UI component is reused by multiple screens, move it here.
Avoid duplicating the same widget implementation across screens.
/state
Contains Provider classes and application state.
Examples:
event_provider.dart
task_provider.dart
auth_provider.dart
Providers are responsible for:
- Holding UI/application state
- Calling appropriate services
- Updating state
- Notifying listeners
- Handling loading/error/success states
Providers should NOT directly contain raw HTTP implementation.
Example:
EventScreen
    ↓
EventProvider
    ↓
EventService
    ↓
Node API
/service
Contains communication with external/backend services.
Examples:
event_service.dart
task_service.dart
auth_service.dart
Services are responsible for:
- HTTP requests
- API endpoints
- Request/response handling
- Authentication-related service calls when appropriate
Do not put UI code in services.
Do not call services directly from UI components when the operation belongs to application state. Prefer:
UI → Provider → Service
/models
Contains Dart data models representing application data.
Examples:
event.dart
task.dart
Models should contain structured data and serialization/deserialization logic where appropriate.
5. Naming Conventions
Use snake_case for Dart filenames.
Correct:
home_screen.dart
event_card.dart
event_provider.dart
event_service.dart
event_details_screen.dart
Incorrect:
HomeScreen.dart
EventCard.dart
eventProvider.dart
event-service.dart
Classes
Use PascalCase.
class HomeScreen extends StatelessWidget {}

class EventCard extends StatelessWidget {}

class EventProvider extends ChangeNotifier {}

class EventService {}
Variables and methods
Use camelCase.
final eventName = 'HackFest';

Future<void> fetchEvents() async {}
Constants
Use lowerCamelCase for Dart constants unless a project-wide convention requires otherwise.
const apiTimeout = Duration(seconds: 30);
6. Screen Naming
Every main screen should follow:
<name>_screen.dart
Examples:
home_screen.dart
calendar_screen.dart
tasks_screen.dart
saved_events_screen.dart
event_details_screen.dart
Corresponding class:
class HomeScreen extends StatelessWidget {}
class CalendarScreen extends StatelessWidget {}
class TasksScreen extends StatelessWidget {}
7. Provider Naming
Every Provider should follow:
<feature>_provider.dart
Examples:
event_provider.dart
task_provider.dart
auth_provider.dart
Corresponding class:
class EventProvider extends ChangeNotifier {}
class TaskProvider extends ChangeNotifier {}
class AuthProvider extends ChangeNotifier {}
8. Service Naming
Every service should follow:
<feature>_service.dart
Examples:
event_service.dart
task_service.dart
auth_service.dart
Corresponding class:
class EventService {}
class TaskService {}
class AuthService {}
9. Component Naming
Reusable widgets should follow:
<feature>_<type>.dart
Examples:
event_card.dart
task_card.dart
event_filter.dart
app_bottom_nav.dart
search_bar.dart
Corresponding classes use PascalCase:
class EventCard extends StatelessWidget {}
class TaskCard extends StatelessWidget {}
10. State Management Rules
Use Provider for application state.
Do not introduce another state-management package unless explicitly requested.
Typical pattern:
Screen
  ↓
context.watch<EventProvider>()
  ↓
Provider
  ↓
EventService
  ↓
Backend API
Use context.watch<T>() when the UI needs to rebuild when state changes.
Use context.read<T>() when calling an action without needing to rebuild.
Keep Provider state focused on its feature.
For example:
EventProvider
→ events
→ loading state
→ error state
→ fetchEvents()
→ saveEvent()
Do not create one giant AppProvider containing every piece of application state.
11. API Communication Rules
Flutter must communicate with the Node.js backend through service classes.
Example:
event_screen.dart
        ↓
event_provider.dart
        ↓
event_service.dart
        ↓
Node.js API
Do NOT do this:
// Inside a widget
http.get(...)
Keep HTTP implementation inside /service.
The base API URL should be centralized rather than repeated throughout the project.
For the Android emulator, the local Node server should normally be accessed through:
http://10.0.2.2:<PORT>
Do not hardcode API URLs in multiple files.
12. Authentication
Supabase Auth is used for authentication.
Authentication-related UI/state should be separated from event/task logic.
Recommended flow:
Login / Signup
      ↓
Supabase Auth
      ↓
AuthProvider
      ↓
Application
The frontend should never contain Supabase service-role keys or other secret credentials.
Only public/client-safe Supabase configuration belongs in the Flutter application.
13. Backend Responsibility
The Node.js backend is responsible for backend operations such as:
- Event APIs
- Task APIs
- AI extraction
- Notion integration
- Business logic
- Data validation
- Backend-side Supabase operations where required
Do not move these responsibilities into Flutter just to make implementation faster.
The Flutter application should consume clean API responses.
14. UI Rules
Keep screens modular.
A screen should generally:
1. Read state from Provider
2. Display loading/error/data states
3. Compose reusable components
4. Trigger Provider actions
Avoid putting large amounts of business logic inside build().
Avoid extremely large screen files.
If a UI section becomes reusable or complex, extract it into /ui/components.
15. Loading and Error States
Every backend-dependent screen should account for:
Loading
Success
Empty
Error
Example:
Loading → CircularProgressIndicator

Success → Display events

Empty → "No upcoming events"

Error → Error message + Retry
Do not leave screens blank when an API request fails.
16. API Models
When receiving JSON from the backend:
JSON
 ↓
Model
 ↓
Provider
 ↓
UI
Do not pass raw JSON maps throughout the UI.
For example:
final Event event = Event.fromJson(json);
Then the UI works with:
event.eventName
event.date
event.registrationDeadline
instead of:
json['event_name']
json['date']
17. Avoid Unnecessary Complexity
This is a hackathon prototype.
Do NOT introduce unnecessary architecture, packages, abstractions, or folders.
Do not add:
- BLoC
- Riverpod
- GetX
- Redux
- Clean Architecture layers
- Repository layers
- Dependency injection frameworks
unless explicitly requested.
The current architecture is intentionally:
UI → Provider → Service → Backend
Keep it simple.
18. Existing Code Rule
Before creating a new file or changing an existing feature:
1. Inspect the existing project structure.
2. Reuse existing components/providers/services where possible.
3. Do not duplicate functionality.
4. Do not rename existing files without a clear reason.
5. Do not break existing authentication or navigation.
6. Do not create new top-level directories without explicit approval.
Preserve working functionality while implementing new features.
19. Feature Implementation Pattern
For a new feature, follow this order:
1. Model
      ↓
2. Service/API
      ↓
3. Provider
      ↓
4. Reusable Components
      ↓
5. Screen
      ↓
6. Navigation integration
For example, adding Events:
models/event.dart
        ↓
service/event_service.dart
        ↓
state/event_provider.dart
        ↓
ui/components/event_card.dart
        ↓
ui/screens/home_screen.dart
20. Agent Behavior
When implementing a task:
- Read the existing code before making changes.
- Follow this guidelines.md strictly.
- Prefer modifying existing files over creating duplicates.
- Keep the architecture consistent.
- Do not introduce a new package unless necessary.
- Do not change the backend architecture from Flutter.
- Do not expose secrets in Flutter.
- Keep API communication inside /service.
- Keep state inside /state.
- Keep reusable widgets inside /ui/components.
- Keep main screens inside /ui/screens.
- Use Provider for shared application state.
- Test the affected flow after implementation.
- If an architectural change is genuinely required, explain it before making it.
21. Current Target Architecture
                    ┌──────────────────┐
                    │   Flutter App    │
                    │  Android Emulator│
                    └────────┬─────────┘
                             │
                         UI Screens
                             │
                         Components
                             │
                         Providers
                             │
                          Services
                             │
                             │ HTTP
                             ▼
                    ┌──────────────────┐
                    │   Node.js API    │
                    │  Local Machine   │
                    └────────┬─────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
                Supabase             Notion
                 / AI
This architecture should remain the default unless the project requirements explicitly require a change.