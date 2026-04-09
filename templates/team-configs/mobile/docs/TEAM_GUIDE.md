# Mobile Team Guide

## Overview

This guide provides comprehensive standards, practices, and guidelines for the mobile engineering team working on iOS, Android, and React Native platforms.

## Table of Contents

1. [Team Structure](#team-structure)
2. [Platform-Specific Standards](#platform-specific-standards)
3. [Shared Code Guidelines](#shared-code-guidelines)
4. [Native Module Integration](#native-module-integration)
5. [Development Workflow](#development-workflow)
6. [Architecture Patterns](#architecture-patterns)
7. [Testing Strategy](#testing-strategy)
8. [Performance Guidelines](#performance-guidelines)
9. [Security Best Practices](#security-best-practices)
10. [Tooling and Infrastructure](#tooling-and-infrastructure)

---

## Team Structure

### Roles and Responsibilities

**iOS Team (@mobile-ios)**
- Swift and Objective-C development
- iOS-specific features and UI
- App Store deployment
- iOS performance optimization
- Apple platform integrations

**Android Team (@mobile-android)**
- Kotlin and Java development
- Android-specific features and UI
- Google Play deployment
- Android performance optimization
- Google platform integrations

**Shared Responsibilities**
- Cross-platform architecture decisions
- React Native development
- Native module development
- API client development
- Shared business logic

### Communication Channels

- **Slack**: `#mobile-team`, `#mobile-ios`, `#mobile-android`
- **Stand-ups**: Daily at 10:00 AM
- **Planning**: Bi-weekly on Mondays
- **Retros**: Bi-weekly on Fridays
- **On-call**: Rotating weekly schedule

---

## Platform-Specific Standards

### iOS Coding Standards

#### Language: Swift 5.9+

**Code Style**
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for automated style checking
- 2 spaces for indentation
- Maximum line length: 120 characters

**Naming Conventions**
```swift
// Types: PascalCase
class UserProfileViewModel { }
struct LoginCredentials { }
enum NetworkError { }

// Variables and functions: camelCase
var userName: String
func fetchUserData() async throws -> User

// Constants: camelCase (same as variables)
let maximumRetryAttempts = 3

// Private properties: prefix with underscore (optional)
private var _cachedData: [String: Any]?

// Protocols: Descriptive adjective or noun
protocol Loadable { }
protocol DataSource { }
```

**File Organization**
```swift
// MARK: - Imports
import Foundation
import UIKit

// MARK: - Type Definition
class UserProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: UserProfileViewModel
    private lazy var tableView: UITableView = { }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() { }
    
    // MARK: - Actions
    @objc private func didTapButton() { }
    
    // MARK: - Helper Methods
    private func updateUI() { }
}

// MARK: - UITableViewDataSource
extension UserProfileViewController: UITableViewDataSource {
    // Implementation
}

// MARK: - UITableViewDelegate
extension UserProfileViewController: UITableViewDelegate {
    // Implementation
}
```

**Modern Swift Patterns**
```swift
// Use async/await instead of completion handlers
func fetchUser(id: String) async throws -> User {
    let request = URLRequest(url: userURL(id))
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(User.self, from: data)
}

// Use structured concurrency
func fetchDashboardData() async throws -> Dashboard {
    async let user = fetchUser()
    async let posts = fetchPosts()
    async let notifications = fetchNotifications()
    
    return try await Dashboard(
        user: user,
        posts: posts,
        notifications: notifications
    )
}

// Use result builders for DSL
@resultBuilder
struct ViewBuilder {
    static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }
}
```

**Memory Management**
```swift
// Use [weak self] in closures to prevent retain cycles
viewModel.onUpdate = { [weak self] in
    self?.updateUI()
}

// Use unowned only when certain the reference won't be nil
class ViewModel {
    unowned let coordinator: Coordinator
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
}
```

#### UI Development

**UIKit vs SwiftUI**
- **UIKit**: Mature features, complex layouts, backward compatibility
- **SwiftUI**: New features, simple layouts, iOS 15+ only

**SwiftUI Best Practices**
```swift
struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                userInfoSection
                settingsSection
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    @ViewBuilder
    private var userInfoSection: some View {
        Section("User Information") {
            Text(viewModel.userName)
            Text(viewModel.userEmail)
        }
    }
}
```

**UIKit Best Practices**
```swift
class UserProfileViewController: UIViewController {
    // Use lazy properties for views
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    // Use Auto Layout programmatically
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
```

#### Dependencies

**Preferred Package Manager: Swift Package Manager**

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.52.0")
]
```

**Alternative: CocoaPods** (for older dependencies)

```ruby
# Podfile
platform :ios, '14.0'
use_frameworks!

target 'App' do
  pod 'SDWebImage', '~> 5.18'
  pod 'Firebase/Analytics'
end
```

### Android Coding Standards

#### Language: Kotlin 1.9+

**Code Style**
- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use ktlint for automated style checking
- 4 spaces for indentation
- Maximum line length: 120 characters

**Naming Conventions**
```kotlin
// Classes and objects: PascalCase
class UserProfileViewModel { }
data class LoginCredentials()
sealed class NetworkError

// Functions and variables: camelCase
var userName: String
fun fetchUserData(): Flow<User>

// Constants: SCREAMING_SNAKE_CASE
const val MAX_RETRY_ATTEMPTS = 3

// Private properties: camelCase (no underscore)
private var cachedData: Map<String, Any>? = null

// Interfaces: Descriptive adjective or noun
interface Loadable { }
interface DataSource { }
```

**File Organization**
```kotlin
package com.example.app.ui.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

/**
 * ViewModel for user profile screen.
 * Manages user data and profile update operations.
 */
class UserProfileViewModel(
    private val userRepository: UserRepository
) : ViewModel() {
    
    // State
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    
    // Public API
    fun loadUserProfile() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            userRepository.getUser()
                .catch { error -> _uiState.value = UiState.Error(error) }
                .collect { user -> _uiState.value = UiState.Success(user) }
        }
    }
    
    // UI State
    sealed class UiState {
        object Loading : UiState()
        data class Success(val user: User) : UiState()
        data class Error(val error: Throwable) : UiState()
    }
}
```

**Modern Kotlin Patterns**
```kotlin
// Use coroutines and Flow
fun observeUsers(): Flow<List<User>> = flow {
    while (true) {
        val users = userRepository.getUsers()
        emit(users)
        delay(5000)
    }
}

// Use sealed classes for type-safe states
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Use delegation
class UserPreferences(context: Context) {
    private val prefs by lazy {
        context.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
    }
    
    var userName: String by stringPreference("user_name", "")
}

// Use extension functions
fun String.isValidEmail(): Boolean {
    return android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()
}
```

#### UI Development

**Jetpack Compose (Preferred for new code)**
```kotlin
@Composable
fun UserProfileScreen(
    viewModel: UserProfileViewModel = viewModel(),
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Profile") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        when (val state = uiState) {
            is UiState.Loading -> LoadingIndicator()
            is UiState.Success -> UserProfileContent(state.user)
            is UiState.Error -> ErrorMessage(state.error)
        }
    }
    
    LaunchedEffect(Unit) {
        viewModel.loadUserProfile()
    }
}
```

**XML Layouts (Legacy code)**
```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    
    <TextView
        android:id="@+id/userNameText"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        android:textAppearance="@style/TextAppearance.App.Headline" />
        
</androidx.constraintlayout.widget.ConstraintLayout>
```

#### Dependencies

**Gradle (Kotlin DSL)**
```kotlin
// build.gradle.kts
dependencies {
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.20")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    
    // AndroidX
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2")
    
    // Compose
    implementation("androidx.compose.ui:ui:1.5.4")
    implementation("androidx.compose.material3:material3:1.1.2")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito.kotlin:mockito-kotlin:5.1.0")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
```

### React Native Standards

#### Language: TypeScript 5.0+

**Code Style**
- Follow [Airbnb TypeScript Style Guide](https://github.com/airbnb/javascript)
- Use ESLint and Prettier
- 2 spaces for indentation
- Maximum line length: 100 characters

**Component Structure**
```typescript
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId, onUpdate }) => {
  const navigation = useNavigation();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUser();
  }, [userId]);

  const loadUser = async () => {
    try {
      setLoading(true);
      const userData = await UserService.getUser(userId);
      setUser(userData);
    } catch (error) {
      console.error('Failed to load user:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (!user) {
    return <ErrorView message="User not found" />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.name}>{user.name}</Text>
      <Text style={styles.email}>{user.email}</Text>
      <TouchableOpacity 
        style={styles.button}
        onPress={() => navigation.navigate('EditProfile')}
      >
        <Text style={styles.buttonText}>Edit Profile</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  email: {
    fontSize: 16,
    color: '#666',
    marginBottom: 24,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

**State Management**
```typescript
// Redux Toolkit (preferred)
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchUser = createAsyncThunk(
  'user/fetch',
  async (userId: string) => {
    const response = await UserService.getUser(userId);
    return response;
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState: {
    data: null as User | null,
    loading: false,
    error: null as string | null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.loading = false;
        state.data = action.payload;
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message ?? 'Unknown error';
      });
  },
});

export default userSlice.reducer;
```

---

## Shared Code Guidelines

### When to Share Code

**Good candidates for sharing:**
- Business logic
- API clients and networking
- Data models and DTOs
- Validation rules
- Utility functions
- Authentication flows
- Analytics events

**Poor candidates for sharing:**
- UI components (platform-specific UX)
- Platform APIs (camera, location, etc.)
- Navigation logic
- Animation implementations
- Platform-specific optimizations

### Shared Code Architecture

**Directory Structure**
```
shared/
├── models/          # Data models
├── services/        # Business logic
├── api/             # API clients
├── utils/           # Utility functions
└── interfaces/      # Platform interfaces
```

**Example: Shared API Client**

```typescript
// shared/api/UserApi.ts
export interface UserApi {
  getUser(id: string): Promise<User>;
  updateUser(id: string, data: Partial<User>): Promise<User>;
}

export class UserApiClient implements UserApi {
  constructor(private baseUrl: string, private httpClient: HttpClient) {}

  async getUser(id: string): Promise<User> {
    const response = await this.httpClient.get(`${this.baseUrl}/users/${id}`);
    return this.parseUser(response.data);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    const response = await this.httpClient.put(
      `${this.baseUrl}/users/${id}`,
      data
    );
    return this.parseUser(response.data);
  }

  private parseUser(data: any): User {
    // Shared parsing logic
    return {
      id: data.id,
      name: data.name,
      email: data.email,
      // ...
    };
  }
}
```

**iOS Usage**
```swift
// Wrap shared API in Swift-friendly interface
class UserService {
    private let api: UserApiClient
    
    init(baseUrl: String) {
        self.api = UserApiClient(
            baseUrl: baseUrl,
            httpClient: URLSessionHttpClient()
        )
    }
    
    func getUser(id: String) async throws -> User {
        return try await api.getUser(id: id)
    }
}
```

**Android Usage**
```kotlin
// Use shared API directly with Kotlin
class UserRepository(
    private val api: UserApiClient
) {
    suspend fun getUser(id: String): Result<User> {
        return try {
            val user = api.getUser(id)
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### Platform Interface Pattern

When you need platform-specific implementations:

```typescript
// shared/interfaces/ImagePicker.ts
export interface ImagePicker {
  pickImage(options: ImagePickerOptions): Promise<ImageResult>;
}

export interface ImagePickerOptions {
  quality: number;
  allowsEditing: boolean;
}

export interface ImageResult {
  uri: string;
  width: number;
  height: number;
}
```

**iOS Implementation**
```swift
import UIKit
import Photos

class IOSImagePicker: ImagePicker {
    func pickImage(options: ImagePickerOptions) async throws -> ImageResult {
        let picker = UIImagePickerController()
        picker.allowsEditing = options.allowsEditing
        // Implementation using UIImagePickerController
        return ImageResult(uri: imageUri, width: width, height: height)
    }
}
```

**Android Implementation**
```kotlin
import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts

class AndroidImagePicker : ImagePicker {
    override suspend fun pickImage(options: ImagePickerOptions): ImageResult {
        // Implementation using ActivityResultContracts
        return ImageResult(uri = imageUri, width = width, height = height)
    }
}
```

---

## Native Module Integration

### Creating Native Modules

When React Native needs access to platform APIs not exposed by default.

**iOS Native Module**
```swift
import React

@objc(BiometricAuth)
class BiometricAuth: NSObject {
    
    @objc
    func authenticate(
        _ reason: String,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            rejecter("AUTH_UNAVAILABLE", "Biometric auth not available", error)
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            if success {
                resolver(true)
            } else {
                rejecter("AUTH_FAILED", "Authentication failed", error)
            }
        }
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
```

```objc
// BiometricAuth.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BiometricAuth, NSObject)

RCT_EXTERN_METHOD(authenticate:(NSString *)reason
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)

@end
```

**Android Native Module**
```kotlin
package com.app.modules

import com.facebook.react.bridge.*
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity

class BiometricAuthModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    
    override fun getName() = "BiometricAuth"
    
    @ReactMethod
    fun authenticate(reason: String, promise: Promise) {
        val activity = currentActivity as? FragmentActivity
        if (activity == null) {
            promise.reject("NO_ACTIVITY", "Activity not available")
            return
        }
        
        val biometricManager = BiometricManager.from(activity)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                showBiometricPrompt(activity, reason, promise)
            }
            else -> {
                promise.reject("AUTH_UNAVAILABLE", "Biometric auth not available")
            }
        }
    }
    
    private fun showBiometricPrompt(
        activity: FragmentActivity,
        reason: String,
        promise: Promise
    ) {
        val executor = ContextCompat.getMainExecutor(activity)
        val biometricPrompt = BiometricPrompt(
            activity,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    result: BiometricPrompt.AuthenticationResult
                ) {
                    promise.resolve(true)
                }
                
                override fun onAuthenticationFailed() {
                    promise.reject("AUTH_FAILED", "Authentication failed")
                }
            }
        )
        
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(reason)
            .setNegativeButtonText("Cancel")
            .build()
        
        biometricPrompt.authenticate(promptInfo)
    }
}
```

**TypeScript Interface**
```typescript
// src/modules/BiometricAuth.ts
import { NativeModules } from 'react-native';

interface BiometricAuthModule {
  authenticate(reason: string): Promise<boolean>;
}

export const BiometricAuth = NativeModules.BiometricAuth as BiometricAuthModule;

// Usage
try {
  const success = await BiometricAuth.authenticate('Please authenticate');
  if (success) {
    console.log('Authentication successful');
  }
} catch (error) {
  console.error('Authentication failed:', error);
}
```

---

## Development Workflow

### Environment Setup

**iOS**
```bash
# Install Xcode from App Store
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Install dependencies
cd ios
pod install
```

**Android**
```bash
# Install Android Studio
# Install Android SDK
# Set ANDROID_HOME environment variable

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

**React Native**
```bash
# Install Node.js 18+
# Install dependencies
npm install

# iOS
cd ios && pod install && cd ..
npm run ios

# Android
npm run android
```

### Running the App

**iOS**
```bash
# Simulator
npm run ios

# Specific device
npm run ios -- --simulator="iPhone 15 Pro"

# Physical device
xcodebuild -workspace ios/App.xcworkspace \
  -scheme App \
  -destination 'platform=iOS,name=My iPhone' \
  run
```

**Android**
```bash
# Emulator
npm run android

# Specific device
adb devices  # List devices
npm run android -- --deviceId=<device-id>
```

### Debugging

**iOS**
- Xcode debugger
- LLDB console
- Instruments for profiling
- React Native Debugger

**Android**
- Android Studio debugger
- Logcat
- Android Profiler
- React Native Debugger

**React Native**
```bash
# Open Chrome DevTools
# Press Cmd+D (iOS) or Cmd+M (Android) in simulator
# Enable "Debug JS Remotely"

# React Native Debugger
brew install --cask react-native-debugger
```

---

## Architecture Patterns

### iOS: MVVM + Coordinator

```swift
// Model
struct User {
    let id: String
    let name: String
    let email: String
}

// ViewModel
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let userService: UserService
    private let coordinator: UserProfileCoordinator
    
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await userService.getUser(id: id)
        } catch {
            self.error = error
        }
    }
    
    func editProfile() {
        coordinator.showEditProfile(user: user)
    }
}

// View
struct UserProfileView: View {
    @StateObject var viewModel: UserProfileViewModel
    
    var body: some View {
        // UI implementation
    }
}

// Coordinator
class UserProfileCoordinator {
    weak var navigationController: UINavigationController?
    
    func showEditProfile(user: User?) {
        let editVC = EditProfileViewController(user: user)
        navigationController?.pushViewController(editVC, animated: true)
    }
}
```

### Android: MVI + Clean Architecture

```kotlin
// Domain Layer
data class User(
    val id: String,
    val name: String,
    val email: String
)

interface UserRepository {
    suspend fun getUser(id: String): Result<User>
}

// Presentation Layer
sealed class UserProfileIntent {
    data class LoadUser(val id: String) : UserProfileIntent()
    object EditProfile : UserProfileIntent()
}

sealed class UserProfileState {
    object Loading : UserProfileState()
    data class Success(val user: User) : UserProfileState()
    data class Error(val message: String) : UserProfileState()
}

class UserProfileViewModel(
    private val repository: UserRepository
) : ViewModel() {
    
    private val _state = MutableStateFlow<UserProfileState>(UserProfileState.Loading)
    val state: StateFlow<UserProfileState> = _state.asStateFlow()
    
    fun handleIntent(intent: UserProfileIntent) {
        when (intent) {
            is UserProfileIntent.LoadUser -> loadUser(intent.id)
            is UserProfileIntent.EditProfile -> navigateToEditProfile()
        }
    }
    
    private fun loadUser(id: String) {
        viewModelScope.launch {
            _state.value = UserProfileState.Loading
            repository.getUser(id)
                .onSuccess { user -> _state.value = UserProfileState.Success(user) }
                .onFailure { error -> _state.value = UserProfileState.Error(error.message ?: "") }
        }
    }
}
```

---

## Testing Strategy

See detailed requirements in `pr-requirements.md`.

**Key Points:**
- 70% minimum code coverage
- Platform-specific unit tests (XCTest, JUnit)
- UI tests for critical flows
- Integration tests for API clients
- Performance tests for launch time and memory

---

## Performance Guidelines

### App Size Optimization

**iOS:**
- Use App Thinning
- Enable Bitcode
- Strip debug symbols in release builds
- Compress assets

**Android:**
- Use Android App Bundles
- Enable ProGuard/R8
- Use WebP for images
- Split APKs by ABI

### Launch Time Optimization

- Lazy load dependencies
- Defer non-critical initialization
- Use splash screen effectively
- Optimize image loading

### Memory Management

**iOS:**
- Profile with Instruments
- Fix retain cycles
- Use `autoreleasepool` for loops
- Implement memory warnings

**Android:**
- Profile with Android Profiler
- Avoid memory leaks
- Use WeakReference appropriately
- Implement `onTrimMemory()`

---

## Security Best Practices

### Data Storage

**Sensitive Data:**
- iOS: Use Keychain
- Android: Use EncryptedSharedPreferences or Keystore

**Example (iOS):**
```swift
import Security

func saveToKeychain(key: String, value: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
}
```

**Example (Android):**
```kotlin
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val sharedPreferences = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
```

### Network Security

- Use HTTPS only
- Implement certificate pinning for critical APIs
- Validate SSL certificates
- Use secure WebSocket (WSS)

### Code Obfuscation

**iOS:**
- Enable optimization level in release builds
- Use Swift's access control

**Android:**
- Enable ProGuard/R8
- Obfuscate sensitive strings

---

## Tooling and Infrastructure

### CI/CD

See `mobile-ci.yml` for complete CI configuration.

**Key Tools:**
- Fastlane for automated deployment
- TestFlight (iOS) / Internal Testing (Android)
- Firebase App Distribution for beta testing

### Monitoring

**Crash Reporting:**
- Firebase Crashlytics
- Sentry

**Analytics:**
- Firebase Analytics
- Mixpanel

**Performance Monitoring:**
- Firebase Performance
- New Relic Mobile

### Code Quality

**iOS:**
- SwiftLint
- SwiftFormat
- Sonar

**Android:**
- ktlint
- detekt
- SonarQube

**React Native:**
- ESLint
- Prettier
- TypeScript strict mode

---

## Resources

- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design Guidelines](https://m3.material.io/)
- [React Native Documentation](https://reactnative.dev/)
- Internal Wiki: `https://wiki.company.com/mobile`
- Team Slack: `#mobile-team`

---

## Questions?

Contact the mobile team leads:
- iOS: @ios-lead
- Android: @android-lead
- Architecture: @mobile-architect
