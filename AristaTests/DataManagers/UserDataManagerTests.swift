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
    
    func testFetchUser_withoutExistingUser_returnNil() throws {
        // Given
        
        SharedTestHelper.createUsers(count: 10, in: context)
        try context.save()
        let testUUID: UUID = UUID()
        
        XCTAssertNil(try? manager.fetchUser(by: testUUID))
    }

    func testNoUserLogged_shouldReturnTrue() throws {
        // Given
        
        // When
        let user = SharedTestHelper.createSampleUser(in: context)
        let user2 = SharedTestHelper.createSampleUser2(in: context)
        try context.save()
        
        // Then
        XCTAssertTrue(manager.noUserLogged)
    }
    
    func testNoUserLogged_shouldReturnFalse() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        
        // When
        try manager.updateUserIsLogged(id: user.id!, isLogged: true)
        // Then
        XCTAssertFalse(manager.noUserLogged)
    }
    
//    func testFetchLoggedUser_returnsTheLoggedUser() throws {
//        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)
//
//        // Crée deux utilisateurs
//        let user1 = try manager.createUser(email: "john@test.com", password: "Password123!", firstName: "John", lastName: "Cena")
//        let user2 = try manager.createUser(email: "jane@test.com", password: "Password123!", firstName: "Jane", lastName: "Cena")
//
//        // On met le user2 comme loggué
//        user2.isLogged = true
//        try manager.container.viewContext.save()
//
//        // Récupère le user loggué
//        let loggedUser = try manager.fetchLoggedUser()
//
//        XCTAssertNotNil(loggedUser)
//        XCTAssertEqual(loggedUser?.id, user2.id)
//    }
    
    // MARK: - Update User Methods
    
    func testUpdateUserIsLogged_NoUser_shouldThrowError() throws {
        // Given / When
        SharedTestHelper.createUsers(count: 20, in: context)
        try context.save()
        let testUserId: UUID = UUID()
        
        // Then
        XCTAssertThrowsError(
               try manager.updateUserIsLogged(id: testUserId, isLogged: true)
           ) { error in
               XCTAssertEqual(error as? UserDataManagerError, .userNotFound)
           }
    }
    
    func testUpdateUserIsLogged_WithUser_ValueIsChanged() throws {
        // When
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        XCTAssertFalse(user.isLogged)
        try manager.updateUserIsLogged(id: user.id!, isLogged: true)
        XCTAssertTrue(user.isLogged)
    }
}
