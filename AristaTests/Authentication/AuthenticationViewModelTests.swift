//
//  AuthenticationViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 11/09/2025.
//

@testable import Arista
import XCTest
import CoreData
import CustomTextFields

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    var sut: AuthenticationViewModel!
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var coordinator: AppCoordinator!
    var spyToastyManager: SpyToastyManager!

    override func setUp() {
        super.setUp()

        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        
        dataManager = UserDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: dataManager)
        
        spyToastyManager = ToastyTestHelpers.createSpyManager()
        
        sut = AuthenticationViewModel(
            appCoordinator: coordinator,
        )
        sut.configure(toastyManager: spyToastyManager)
    }
    
    override func tearDown() {
        testContainer.clearAllData()
        spyToastyManager = nil
        sut = nil
        super.tearDown()
    }

    ///Initial State Tests
    func test_initialState_shouldHaveEmptyFieldsAndNeutralValidation() {
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
        XCTAssertEqual(sut.firstName, "")
        XCTAssertEqual(sut.lastName, "")
        XCTAssertFalse(sut.creationMode)
        XCTAssertEqual(sut.buttonState, .disabled)

        // Validation states should be neutral
        XCTAssertEqual(sut.emailValidationState, .neutral)
        XCTAssertEqual(sut.passwordValidationState, .neutral)
        XCTAssertEqual(sut.firstNameValidationState, .neutral)
        XCTAssertEqual(sut.lastNameValidationState, .neutral)
    }

    /// Form Validation Tests
    func test_isFormValid_withEmptyFields_shouldBeFalse() {
        XCTAssertFalse(sut.isFormValid)
    }

    func test_isLoginFormValid_withValidCredentials_shouldBeTrue() {
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        XCTAssertTrue(sut.isFormValid)
        XCTAssertTrue(sut.isLoginFormValid)
    }
    
    func test_isLoginFormValid_withInvalidEmail_shouldBeFalse() {
        sut.email = "invalid-email"
        sut.password = SharedTestHelper.sampleUserData.password
        
        XCTAssertFalse(sut.isMailValid)
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_isLoginFormValid_withWeakPassword_shouldBeFalse() {
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = "weak"
        
        XCTAssertFalse(sut.isPasswordValid)
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_isCreationFormValid_withAllValidFields_shouldBeTrue() {
        sut.creationMode = true
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        XCTAssertTrue(sut.isFormValid)
        XCTAssertTrue(sut.isCreationFormValid)
    }
    
    func test_isCreationFormValid_withEmptyFirstName_shouldBeFalse() {
        sut.creationMode = true
        sut.firstName = ""
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        XCTAssertFalse(sut.isFirstNameValid)
        XCTAssertFalse(sut.isFormValid)
        XCTAssertFalse(sut.isCreationFormValid)
    }
    
    /// Individual Field Validation Tests
    func test_isMailValid_withValidEmail_shouldBeTrue() {
        sut.email = "test@example.com"
        XCTAssertTrue(sut.isMailValid)
    }
    
    func test_isMailValid_withInvalidEmail_shouldBeFalse() {
        sut.email = "invalid-email"
        XCTAssertFalse(sut.isMailValid)
    }
    
    func test_isPasswordValid_withStrongPassword_shouldBeTrue() {
        sut.password = "StrongPass123!"
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withWeakPassword_shouldBeFalse() {
        sut.password = "weak"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isFirstNameValid_withValidName_shouldBeTrue() {
        sut.firstName = "John"
        XCTAssertTrue(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withInvalidName_shouldBeFalse() {
        sut.firstName = "J"  // Too short
        XCTAssertFalse(sut.isFirstNameValid)
    }
    
    /// Button State Management Tests
    func test_updateButtonState_withValidForm_shouldEnableButton() {
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        sut.updateButtonState()
        
        XCTAssertEqual(sut.buttonState, .enabled)
    }
    
    func test_updateButtonState_withInvalidForm_shouldDisableButton() {
        sut.email = "invalid"
        sut.password = "weak"
        
        sut.updateButtonState()
        
        XCTAssertEqual(sut.buttonState, .disabled)
    }

    /// Validation State Management Tests
    func test_resetFieldValidation_shouldResetSpecificField() {
        // Given
        sut.emailValidationState = .invalid
        sut.passwordValidationState = .invalid
        
        // When
        sut.resetFieldValidation(.email)
        
        // Then
        XCTAssertEqual(sut.emailValidationState, .neutral)
        XCTAssertEqual(sut.passwordValidationState, .invalid)
    }
    
    func test_resetFieldValidation_firstName_resetsFromInvalidToNeutral() {
        // Given
        sut.firstNameValidationState = .invalid
        
        // When
        sut.resetFieldValidation(.firstName)
        
        // Then
        XCTAssertEqual(sut.firstNameValidationState, .neutral)
    }

    func test_resetFieldValidation_lastName_resetsFromInvalidToNeutral() {
        // Given
        sut.lastNameValidationState = .invalid
        
        // When
        sut.resetFieldValidation(.lastName)
        
        // Then
        XCTAssertEqual(sut.lastNameValidationState, .neutral)
    }

    func test_resetFieldValidation_password_resetsFromInvalidToNeutral() {
        // Given
        sut.passwordValidationState = .invalid
        
        // When
        sut.resetFieldValidation(.password)
        
        // Then
        XCTAssertEqual(sut.passwordValidationState, .neutral)
    }

    func test_resetAllValidationStates_shouldResetAllFields() {
        // Given
        sut.emailValidationState = .invalid
        sut.passwordValidationState = .invalid
        sut.firstNameValidationState = .invalid
        sut.lastNameValidationState = .invalid
        
        // When
        sut.resetAllValidationStates()
        
        // Then
        XCTAssertEqual(sut.emailValidationState, .neutral)
        XCTAssertEqual(sut.passwordValidationState, .neutral)
        XCTAssertEqual(sut.firstNameValidationState, .neutral)
        XCTAssertEqual(sut.lastNameValidationState, .neutral)
    }

    func test_validateAllFields_withValidFields_shouldReturnTrue() {
        // Given
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        // When
        let result = sut.validateAllFields()
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(sut.emailValidationState, .neutral)
        XCTAssertEqual(sut.passwordValidationState, .neutral)
    }
    
    func test_validateAllFields_withInvalidEmail_shouldReturnFalseAndSetState() {
        // Given
        sut.email = "invalid-email"
        sut.password = SharedTestHelper.sampleUserData.password
        
        // When
        let result = sut.validateAllFields()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(sut.emailValidationState, .invalid)
        XCTAssertEqual(sut.passwordValidationState, .neutral)
    }
    
    func test_validateAllFields_inCreationMode_withInvalidFirstName_shouldSetState() {
        // Given
        sut.creationMode = true
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        sut.firstName = "J"
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        
        // When
        let result = sut.validateAllFields()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(sut.firstNameValidationState, .invalid)
        XCTAssertEqual(sut.lastNameValidationState, .neutral)
    }
    
    func test_validateAllFields_inCreationMode_withInvalidLastName_shouldSetState() {
        // Given
        sut.creationMode = true
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = "X"
        
        // When
        let result = sut.validateAllFields()
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(sut.lastNameValidationState, .invalid)
    }

    /// Submit Handling Tests
    func test_handleSubmit_withValidForm_shouldNotSetErrorState() {
        // Given
        let expectation = XCTestExpectation(description: "Submit should complete")
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        // Create test user first
        SharedTestHelper.createSampleUser(in: context)
        try! SharedTestHelper.saveContext(context)
        
        // When
        sut.handleSubmit()
        
        // Then - Wait a bit for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotEqual(self.sut.buttonState, .error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_handleSubmit_withInvalidForm_shouldSetErrorStateTemporarily() {
        // Given
        let expectation = XCTestExpectation(description: "Button should return to normal state")
        sut.email = "invalid-email"
        sut.password = "weak"
        
        // When
        sut.handleSubmit()
        
        // Then
        XCTAssertEqual(sut.buttonState, .error)
        XCTAssertEqual(sut.emailValidationState, .invalid)
        XCTAssertEqual(sut.passwordValidationState, .invalid)
        
        // Wait for button to return to normal state (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(self.sut.buttonState, .disabled) // Should be disabled due to invalid form
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    /// Login Tests (Updated)
    func test_login_withValidCredentials_shouldSucceed() throws {
        // Given
        let testUser = SharedTestHelper.createSampleUser(in: context)
        try SharedTestHelper.saveContext(context)
        
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        // When
        try sut.login()
        
        // Then
        XCTAssertEqual(coordinator.currentUser?.id, testUser.id)
        XCTAssertTrue(coordinator.isAuthenticated)
        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }
    
    func test_login_withInvalidForm_shouldThrowValidationError() {
        // Given
        sut.email = ""
        sut.password = ""
        
        // When / Then
        XCTAssertThrowsError(try sut.login()) { error in
            XCTAssertEqual(error as? AuthenticationError, .validationFailed)
        }
    }
    
    func test_login_withWrongCredentials_shouldThrowInvalidCredentials() throws {
        // Given
        SharedTestHelper.createSampleUser(in: context)
        try SharedTestHelper.saveContext(context)
        
        sut.email = "wrong@email.com"
        sut.password = SharedTestHelper.sampleUserData.password
        
        // When / Then
        XCTAssertThrowsError(try sut.login()) { error in
            XCTAssertEqual(error as? AuthenticationError, .invalidCredentials)
        }
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
    }
    
    /// Create Account Tests
    func test_createUserAndLogin_withValidForm_shouldSucceed() throws {
        // Given
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        
        // When
        try sut.createUserAndLogin()
        
        // Then
        XCTAssertNotNil(coordinator.currentUser)
        XCTAssertTrue(coordinator.isAuthenticated)
        XCTAssertEqual(coordinator.currentUser?.email, sut.email)
        XCTAssertEqual(spyToastyManager.showCallCount, 0)
    }
    
    func test_createUserAndLogin_withInvalidForm_shouldThrowValidationError() {
        // Given
        sut.firstName = ""
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        // When / Then
        XCTAssertThrowsError(try sut.createUserAndLogin()) { error in
            XCTAssertEqual(error as? AuthenticationError, .validationFailed)
        }
    }
    
    func test_createUserAndLogin_withUsedEmail_shouldThrowEmailAlreadyUsed() {
        // Given
        let existingUser = SharedTestHelper.createSampleUser(in: context)
        try! context.save()
        
        sut.email = existingUser.email
        sut.password = SharedTestHelper.sampleUserData.password
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        
        // When / Then
        XCTAssertThrowsError(try sut.createUserAndLogin()) { error in
            XCTAssertEqual(error as? AuthenticationError, .emailAlreadyUsed)
        }
    }
    
    /// Mode Switching Tests
    func test_creationMode_shouldAffectFormValidation() {
        // Given
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        
        XCTAssertTrue(sut.isFormValid)
        
        sut.creationMode = true
        
        XCTAssertFalse(sut.isFormValid)
        
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        
        XCTAssertTrue(sut.isFormValid)
    }
}
