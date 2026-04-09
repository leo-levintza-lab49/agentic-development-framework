# Pull Request Requirements

## Overview

All pull requests must meet quality standards before merging. These requirements ensure code reliability, maintainability, and consistent performance across iOS and Android platforms.

## Checklist

Before submitting a PR, ensure:

- [ ] Code passes all CI checks (builds, tests, linting)
- [ ] Test coverage meets 70% minimum threshold
- [ ] Platform-specific tests included (XCTest for iOS, JUnit for Android)
- [ ] UI tests for critical user flows
- [ ] Performance testing completed (app size, launch time, memory)
- [ ] Code review approved by required reviewers
- [ ] Documentation updated (if applicable)
- [ ] No merge conflicts with target branch

## Code Coverage Requirements

### Minimum Coverage: 70%

All PRs must maintain or improve overall code coverage. Coverage must meet 70% for:

- **Line coverage** - Percentage of code lines executed
- **Branch coverage** - Percentage of conditional branches tested
- **Function coverage** - Percentage of functions called

### Coverage by Platform

**iOS (XCTest + XCTestExpectation):**
```bash
# Generate coverage report
xcodebuild test \
  -workspace ios/App.xcworkspace \
  -scheme App \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# View coverage
xcrun llvm-cov report \
  --instr-profile=Coverage.profdata \
  --object App.app/App
```

**Android (JUnit + JaCoCo):**
```bash
# Run tests with coverage
./gradlew testDebugUnitTest jacocoTestReport

# View coverage report
open android/app/build/reports/jacoco/jacocoTestReport/html/index.html
```

**React Native (Jest):**
```bash
# Run tests with coverage
npm test -- --coverage

# Coverage thresholds in jest.config.js
coverageThreshold: {
  global: {
    branches: 70,
    functions: 70,
    lines: 70,
    statements: 70
  }
}
```

### Exemptions

Some code may be excluded from coverage requirements:
- Generated code (protobuf, GraphQL types)
- Platform-specific glue code with < 5 lines
- Experimental features (must be flagged)
- Legacy code being deprecated (with timeline)

Document exemptions in PR description.

## Platform-Specific Testing

### iOS Testing (XCTest)

**Unit Tests Required:**
- Business logic classes
- View models
- Data transformations
- Network layer
- Persistence layer

**Example Test Structure:**
```swift
import XCTest
@testable import App

class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!
    var mockNetworkClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = AuthenticationService(client: mockNetworkClient)
    }
    
    func testLoginSuccess() async throws {
        // Given
        let credentials = Credentials(email: "test@example.com", password: "password")
        mockNetworkClient.stubResponse(LoginResponse(token: "abc123"))
        
        // When
        let result = try await sut.login(credentials: credentials)
        
        // Then
        XCTAssertEqual(result.token, "abc123")
        XCTAssertTrue(mockNetworkClient.loginCalled)
    }
    
    func testLoginFailure() async {
        // Given
        let credentials = Credentials(email: "test@example.com", password: "wrong")
        mockNetworkClient.stubError(AuthError.invalidCredentials)
        
        // When/Then
        await XCTAssertThrowsError(try await sut.login(credentials: credentials)) { error in
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }
}
```

**UI Tests Required:**
- Critical user flows (login, checkout, onboarding)
- Navigation paths
- Form validation
- Error state handling

### Android Testing (JUnit + Espresso)

**Unit Tests Required:**
- ViewModels
- Use cases / interactors
- Repository layer
- Data mappers
- Utility functions

**Example Test Structure:**
```kotlin
import org.junit.Test
import org.junit.Before
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations
import kotlinx.coroutines.test.runTest
import com.google.common.truth.Truth.assertThat

class AuthenticationViewModelTest {
    @Mock
    private lateinit var authRepository: AuthRepository
    
    private lateinit var viewModel: AuthenticationViewModel
    
    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        viewModel = AuthenticationViewModel(authRepository)
    }
    
    @Test
    fun `login with valid credentials emits success state`() = runTest {
        // Given
        val credentials = Credentials("test@example.com", "password")
        `when`(authRepository.login(credentials)).thenReturn(Result.success(Token("abc123")))
        
        // When
        viewModel.login(credentials)
        
        // Then
        assertThat(viewModel.uiState.value).isInstanceOf(UiState.Success::class.java)
        verify(authRepository).login(credentials)
    }
    
    @Test
    fun `login with invalid credentials emits error state`() = runTest {
        // Given
        val credentials = Credentials("test@example.com", "wrong")
        `when`(authRepository.login(credentials)).thenReturn(Result.failure(AuthException()))
        
        // When
        viewModel.login(credentials)
        
        // Then
        assertThat(viewModel.uiState.value).isInstanceOf(UiState.Error::class.java)
    }
}
```

