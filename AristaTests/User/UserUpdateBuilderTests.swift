//
//  UserUpdateBuilderTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 29/08/2025.
//

import Foundation
import CoreData
import XCTest
@testable import Arista

final class UserUpdateBuilderTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var manager: UserDataManager!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        manager = UserDataManager(container: persistenceController.container)
    }
    
    override func tearDown() {
        persistenceController = nil
        manager = nil
        super.tearDown()
    }
    
    func testUpdateFirstName_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.firstName("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyFirstName)
        }
    }

    func testUpdateFirstName() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // When
        try builder.firstName("Alice").save()
        
        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(updatedUser.firstName, "Alice")
    }
    
    func testUpdateLastName_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.lastName("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyLastName)
        }
    }

    func testUpdateLastName() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)

        // When
        try builder.lastName("Batman").save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(updatedUser.lastName, "Batman")
    }

    func testUpdateEmail_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.email("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyEmail)
        }
    }

    func testUpdateEmail() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)

        // When
        try builder.email("Autremail@test.com").save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(updatedUser.email, "Autremail@test.com")
    }
    func testUpdateSalt() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let oldSalt = user.salt
        
        // When
        try builder.salt().save()

        // Then
        XCTAssertNotEqual(user.salt, oldSalt)
    }

    func testUpdatePassword_emptyString_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        
        // Then
        XCTAssertThrowsError(
            try builder.password("").save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .emptyPassword)
        }
    }

    func testUpdatePassword() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)

        // When
        try builder.password("NewPassword").save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(updatedUser.hashPassword, "NewPassword")
    }

    func testUpdateCalorieGoal_nullValue_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomNegative: Int = Int.random(in: -1000...0)
        
        // Then
        XCTAssertThrowsError(
            try builder.calorieGoal(randomNegative).save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .nullCalorieGoal)
        }
    }

    func testUpdateCalorieGoal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomCalorieGoal: Int = Int.random(in: 1...3000)
        // When
        try builder.calorieGoal(randomCalorieGoal).save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(Int(updatedUser.calorieGoal), randomCalorieGoal)
    }
    
    func testUpdateSleepGoal_nullOrNegativeValue_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomNegative: Int = Int.random(in: -1000...0)
        
        // Then
        XCTAssertThrowsError(
            try builder.sleepGoal(randomNegative).save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .nullSleepGoal)
        }
    }

    func testUpdateSleepGoal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomCalorieGoal: Int = Int.random(in: 1...3000)
        // When
        try builder.sleepGoal(randomCalorieGoal).save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(Int(updatedUser.sleepGoal), randomCalorieGoal)
    }

    func testUpdateWaterGoal_nullOrNegativeValue_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomNegative: Int = Int.random(in: -1000...0)
        
        // Then
        XCTAssertThrowsError(
            try builder.waterGoal(randomNegative).save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .nullWaterGoal)
        }
    }

    func testUpdateWaterGoal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomCalorieGoal: Int = Int.random(in: 1...3000)
        // When
        try builder.waterGoal(randomCalorieGoal).save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(Int(updatedUser.waterGoal), randomCalorieGoal)
    }
    
    func testUpdateWaterGoal_nullValue_throwError() throws {
        // Given / When
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomNegative: Int = Int.random(in: -1000...0)
        
        // Then
        XCTAssertThrowsError(
            try builder.waterGoal(randomNegative).save()
        ) { error in
            guard let userError = error as? UserUpdateBuilderError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(userError, .nullWaterGoal)
        }
    }

    func testUpdateWeight() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let randomCalorieGoal: Int = Int.random(in: 1...3000)
        // When
        try builder.waterGoal(randomCalorieGoal).save()

        // Then
        let updatedUser = try manager.fetchUser(by: user.id)
        XCTAssertEqual(Int(updatedUser.waterGoal), randomCalorieGoal)
    }
    
    func testUpdate_allvalues_success() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        let builder = UserUpdateBuilder(user: user, dataManager: manager)
        let oldId = user.id
        let oldSalt = user.salt
        
        // When
        try builder.firstName("Selina")
            .lastName("Kyle")
            .email("catwoman@test.com")
            .password("newPassword")
            .salt()
            .isLogged(true)
            .calorieGoal(1000)
            .sleepGoal(800)
            .waterGoal(10)
            .save()
        
        // Then
        XCTAssertEqual(user.email, "catwoman@test.com")
        XCTAssertEqual(user.hashPassword, "newPassword")
        XCTAssertEqual(user.firstName, "Selina")
        XCTAssertEqual(user.lastName, "Kyle")
        XCTAssertEqual(user.id, oldId)
        XCTAssertNotEqual(oldSalt,user.salt)
        XCTAssertTrue(user.isLogged)
        XCTAssertEqual(user.calorieGoal, 1000)
        XCTAssertEqual(user.sleepGoal, 800)
        XCTAssertEqual(user.waterGoal, 10)
    }
}
