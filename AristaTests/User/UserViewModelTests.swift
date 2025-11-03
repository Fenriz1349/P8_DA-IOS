//
//  UserViewModelTests.swift
//  AristaTests
//
//  Created by Julien Cotte on 12/09/2025.
//

import XCTest
import CoreData
@testable import Arista

@MainActor
final class UserViewModelTests: XCTestCase {
    var testContainer: PersistenceController!
    var context: NSManagedObjectContext!
    var dataManager: UserDataManager!
    var goalDataManager: GoalDataManager!
    var coordinator: AppCoordinator!

    override func setUp() {
        super.setUp()
        testContainer = SharedTestHelper.createTestContainer()
        context = testContainer.container.viewContext
        dataManager = UserDataManager(container: testContainer.container)
        goalDataManager = GoalDataManager(container: testContainer.container)
        coordinator = AppCoordinator(dataManager: dataManager)
        coordinator.userDefaults = UserDefaults(suiteName: "com.arista.tests")!
    }

    override func tearDown() {
        testContainer = nil
        context = nil
        dataManager = nil
        goalDataManager = nil
        coordinator = nil
        UserDefaults(suiteName: "com.arista.tests")?.removePersistentDomain(forName: "com.arista.tests")
        super.tearDown()
    }

    func test_init_withLoggedUser_loadsUserDataCorrectly() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)

        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // Then
        XCTAssertEqual(sut.user.firstName, user.firstName)
        XCTAssertEqual(sut.user.lastName, user.lastName)
        XCTAssertFalse(sut.showEditModal)
        XCTAssertFalse(sut.showingResetAlert)
    }

    func test_init_withDemoUser_shouldNotThrow_andBindDemoUser() throws {
        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // Then
        XCTAssertEqual(sut.user.email, AppCoordinator.demoEmail)
    }

    func test_openAndCloseEditModal_shouldToggleShowEditModal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // When
        sut.openEditModal()
        XCTAssertTrue(sut.showEditModal)

        // Then
        sut.closeEditModal()
        XCTAssertFalse(sut.showEditModal)
    }

    func test_logout_shouldClearCurrentUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        XCTAssertTrue(coordinator.isAuthenticated)

        // When
        sut.logout()

        // Then
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_deleteAccount_shouldRemoveUser() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        XCTAssertTrue(coordinator.isAuthenticated)

        // When
        sut.deleteAccount()

        // Then
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(coordinator.currentUser)
    }

    func test_loadUserForEditing_shouldUpdatePublishedProperties() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        // When
        sut.loadUserForEditing()

        // Then
        XCTAssertEqual(sut.firstName, user.firstName)
        XCTAssertEqual(sut.lastName, user.lastName)
        XCTAssertEqual(sut.calorieGoal, Int(user.calorieGoal))
        XCTAssertEqual(sut.sleepGoal, Int(user.sleepGoal))
        XCTAssertEqual(sut.waterGoal, Int(user.waterGoal))
        XCTAssertEqual(sut.stepsGoal, Int(user.stepsGoal))
    }

    func test_saveChanges_shouldUpdateUserData() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        sut.loadUserForEditing()
        sut.firstName = "Alex"
        sut.lastName = "Dupont"
        sut.calorieGoal = 2500
        sut.sleepGoal = 500
        sut.waterGoal = 30

        // When
        sut.saveChanges()

        // Then
        XCTAssertEqual(user.firstName, "Alex")
        XCTAssertEqual(user.lastName, "Dupont")
        XCTAssertEqual(user.calorieGoal, 2500)
        XCTAssertEqual(user.sleepGoal, 500)
        XCTAssertEqual(user.waterGoal, 30)
        XCTAssertFalse(sut.showEditModal)
    }

    func test_saveChanges_withInvalidData_shouldShowError() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)

        sut.firstName = ""
        sut.lastName = ""

        let fakeToasty = ToastyManager()
        sut.configureToasty(toastyManager: fakeToasty)

        // When
        sut.saveChanges()

        // Then
        XCTAssertNotNil(sut.toastyManager)
    }
    
    // MARK: - Goal Tests
    
    func test_loadTodayGoal_shouldLoadExistingGoal() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        _ = try goalDataManager.updateWater(for: user, newWater: 15)
        _ = try goalDataManager.updateSteps(for: user, newSteps: 5000)
        
        // When
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // Then
        XCTAssertEqual(sut.currentWater, 15)
        XCTAssertEqual(sut.currentSteps, 5000)
    }
    
    func test_updateWater_shouldSaveToGoalDataManager() async throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        sut.currentWater = 20
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        let goal = try goalDataManager.fetchGoal(for: user)
        XCTAssertEqual(goal?.totalWater, 20)
    }
    
    func test_updateSteps_shouldSaveToGoalDataManager() async throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        sut.currentSteps = 8000
        
        // Give time for Task to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        let goal = try goalDataManager.fetchGoal(for: user)
        XCTAssertEqual(goal?.totalSteps, 8000)
    }
    
    // MARK: - Display Properties Tests
    
    func test_userDisplay_shouldReturnCorrectDisplay() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let display = sut.userDisplay
        
        // Then
        XCTAssertEqual(display.firstName, user.firstName)
        XCTAssertEqual(display.lastName, user.lastName)
        XCTAssertEqual(display.email, user.email)
    }
    
    func test_todayCalories_withGoal_shouldReturnTotalCalories() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // Create a goal with steps (steps generate calories: totalSteps * 0.04)
        let goal = Goal(context: context)
        goal.id = UUID()
        goal.date = Date()
        goal.totalSteps = 10000
        goal.totalWater = 0
        goal.user = user
        
        // Add an exercise to the user (exercises contribute to calories)
        let exercise = Exercice(context: context)
        exercise.id = UUID()
        exercise.date = Date()
        exercise.duration = 30
        exercise.type = "running"
        exercise.user = user
        
        try context.save()
        
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let calories = sut.todayCalories
        
        // Then
        XCTAssertEqual(calories, 400)
    }
    
    func test_todayCalories_withoutGoal_shouldReturnZero() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let calories = sut.todayCalories
        
        // Then
        XCTAssertEqual(calories, 0)
    }
    
    func test_lastSevenDaysCalories_shouldReturnSevenDays() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        // Create goals for the last 3 days with steps
        let calendar = Calendar.current
        for offset in 0..<3 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let goal = Goal(context: context)
                goal.id = UUID()
                goal.date = calendar.startOfDay(for: date)
                goal.totalSteps = Int32(5000 + offset * 1000) // Steps will be converted to calories
                goal.totalWater = 0
                goal.user = user
            }
        }
        try context.save()
        
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let days = sut.lastSevenDaysCalories
        
        // Then
        XCTAssertEqual(days.count, 7)
        // Days with goals should have calories > 0
        // Days without goals should have 0 calories
        let daysWithCalories = days.filter { $0.calories > 0 }
        XCTAssertEqual(daysWithCalories.count, 3)
    }
    
    // MARK: - Sleep Metrics Tests
    
    func test_loadSleepData_shouldPopulateCachedCycles() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        
        // Create a completed sleep cycle
        let startDate = Date().addingTimeInterval(-8 * 3600)
        let endDate = Date()
        _ = try sleepManager.startSleepCycle(for: user, startDate: startDate)
        _ = try sleepManager.endSleepCycle(for: user, endDate: endDate, quality: 8)
        
        // When
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // Then
        XCTAssertEqual(sut.cachedSleepCycles.count, 1)
        XCTAssertEqual(sut.cachedSleepCycles.first?.quality, 8)
    }
    
    func test_lastWeekSleepCycles_shouldReturnCachedCycles() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        _ = try sleepManager.startSleepCycle(for: user)
        _ = try sleepManager.endSleepCycle(for: user, quality: 7)
        
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // When
        let cycles = sut.lastWeekSleepCycles
        
        // Then
        XCTAssertEqual(cycles.count, 1)
    }
    
    func test_averageSleepDuration_withCompletedCycles_shouldCalculateAverage() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        
        // Create two 8-hour sleep cycles
        for _ in 0..<2 {
            let start = Date().addingTimeInterval(-16 * 3600)
            let end = start.addingTimeInterval(8 * 3600)
            _ = try sleepManager.startSleepCycle(for: user, startDate: start)
            _ = try sleepManager.endSleepCycle(for: user, endDate: end, quality: 7)
        }
        
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // When
        let average = sut.averageSleepDuration
        
        // Then
        XCTAssertEqual(average, 8 * 3600, accuracy: 1) // 8 hours ± 1 second
    }
    
    func test_averageSleepDuration_withNoCycles_shouldReturnZero() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let average = sut.averageSleepDuration
        
        // Then
        XCTAssertEqual(average, 0)
    }
    
    func test_averageSleepQuality_withCompletedCycles_shouldCalculateAverage() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        
        // Create cycles with quality 6, 8, 10
        for quality in [6, 8, 10] {
            let start = Date().addingTimeInterval(-16 * 3600)
            let end = start.addingTimeInterval(8 * 3600)
            _ = try sleepManager.startSleepCycle(for: user, startDate: start)
            _ = try sleepManager.endSleepCycle(for: user, endDate: end, quality: quality)
        }
        
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // When
        let average = sut.averageSleepQuality
        
        // Then
        XCTAssertEqual(average, 8.0, accuracy: 0.1) // (6+8+10)/3 = 8
    }
    
    func test_averageSleepQuality_withNoCycles_shouldReturnZero() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // When
        let average = sut.averageSleepQuality
        
        // Then
        XCTAssertEqual(average, 0)
    }
    
    func test_sleepMetrics_shouldReturnCorrectMetrics() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        user.sleepGoal = 480 // 8 hours
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        let start = Date().addingTimeInterval(-8 * 3600)
        let end = Date()
        _ = try sleepManager.startSleepCycle(for: user, startDate: start)
        _ = try sleepManager.endSleepCycle(for: user, endDate: end, quality: 9)
        
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // When
        let metrics = sut.sleepMetrics
        
        // Then
        XCTAssertEqual(metrics.sleepGoal, 480)
        XCTAssertEqual(metrics.averageQuality, 9.0)
        XCTAssertGreaterThan(metrics.averageDuration, 0)
    }
    
    // MARK: - Refresh Tests
    
    func test_refreshData_shouldReloadAllData() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        
        let sleepManager = SleepDataManager(container: testContainer.container)
        let sut = try UserViewModel(
            appCoordinator: coordinator,
            goalDataManager: goalDataManager,
            sleepDataManager: sleepManager
        )
        
        // Add new data after init
        _ = try goalDataManager.updateWater(for: user, newWater: 25)
        _ = try sleepManager.startSleepCycle(for: user)
        _ = try sleepManager.endSleepCycle(for: user, quality: 7)
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertEqual(sut.currentWater, 25)
        XCTAssertEqual(sut.cachedSleepCycles.count, 1)
    }
    
    // MARK: - ToastyManager Tests
    
    func test_configureToasty_shouldSetToastyManager() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        let toasty = ToastyManager()
        
        // When
        sut.configureToasty(toastyManager: toasty)
        
        // Then
        XCTAssertNotNil(sut.toastyManager)
    }
    
    // MARK: - Alert Message Test
    
    func test_alertMessage_shouldNotBeEmpty() throws {
        // Given
        let user = SharedTestHelper.createSampleUser(in: context)
        try context.save()
        try coordinator.login(id: user.id)
        let sut = try UserViewModel(appCoordinator: coordinator, goalDataManager: goalDataManager)
        
        // Then
        XCTAssertFalse(sut.alertMessage.isEmpty)
    }
}
