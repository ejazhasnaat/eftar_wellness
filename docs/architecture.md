# EFTAR Wellness Project – Reference Architecture & Guidelines

## 1. Project Structure

We follow a **feature-first Clean Architecture** with separation of concerns.  
Everything lives inside `lib/features/<feature_name>` unless it’s **app-wide** (in `lib/app` or `lib/core`).

```
lib/
├── app/                      # Global app-level code
│   ├── app.dart              # App entry with providers & router
│   ├── router_provider.dart  # Centralized GoRouter config
│   └── theme/                # Shared theming
│       ├── app_theme.dart
│       ├── brand.dart
│       └── theme_controller.dart
│
├── core/                     # Core shared services
│   ├── db/                   # Drift DB + DAOs
│   ├── utils/                # Reusable helpers (reset_utils, etc.)
│   └── constants/            # Flags, keys, constants
│
├── features/                 # Each feature isolated
│   ├── auth/                 # Authentication
│   │   ├── application/      # Controllers (state mgmt, Riverpod Notifiers)
│   │   ├── domain/           # Pure business rules (entities, repos abstract)
│   │   ├── infrastructure/   # Repo implementations (prefs, db, network)
│   │   └── presentation/     # UI (screens, widgets)
│   │
│   ├── home/                 # Home dashboard
│   │   ├── application/
│   │   ├── data/             # Local/mock repos
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai_assistant/         # AI chat
│   │   ├── application/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   ├── settings/             # User preferences
│   │   └── presentation/
│   │
│   └── profile/              # User wellness profile
│       ├── application/
│       ├── domain/
│       └── presentation/
│
└── main.dart                 # Bootstraps app
```

---

## 2. Layers & Responsibilities

Each feature follows **DDD-inspired layering**:

- **Domain**  
  - Entities (pure Dart classes, no Flutter dependencies)  
  - Abstract repository interfaces  
- **Application**  
  - Controllers/Notifiers (state management via Riverpod)  
  - Exposes state via providers  
- **Infrastructure / Data**  
  - Implements repositories (Prefs, Drift, API clients)  
  - Converts raw DB/network responses into domain models  
- **Presentation**  
  - Screens (widgets + layout)  
  - Calls application layer via providers  
  - ✅ **Never directly calls DB or APIs**

---

## 3. Riverpod Usage Guidelines

- Providers live in **application layer**
- **Notifier** → owns business logic
- **Provider** → injects repository / service

Example:

```dart
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthController(repo);
});
```

---

## 4. Repository Pattern Guidelines

- Always define repository **abstract interface** in `domain/`
- Provide concrete implementations in `infrastructure/` or `data/`
- Inject into controllers via Riverpod providers

Example:

```dart
// domain/auth_repository.dart
abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
}

// infrastructure/auth_repository_prefs.dart
class AuthRepositoryPrefs implements AuthRepository {
  final SharedPreferences prefs;
  AuthRepositoryPrefs(this.prefs);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    // save locally or call API
  }
}
```

---

## 5. UI & Screens Guidelines

- **Presentation layer only reads from providers**
- No direct DB/API calls in widgets
- Use `ConsumerWidget` or `Consumer` for reading providers
- Keep UI & logic separate

Example:

```dart
class SignInScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return ElevatedButton(
      onPressed: () {
        ref.read(authControllerProvider.notifier).signInWithEmail(
              email: 'test@email.com',
              password: '1234',
            );
      },
      child: state.isLoading ? CircularProgressIndicator() : Text('Sign In'),
    );
  }
}
```

---

## 6. Naming Conventions

- **Features**: snake_case → `auth`, `home`, `ai_assistant`  
- **Files**: snake_case → `auth_controller.dart`  
- **Classes**: PascalCase → `AuthController`  
- **Providers**: suffix with `Provider` → `authControllerProvider`  

---

## 7. Database & Reset

- Drift DB lives in `core/db`  
- DAOs per entity (e.g., `user_dao.dart`)  
- **Resetting app** → use `reset_utils.dart` wired into Settings  
  - Deletes DB file (`wellness.sqlite`)  
  - Clears SharedPreferences  
  - Resets user sessions  

---

## 8. Feature Development Workflow

When adding a new feature:

1. Create folder under `lib/features/<name>/`
2. Add subfolders: `domain`, `application`, `infrastructure` (if needed), `presentation`
3. Define **domain models + repository interface**
4. Implement repository in `infrastructure` (Prefs/API/DB)
5. Add **controller** with providers in `application`
6. Build **screens** in `presentation`
7. Wire routes in `router_provider.dart`
8. Add tests if possible

---

## 9. Best Practices

- ❌ Avoid putting logic inside widgets  
- ✅ Keep controllers as single source of truth  
- ✅ Use `StateNotifier` + immutable state models  
- ✅ Use constants & enums for predictable states  
- ✅ Keep repositories swappable (DB → Supabase migration)  
- ✅ Use feature flags for experimental code  
