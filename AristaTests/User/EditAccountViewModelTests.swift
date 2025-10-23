//
//  EditAccountViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 16/09/2025.
//

import Foundation

import XCTest
import CoreData
@testable import Arista

@MainActor
final class EditAccountViewModelTests: XCTestCase {
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var coordinator: AppCoordinator!
    
    override func setUp() {
        super.setUp()
        
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        dataManager = UserDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: dataManager)
    }
    
    override func tearDown() {
        testContainer = nil
        context = nil
        coordinator = nil
        super.tearDown()
    }
    
    func test_init_withLoggedUser_loadsUserData() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // When
        let sut = try EditAccountViewModel(appCoordinator: coordinator)
        
        // Then
        XCTAssertEqual(sut.firstName, user.firstName)
        XCTAssertEqual(sut.lastName, user.lastName)
        XCTAssertEqual(sut.email, user.email)
        XCTAssertEqual(sut.calorieGoal, String(user.calorieGoal))
        XCTAssertEqual(sut.sleepGoal, String(user.sleepGoal))
        XCTAssertEqual(sut.waterGoal, String(user.waterGoal))
    }
    
    func test_init_withNoLoggedUser_throwsError() throws {
        // Given / When / Then
        XCTAssertThrowsError(try EditAccountViewModel(appCoordinator: coordinator)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }
    
    func test_saveChanges_updatesAllModifiedFields_preservesUnmodifiedFields() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try EditAccountViewModel(appCoordinator: coordinator)
        
        let originalId = user.id
        let originalSalt = user.salt
        let originalEmail = user.email
        let originalHashPassword = user.hashPassword
        let originalIsLogged = user.isLogged
        
        let newBirthdate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 15))!
        
        // When
        sut.firstName = "NewFirstName"
        sut.lastName = "NewLastName"
        sut.calorieGoal = "2500"
        sut.sleepGoal = "420"
        sut.waterGoal = "30"
        
        try sut.saveChanges()
        
        // Then
        let updatedUser = try dataManager.fetchUser(by: user.id)
        
        // Verify modified fields
        XCTAssertEqual(updatedUser.firstName, "NewFirstName")
        XCTAssertEqual(updatedUser.lastName, "NewLastName")
        XCTAssertEqual(updatedUser.calorieGoal, 2500)
        XCTAssertEqual(updatedUser.sleepGoal, 420)
        XCTAssertEqual(updatedUser.waterGoal, 30)
        
        // Verify unmodified/protected fields remain unchanged
        XCTAssertEqual(updatedUser.id, originalId)
        XCTAssertEqual(updatedUser.salt, originalSalt)
        XCTAssertEqual(updatedUser.email, originalEmail)
        XCTAssertEqual(updatedUser.hashPassword, originalHashPassword)
        XCTAssertEqual(updatedUser.isLogged, originalIsLogged)
    }
    
    func test_saveChanges_noChanges_doesNotSave() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try EditAccountViewModel(appCoordinator: coordinator)
        
        // When
        try sut.saveChanges()
        
        // Then
        let unchangedUser = try dataManager.fetchUser(by: user.id)
        XCTAssertEqual(unchangedUser.firstName, user.firstName)
    }
    
    func test_deleteAccount_removesUserAndResetsCoordinator() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try EditAccountViewModel(appCoordinator: coordinator)
        
        // When
        try sut.deleteAccount()
        
        // Then
        XCTAssertNil(coordinator.currentUser)
        XCTAssertFalse(coordinator.isAuthenticated)
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let users = try context.fetch(request)
        XCTAssertTrue(users.isEmpty)
    }
}
