//
//  UserDataManagerTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 28/08/2025.
//

import Foundation
import CoreData
import XCTest
@testable import Arista

final class UserDataManagerTests: XCTestCase {

    var manager: UserDataManager!
    var context: NSManagedObjectContext!
    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        manager = UserDataManager(container: persistenceController.container)
    }

    override func tearDown() {
        manager = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    func testCreateUser_withEmptyEmail_throwError() throws {
        // Given / When
        XCTAssertThrowsError(
            try manager.createUser(email: "", password: "password", firstName: "", lastName: "Cena")
            // Then
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        }
    }

    func testCreateUser_withEmptyPassword_throwError() throws {
        // Given / When
        XCTAssertThrowsError(
            // Then
            try manager.createUser(email: "john.Cena@test.com", password: "", firstName: "", lastName: "Cena")
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        }
    }

    func testCreateUser_withEmptyFirstName_throwError() throws {
        // Given / When
        XCTAssertThrowsError(
            try manager.createUser(email: "john.Cena@test.com", password: "password", firstName: "", lastName: "Cena")
            // Then
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        }
    }

    func testCreateUser_withEmptyLastName_throwError() throws {
        
        XCTAssertThrowsError(
            // Given / When
            try manager.createUser(email: "john.Cena@test.com", password: "password", firstName: "John", lastName: "")
            // Then
        ) { error in
            guard let urlError = error as? URLError else {
                return
            }
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        }
    }

    func testCreateUser_withAllDatas_doesNotThrow() throws {
        // Given / When
        let user = try manager.createUser(email: "john.Cena@test.com", password: "password", firstName: "John",lastName: "Cena")

        // Then
        XCTAssertEqual(user.email, "john.Cena@test.com")
        XCTAssertEqual(user.login, "john.Cena@test.com")
        XCTAssertEqual(user.hashPassword, "password")
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.firstNameSafe, "John")
        XCTAssertEqual(user.lastName, "Cena")
        XCTAssertEqual(user.lastNameSafe, "Cena")
        XCTAssertNotNil(user.id)
        XCTAssertNotNil(user.salt)
        XCTAssertFalse(user.isLogged)
        XCTAssertNil(user.birthdate)
        XCTAssertEqual(user.calorieGoal, 2000)
        XCTAssertEqual(user.sleepGoal, 480)
        XCTAssertEqual(user.waterGoal, 25)
        XCTAssertEqual(user.gender, "other")
        XCTAssertEqual(user.genderEnum, .other)
        XCTAssertEqual(user.height, 0)
        XCTAssertEqual(user.weight, 0)
    }
    
    // MARK: - Fetching User Tests
    
    func testFetchUser_withExistingUser_returnUser() throws {
        // Given / Then
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        
        // When
        if let fetchedUser = try? manager.fetchUser(by: user.id!) {
            XCTAssertEqual(fetchedUser.email, user.email)
            XCTAssertEqual(fetchedUser.hashPassword, user.hashPassword)
            XCTAssertEqual(fetchedUser.firstName, user.firstName)
            XCTAssertEqual(fetchedUser.lastName, user.lastName)
            XCTAssertEqual(fetchedUser.id, user.id)
        }
    }
    
    func testFetchUser_withoutExistingUser_throwError() throws {
        // Given
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()
        let testUUID: UUID = UUID()
        
        XCTAssertThrowsError(
            //When
            try manager.fetchUser(by: testUUID)
            // Then
        ) { error in
            guard let userError = error as? UserDataManagerError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .userNotFound)
        }
    }

    func testFetchAllUsers_withNUser_returnNUsers() throws {
        // Given / When
        let randomCount: Int = Int.random(in: 1...100)
        SharedTestHelper.createUsers(count: randomCount, in: context)
        try context.save()
        
        // Then
        XCTAssertEqual(manager.allUsers.count, randomCount)

    }

    func testNoUserLogged_shouldReturnTrue() throws {
        // Given / When
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()
        
        // Then
        XCTAssertTrue(manager.noUserLogged)
    }
    
    func testNoUserLogged_shouldReturnFalse() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        try context.save()
        
        // When
        try builder.isLogged(true)
        // Then
        XCTAssertFalse(manager.noUserLogged)
    }
    
    func testFetchLoggedUser_returnsTheLoggedUser() throws {
        // Given
        let user1 = SharedTestHelper.createSampleUser(in: context)
        let user2 = SharedTestHelper.createSampleUser2(in: context)
        let builder = UserUpdateBuilder(user: user1, dataManager: manager)
        try context.save()
        
        // When
        try builder.isLogged(true).save()

        let loggedUser = try manager.fetchLoggedUser()

        XCTAssertNotNil(loggedUser)
        XCTAssertEqual(loggedUser.id, user1.id)
    }

    func testFetchLoggedUser_NoLoggedUser_throwError() throws {
        // Given
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()

        XCTAssertThrowsError(
            // When
            try manager.fetchLoggedUser()
            // Then
        ) { error in
            guard let userError = error as? UserDataManagerError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .noLoggedUser)
        }
    }
    
    func testLoggedOffAllUsers_NoLoggedUser_throwError() throws {
        // Given
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()
        
        // When
       try manager.loggedOffAllUsers()
        
        // Then
        XCTAssertTrue(manager.noUserLogged)
    }

    func testDeleteUser_userNotFound_throwError() throws {
        // Given
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()
        let testUUID: UUID = UUID()
        let usersCount = manager.allUsers.count
        
        XCTAssertThrowsError(
            // When
            try manager.deleteUser(by: testUUID)
            // Then
        ) { error in
            guard let userError = error as? UserDataManagerError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(manager.allUsers.count, usersCount)
            XCTAssertEqual(userError, .userNotFound)
        }
    }

    func testDeleteUser_deletedWithSuccess() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let userId = user.id!
        SharedTestHelper.createRandomUsers(in: context)
        try context.save()
        let usersCount = manager.allUsers.count
        
        // When
        try manager.deleteUser(by: userId)
        
        // Then
        XCTAssertEqual(manager.allUsers.count, usersCount - 1)
        XCTAssertThrowsError(try manager.fetchUser(by: userId))
    }
}
