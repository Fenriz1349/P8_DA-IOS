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

    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        manager = UserDataManager(container: PersistenceController(inMemory: true).container)
    }

    override func tearDown() {
        manager = nil
        context = nil
        super.tearDown()
    }

    func testCreateUser_withEmptyEmail_throwError() throws {
        // Given / When
        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)

        // Then
        XCTAssertThrowsError(
               try manager.createUser(email: "", password: "password", firstName: "", lastName: "Cena")
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
        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)

        // Then
        XCTAssertThrowsError(
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
        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)
        
        // Then
        XCTAssertThrowsError(
            try manager.createUser(email: "john.Cena@test.com", password: "password", firstName: "", lastName: "Cena")
        ) { error in
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError, got \(type(of: error))")
                return
            }
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        }
    }

    func testCreateUser_withEmptyLastName_throwError() throws {
        // Given / When
        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)

        // Then
        XCTAssertThrowsError(
               try manager.createUser(email: "john.Cena@test.com", password: "password", firstName: "John", lastName: "")
           ) { error in
               guard let urlError = error as? URLError else {
                   XCTFail("Expected URLError, got \(type(of: error))")
                   return
               }
               XCTAssertEqual(urlError.code, .cannotParseResponse)
           }
    }

    func testCreateUser_withAllDatas_doesNotThrow() throws {
        // Given / When
        let manager = UserDataManager(container: PersistenceController(inMemory: true).container)

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
}