**Instrumented Tests Required:**
- Database operations
- UI interactions (Espresso)
- Integration tests

### React Native Testing (Jest + React Testing Library)

**Unit Tests Required:**
- Component logic
- Hooks
- Redux actions/reducers
- Utility functions
- API clients

**Example Test Structure:**
```typescript
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { LoginScreen } from './LoginScreen';
import { AuthService } from '../services/AuthService';

jest.mock('../services/AuthService');

describe('LoginScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should login successfully with valid credentials', async () => {
    // Given
    const mockLogin = jest.fn().mockResolvedValue({ token: 'abc123' });
    (AuthService.login as jest.Mock) = mockLogin;
    
    const { getByTestId } = render(<LoginScreen />);
    
    // When
    fireEvent.changeText(getByTestId('email-input'), 'test@example.com');
    fireEvent.changeText(getByTestId('password-input'), 'password');
    fireEvent.press(getByTestId('login-button'));
    
    // Then
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password',
      });
    });
  });

  it('should show error message on login failure', async () => {
    // Given
    const mockLogin = jest.fn().mockRejectedValue(new Error('Invalid credentials'));
    (AuthService.login as jest.Mock) = mockLogin;
    
    const { getByTestId, getByText } = render(<LoginScreen />);
    
    // When
    fireEvent.changeText(getByTestId('email-input'), 'test@example.com');
    fireEvent.changeText(getByTestId('password-input'), 'wrong');
    fireEvent.press(getByTestId('login-button'));
    
    // Then
    await waitFor(() => {
      expect(getByText('Invalid credentials')).toBeTruthy();
    });
  });
});
```

## UI Tests for Critical Flows

### Critical User Flows

These flows MUST have comprehensive UI tests:

1. **Authentication**
   - Login
   - Signup
   - Password reset
   - Biometric authentication

2. **Onboarding**
   - First-time user experience
   - Permission requests
   - Tutorial/walkthrough

3. **Core Features**
   - Main user journey (varies by app)
   - Payment/checkout flow
   - Content creation/submission
   - Search and filtering

4. **Error Handling**
   - Network errors
   - Invalid inputs
   - Session expiration
   - Offline mode

### iOS UI Tests (XCUITest)

```swift
import XCTest

class LoginUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testSuccessfulLogin() {
        // Navigate to login
        app.buttons["Get Started"].tap()
        
        // Fill credentials
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Submit
        app.buttons["Login"].tap()
        
        // Verify success
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
    }
}
```

### Android UI Tests (Espresso)

```kotlin
@RunWith(AndroidJUnit4::class)
class LoginUITest {
    @get:Rule
    val activityRule = ActivityScenarioRule(LoginActivity::class.java)
    
    @Test
    fun successfulLogin() {
        // Fill credentials
        onView(withId(R.id.email_input))
            .perform(typeText("test@example.com"), closeSoftKeyboard())
        
        onView(withId(R.id.password_input))
            .perform(typeText("password123"), closeSoftKeyboard())
        
        // Submit
        onView(withId(R.id.login_button))
            .perform(click())
        
        // Verify success
        onView(withText("Home"))
            .check(matches(isDisplayed()))
    }
}
```

## Performance Testing

### App Size Limits

**iOS:**
- Target: < 50MB (uncompressed)
- Maximum: 100MB (triggers warning)
- Over-the-air limit: 200MB

Check with: `xcrun swift -print-stats`

**Android:**
- Target: < 30MB (APK)
- Maximum: 50MB (triggers warning)
- Split APKs for > 50MB

Check with: `./gradlew assembleRelease --info`

**Size Analysis:**
```bash
# iOS
xcrun swift-build-size-analyzer app.app

# Android
./gradlew analyzeReleaseBundle
```

### Launch Time Requirements

**iOS:**
- Cold launch: < 400ms (on iPhone 12+)
- Warm launch: < 200ms
- Measured from tap to interactive UI

**Android:**
- Cold start: < 500ms (on mid-range device)
- Warm start: < 300ms
- Measured to first frame

**Measurement Tools:**
- iOS: Instruments (Time Profiler)
- Android: Android Studio Profiler, `adb shell am start -W`

### Memory Usage Limits

**iOS:**
- Typical usage: < 200MB
- Peak usage: < 500MB
- Background: < 50MB

**Android:**
- Typical usage: < 150MB
- Peak usage: < 400MB
- Heap size: Stay below device limit

**Profiling:**
```bash
# iOS
instruments -t "Allocations" -D allocations.trace YourApp.app

# Android
./gradlew connectedCheck -Pandroid.testInstrumentationRunnerArguments.class=com.example.MemoryTest
```

### Frame Rate Requirements

