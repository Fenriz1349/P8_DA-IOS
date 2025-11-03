//
//  ExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 26/10/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class ExerciseViewModelTests: XCTestCase {

    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: ExerciceDataManager!
    var coordinator: AppCoordinator!
    var spyToastyManager: SpyToastyManager!
    var sut: ExerciseViewModel!

    override func setUp() {
        super.setUp()
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        dataManager = ExerciceDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: UserDataManager(container: testContainer.container))
        coordinator.userDefaults = UserDefaults(suiteName: "com.arista.tests")!
        spyToastyManager = ToastyTestHelpers.createSpyManager()

        let user = SharedTestHelper.createSampleUser(in: context)
        try! context.save()
        try! coordinator.login(id: user.id)

        sut = try! ExerciseViewModel(appCoordinator: coordinator, dataManager: dataManager)
        sut.configureToasty(toastyManager: spyToastyManager)
    }

    override func tearDown() {
        sut = nil
        spyToastyManager = nil
        coordinator = nil
        dataManager = nil
        testContainer = nil
        UserDefaults(suiteName: "com.arista.tests")?.removePersistentDomain(forName: "com.arista.tests")
        super.tearDown()
    }

    /// Initialization Tests
    func test_init_withLoggedUser_setsUpCorrectly() throws {
        // Given / When / Then
        XCTAssertNotNil(sut.currentUser)
        XCTAssertTrue(sut.exercices.isEmpty)
        XCTAssertFalse(sut.showEditModal)
        XCTAssertEqual(sut.validationState, .neutral)
    }

    func test_init_withNoLoggedUser_throwsError() throws {
        // Given
        coordinator.currentUser = nil

        // When / Then
        XCTAssertThrowsError(try ExerciseViewModel(appCoordinator: coordinator, dataManager: dataManager)) { error in
            XCTAssertEqual(error as? UserDataManagerError, .noLoggedUser)
        }
    }

    /// Validation Tests
    func test_validateData_withValidData_setsValid() {
        // Given
        sut.duration = 30
        sut.intensity = 5
        
        // When
        sut.validateData()
        
        // Then
        XCTAssertEqual(sut.validationState, .valid)
    }
    
    func test_validateData_withInvalidDuration_setsInvalid() {
        // Given
        sut.duration = -10
        sut.intensity = 5
        
        // When
        sut.validateData()
        
        // Then
        XCTAssertEqual(sut.validationState, .invalid)
    }
    
    func test_validateData_withInvalidIntensity_setsInvalid() {
        // Given
        sut.duration = 30
        sut.intensity = 11
        
        // When
        sut.validateData()
        
        // Then
        XCTAssertEqual(sut.validationState, .invalid)
    }
    
    func test_resetValidation_setsNeutral() {
        // Given
        sut.validationState = .invalid
        
        // When
        sut.resetValidation()
        
        // Then
        XCTAssertEqual(sut.validationState, .neutral)
    }

    /// Reload
    func test_reloadAll_loadsExercisesForCurrentUser() throws {
        // Given
        SharedTestHelper.createSampleExercice(for: sut.currentUser, in: context)
        SharedTestHelper.createSampleExercice(for: sut.currentUser, in: context)
        try context.save()

        // When
        sut.reloadAll()

        // Then
        XCTAssertFalse(sut.exercices.isEmpty)
        XCTAssertNil(sut.lastError)
    }

    func test_reloadAll_whenFetchFails_setsLastError() {
        // Given
        let brokenContainer = NSPersistentContainer(name: "InvalidContainer")
        let brokenManager = ExerciceDataManager(container: brokenContainer)
        let brokenVM = try! ExerciseViewModel(appCoordinator: coordinator, dataManager: brokenManager)

        // When
        brokenVM.reloadAll()

        // Then
        XCTAssertNotNil(brokenVM.lastError)
    }

    /// Save
    func test_saveExercise_withValidData_createsNewExercise() throws {
        // Given
        sut.selectedExercice = nil
        sut.selectedType = .running
        sut.duration = 45
        sut.intensity = 6

        // When
        sut.saveExercise()

        // Then
        let exercices = try dataManager.fetchExercices(for: sut.currentUser)
        XCTAssertEqual(exercices.count, 1)
        XCTAssertEqual(exercices.first?.type, ExerciceType.running.rawValue)
        XCTAssertFalse(sut.showEditModal)
        XCTAssertEqual(sut.validationState, .neutral)
    }

    func test_saveExercise_updatesExistingExercise() throws {
        // Given
        let exercice = try dataManager.createExercice(for: sut.currentUser, duration: 30, type: .cycling, intensity: 5)
        sut.selectedExercice = exercice.toDisplay
        sut.duration = 60
        sut.intensity = 8
        sut.selectedType = .yoga

        // When
        sut.saveExercise()

        // Then
        let updated = try dataManager.fetchExercices(for: sut.currentUser).first
        XCTAssertEqual(updated?.duration, 60)
        XCTAssertEqual(updated?.intensity, 8)
        XCTAssertEqual(updated?.type, ExerciceType.yoga.rawValue)
        XCTAssertFalse(sut.showEditModal)
    }

    func test_saveExercise_withInvalidData_doesNotSave() throws {
        // Given
        sut.duration = -10
        sut.intensity = 15
        sut.selectedExercice = nil
        let initialCount = try dataManager.fetchExercices(for: sut.currentUser).count

        // When
        sut.saveExercise()

        // Then
        let finalCount = try dataManager.fetchExercices(for: sut.currentUser).count
        XCTAssertEqual(finalCount, initialCount)
        XCTAssertEqual(sut.validationState, .invalid)
    }

    /// Delete
    func test_deleteExercise_removesFromStore() throws {
        // Given
        let exercice = try dataManager.createExercice(for: sut.currentUser)
        sut.reloadAll()
        XCTAssertEqual(sut.exercices.count, 1)

        // When
        sut.deleteExercise(exercice.toDisplay)

        // Then
        let all = try dataManager.fetchExercices(for: sut.currentUser)
        XCTAssertTrue(all.isEmpty)
    }

    func test_deleteExercise_withInvalidId_setsError() {
        // Given
        XCTAssertNotNil(sut.currentUser)
        let fake = ExerciceDisplay(
            id: UUID(),
            date: Date(),
            duration: 30,
            intensity: 5,
            type: .running
        )

        // When
        sut.deleteExercise(fake)

        // Then
        XCTAssertNotNil(sut.lastError)
    }

    /// Modal
    func test_openEditModal_withExistingExercise_populatesFields() throws {
        // Given
        let exercice = try dataManager.createExercice(for: sut.currentUser, duration: 30, type: .yoga, intensity: 8)

        // When
        sut.openEditModal(for: exercice.toDisplay)

        // Then
        XCTAssertTrue(sut.showEditModal)
        XCTAssertEqual(sut.duration, 30)
        XCTAssertEqual(sut.intensity, 8)
        XCTAssertEqual(sut.selectedType, .yoga)
        XCTAssertEqual(sut.validationState, .neutral)
    }

    func test_openEditModal_withoutExercise_resetsFields() {
        // Given
        sut.lastSelectedType = .running
        
        // When
        sut.openEditModal(for: nil)

        // Then
        XCTAssertTrue(sut.showEditModal)
        XCTAssertEqual(sut.duration, 30)
        XCTAssertEqual(sut.intensity, 5)
        XCTAssertEqual(sut.selectedType, .running)
        XCTAssertEqual(sut.validationState, .neutral)
    }

    /// Toasty Configuration
    func test_configureToasty_setsManagerCorrectly() {
        // Given / When
        sut.configureToasty(toastyManager: spyToastyManager)

        // Then
        XCTAssertNotNil(sut.toastyManager)
        XCTAssertTrue(sut.toastyManager === spyToastyManager)
    }
    
    /// CaloriesBurned
    func test_caloriesBurned_calculatesCorrectly() {
        // Given
        sut.duration = 60
        sut.intensity = 7
        sut.selectedType = .running // calorieFactor = 1.0
        
        // When
        let calories = sut.caloriesBurned
        
        // Then
        XCTAssertEqual(calories, "630 kcal")
    }
}
