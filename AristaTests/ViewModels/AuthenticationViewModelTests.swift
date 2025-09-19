//
//  AuthenticationViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 11/09/2025.
//

@testable import Arista
import XCTest
import CoreData

@MainActor
final class AuthenticationViewModelTests: XCTestCase {
    var sut: AuthenticationViewModel!
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var coordinator: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        
        testContainer = PersistenceController.createTestContainer()
        context = testContainer.container.viewContext
        
        dataManager = UserDataManager(container: testContainer.container)
        
        coordinator = AppCoordinator(dataManager: dataManager)
        
        sut = AuthenticationViewModel(appCoordinator: coordinator)
    }
    
    override func tearDown() {
        testContainer.clearAllData()
        super.tearDown()
    }
    
    // MARK: - Initial State
    func test_initialState_shouldHaveEmptyFields() {
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
    }
    
    // MARK: - Form Validation
    func test_isFormValid_withEmptyFields_shouldBeFalse() {
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_isLoginFormValid_withBothFields_shouldBeTrue() {
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        XCTAssertTrue(sut.isFormValid)
        XCTAssertTrue(sut.isLoginFormValid)
    }

    func test_isCreationFormValid_withBothFields_shouldBeTrue() {
        sut.creationMode = true
        sut.firstName = SharedTestHelper.sampleUserData.firstName
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        XCTAssertTrue(sut.isFormValid)
        XCTAssertTrue(sut.isLoginFormValid)
    }
    
    func test_isCreationFormValid_withEmptyFields_shouldBeFalse() {
        sut.creationMode = true
        sut.firstName = ""
        sut.lastName = SharedTestHelper.sampleUserData.lastName
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = SharedTestHelper.sampleUserData.password
        XCTAssertFalse(sut.isFormValid)
        XCTAssertTrue(sut.isLoginFormValid)
        XCTAssertFalse(sut.isCreationFormValid)
    }

    // MARK: - Login Success
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
    }
    
    // MARK: - Login Failure
    func test_login_withWrongEmail_throwError() throws {
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
    
    func test_login_withWrongPassword_throwError() throws {
        // Given
        SharedTestHelper.createSampleUser(in: context)
        try SharedTestHelper.saveContext(context)
        
        sut.email = SharedTestHelper.sampleUserData.email
        sut.password = "Wrongpassword123!"

        // When / Then
        XCTAssertThrowsError(try sut.login()) { error in
            XCTAssertEqual(error as? AuthenticationError, .invalidCredentials)
        }
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
    }
    
    func test_login_withInvalidForm_shouldNotAttemptLogin() throws {
        // Given - empty fields
        sut.email = ""
        sut.password = ""
        
        // When
        try sut.login()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
    }
    
    // MARK: - Create Account
    func test_createAccount_ShouldSucceed() throws {
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
    }
}