- Maintain 60fps during scrolling
- No frame drops in critical animations
- 120fps support for ProMotion devices (iOS)

**Testing:**
- iOS: Instruments (Core Animation)
- Android: GPU Profiler in Android Studio

### Network Performance

- API response timeout: 30s
- Retry logic for failures
- Offline mode support
- Image loading optimization

## Code Review Requirements

### Review Assignments

Based on CODEOWNERS:
- **iOS code** → 1 reviewer from @polybase-poc/mobile-ios
- **Android code** → 1 reviewer from @polybase-poc/mobile-android
- **Shared code** → 2 reviewers (1 iOS + 1 Android)

### Review Checklist

Reviewers should verify:

- [ ] Code follows platform conventions (Swift/Kotlin style guides)
- [ ] No code smells (long methods, god classes, etc.)
- [ ] Error handling is comprehensive
- [ ] Security best practices followed
- [ ] Accessibility considerations included
- [ ] No hardcoded strings (use localization)
- [ ] No sensitive data logged
- [ ] Memory management correct (no retain cycles)
- [ ] Thread safety for concurrent operations
- [ ] Proper use of async/await patterns

### Review Response Time

- First review: within 24 hours
- Follow-up reviews: within 4 hours
- Hotfixes: within 1 hour

## Documentation Updates

Update documentation when:
- Adding new features → Update feature docs
- Changing APIs → Update API documentation
- Modifying build process → Update build docs
- Changing architecture → Update architecture docs

Required documentation:
- Code comments for complex logic
- README updates for new dependencies
- API documentation (inline docs)
- Architecture Decision Records (ADRs) for significant changes

## PR Description Template

```markdown
## Summary
Brief description of changes (2-3 sentences)

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Performance improvement
- [ ] Documentation

## Platforms Affected
- [ ] iOS
- [ ] Android
- [ ] Shared/React Native

## Testing
### Unit Tests
- Coverage: X%
- New tests: Y tests added
- Platform: iOS/Android/RN

### UI Tests
- Flows tested: [list critical flows]

### Performance Testing
- App size: XMB (before) → YMB (after)
- Launch time: Xms
- Memory usage: XMB peak

### Manual Testing
- [ ] Tested on iOS 15+
- [ ] Tested on Android 12+
- [ ] Tested on multiple device sizes
- [ ] Tested offline scenarios
- [ ] Tested error states

## Screenshots/Videos
[Add screenshots or screen recordings for UI changes]

## Breaking Changes
[List any breaking changes and migration steps]

## Checklist
- [ ] Tests pass locally
- [ ] CI passes
- [ ] Code coverage ≥ 70%
- [ ] UI tests for critical flows
- [ ] Performance requirements met
- [ ] Documentation updated
- [ ] CHANGELOG updated (for releases)

## References
- Related PR: #X
- Issue: #Y
- Design: [Figma link]
```

## Automated Checks

CI automatically verifies:

1. **Build Success**
   - iOS: Xcode build
   - Android: Gradle build
   - RN: npm build

2. **Linting**
   - iOS: SwiftLint
   - Android: ktlint
   - RN: ESLint + Prettier

3. **Tests**
   - All unit tests pass
   - Coverage ≥ 70%
   - UI tests pass

4. **Security**
   - No secrets in code
   - Dependency vulnerabilities check
   - npm audit / CocoaPods audit

5. **Performance**
   - App size within limits
   - No significant performance regressions

## Merge Requirements

Before merging:
- ✅ All CI checks pass
- ✅ Required reviews approved
- ✅ No unresolved comments
- ✅ Branch is up to date with base
- ✅ No merge conflicts

## Post-Merge

After merging:
1. Delete feature branch
2. Verify deployment (if auto-deployed)
3. Monitor crash reports
4. Monitor performance metrics

## FAQ

**Q: What if I can't reach 70% coverage?**  
A: Discuss with team. May be acceptable for UI-heavy code or prototypes, but needs explicit justification.

**Q: Do I need UI tests for every screen?**  
A: No, focus on critical user flows. Simple views can be covered with unit tests.

**Q: How do I test performance locally?**  
A: Use Instruments (iOS) or Android Profiler. CI will also run automated checks.

**Q: Can I merge with one approval?**  
A: Platform-specific code yes (1 reviewer). Shared code requires 2 reviewers.

**Q: What if tests are flaky?**  
A: Fix flaky tests before merging. Use retry logic sparingly and investigate root causes.

## References

- [iOS Testing Guide](https://developer.apple.com/documentation/xctest)
- [Android Testing Guide](https://developer.android.com/training/testing)
- [React Native Testing](https://reactnative.dev/docs/testing-overview)
- Mobile Team Runbook: `/docs/runbook.md`
