//
//  CalendarViewModelTests.swift
//  WorkoutCalendarTests
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import XCTest
@testable import WorkoutCalendar

@MainActor
final class CalendarViewModelTests: XCTestCase {
    
    var sut: CalendarViewModel!
    var mockService: MockWorkoutService!
    
    override func setUp() {
        super.setUp()
        mockService = MockWorkoutService()
        sut = CalendarViewModel(workoutService: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Month Navigation
    
    func testMoveToNextMonth() {
        // Given
        let calendar = Calendar.current
        let initialMonth = sut.currentMonth
        
        // When
        sut.moveToNextMonth()
        
        // Then
        let expectedMonth = calendar.date(byAdding: .month, value: 1, to: initialMonth)!
        let actualMonth = sut.currentMonth
        
        XCTAssertEqual(
            calendar.component(.month, from: actualMonth),
            calendar.component(.month, from: expectedMonth),
            "Should move to next month"
        )
        XCTAssertEqual(
            calendar.component(.year, from: actualMonth),
            calendar.component(.year, from: expectedMonth),
            "Year should be correct after moving to next month"
        )
    }
    
    func testMoveToPreviousMonth() {
        // Given
        let calendar = Calendar.current
        let initialMonth = sut.currentMonth
        
        // When
        sut.moveToPreviousMonth()
        
        // Then
        let expectedMonth = calendar.date(byAdding: .month, value: -1, to: initialMonth)!
        let actualMonth = sut.currentMonth
        
        XCTAssertEqual(
            calendar.component(.month, from: actualMonth),
            calendar.component(.month, from: expectedMonth),
            "Should move to previous month"
        )
        XCTAssertEqual(
            calendar.component(.year, from: actualMonth),
            calendar.component(.year, from: expectedMonth),
            "Year should be correct after moving to previous month"
        )
    }
    
    func testMoveMultipleMonths() {
        // Given
        let calendar = Calendar.current
        let initialMonth = sut.currentMonth
        
        // When
        sut.moveToNextMonth()
        sut.moveToNextMonth()
        sut.moveToPreviousMonth()
        
        // Then
        let expectedMonth = calendar.date(byAdding: .month, value: 1, to: initialMonth)!
        let actualMonth = sut.currentMonth
        
        XCTAssertEqual(
            calendar.component(.month, from: actualMonth),
            calendar.component(.month, from: expectedMonth),
            "Should correctly handle multiple month changes"
        )
    }
    
    // MARK: - Test Date Selection
    
    func testSelectDate() {
        // Given
        let testDate = Date()
        
        // When
        sut.selectDate(testDate)
        
        // Then
        XCTAssertTrue(
            Calendar.current.isDate(sut.selectedDate, inSameDayAs: testDate),
            "Selected date should match the test date"
        )
    }
    
    func testIsToday() {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // When/Then
        XCTAssertTrue(sut.isToday(today), "Today's date should return true")
        XCTAssertFalse(sut.isToday(yesterday), "Yesterday's date should return false")
        XCTAssertFalse(sut.isToday(nil), "Nil date should return false")
    }
    
    func testIsSelected() {
        // Given
        let testDate = Date()
        sut.selectDate(testDate)
        let otherDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        
        // When/Then
        XCTAssertTrue(sut.isSelected(testDate), "Selected date should return true")
        XCTAssertFalse(sut.isSelected(otherDate), "Non-selected date should return false")
        XCTAssertFalse(sut.isSelected(nil), "Nil date should return false")
    }
    
    // MARK: - Test Event Filtering
    
    func testFilterWorkoutsByDay() async {
        // Given
        mockService.mockWorkouts = [
            createMockWorkout(key: "1", date: "2025-11-25 09:30:00"),
            createMockWorkout(key: "2", date: "2025-11-25 18:00:00"),
            createMockWorkout(key: "3", date: "2025-11-24 07:15:00")
        ]
        
        await sut.loadData()
        
        // When
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let testDate = formatter.date(from: "2025-11-25 12:00:00")!
        sut.selectDate(testDate)
        
        // Then
        XCTAssertEqual(sut.eventsForSelectedDate.count, 2, "Should find 2 events on 2025-11-25")
        XCTAssertTrue(sut.eventsForSelectedDate.contains { $0.workoutKey == "1" })
        XCTAssertTrue(sut.eventsForSelectedDate.contains { $0.workoutKey == "2" })
    }
    
    func testHasEvents() async {
        // Given
        mockService.mockWorkouts = [
            createMockWorkout(key: "1", date: "2025-11-25 09:30:00")
        ]
        
        await sut.loadData()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateWithEvents = formatter.date(from: "2025-11-25 12:00:00")!
        let dateWithoutEvents = formatter.date(from: "2025-11-26 12:00:00")!
        
        // When/Then
        XCTAssertTrue(sut.hasEvents(dateWithEvents), "Date with events should return true")
        XCTAssertFalse(sut.hasEvents(dateWithoutEvents), "Date without events should return false")
        XCTAssertFalse(sut.hasEvents(nil), "Nil date should return false")
    }
    
    func testEmptyEventsForSelectedDate() async {
        // Given
        mockService.mockWorkouts = []
        await sut.loadData()
        
        // When
        let result = sut.eventsForSelectedDate
        
        // Then
        XCTAssertTrue(result.isEmpty, "Should return empty array when no workouts exist")
    }
    
    // MARK: - Test Data Loading
    
    func testLoadDataSuccess() async {
        // Given
        mockService.mockWorkouts = [
            createMockWorkout(key: "1", date: "2025-11-25 09:30:00")
        ]
        mockService.mockMetadata = [
            "1": createMockMetadata(key: "1")
        ]
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNil(sut.errorMessage, "Should not have error message")
        XCTAssertEqual(sut.workouts.count, 1, "Should load 1 workout")
        XCTAssertEqual(sut.metadata.count, 1, "Should load 1 metadata")
    }
    
    func testLoadDataFailure() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        XCTAssertTrue(sut.workouts.isEmpty, "Should have no workouts on error")
    }
    
    // MARK: - Test Month Year Formatting
    
    func testMonthYearString() {
        // Given
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 1
        
        let testDate = calendar.date(from: components)!
        sut.currentMonth = testDate
        
        // When
        let result = sut.monthYearString
        
        // Then
        XCTAssertTrue(result.contains("2025"), "Should contain year")
        XCTAssertTrue(result.lowercased().contains("ноябрь") || result.lowercased().contains("november"), 
                     "Should contain month name")
    }
    
    // MARK: - Test Days in Month Generation
    
    func testDaysInMonthCount() {
        // Given
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 1
        
        let testDate = calendar.date(from: components)!
        sut.currentMonth = testDate
        
        // When
        let days = sut.daysInMonth
        
        // Then
        XCTAssertFalse(days.isEmpty, "Should generate days")
        XCTAssertTrue(days.count % 7 == 0, "Days array should be multiple of 7 (weeks)")
        
        // Count non-nil days (actual days in November 2025 = 30)
        let actualDays = days.compactMap { $0 }.count
        XCTAssertEqual(actualDays, 30, "November 2025 should have 30 days")
    }
    
    func testDaysInMonthStartsOnCorrectWeekday() {
        // Given - November 2025 starts on Saturday
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 1
        
        let testDate = calendar.date(from: components)!
        sut.currentMonth = testDate
        
        // When
        let days = sut.daysInMonth
        
        // Then
        let firstNonNilIndex = days.firstIndex(where: { $0 != nil })!
        
        // November 1, 2025 is Saturday (6th day if Monday is 1st)
        XCTAssertEqual(firstNonNilIndex, 5, "November 1, 2025 (Saturday) should be at index 5 when week starts on Monday")
    }
    
    // MARK: - Helper Methods
    
    private func createMockWorkout(key: String, date: String) -> Workout {
        Workout(
            workoutKey: key,
            workoutActivityType: "Walking/Running",
            workoutStartDate: date
        )
    }
    
    private func createMockMetadata(key: String) -> WorkoutMetadata {
        WorkoutMetadata(
            workoutKey: key,
            workoutActivityType: "Walking/Running",
            workoutStartDate: "2025-11-25 09:30:00",
            distance: "5000.0",
            duration: "3600.0",
            maxLayer: 2,
            maxSubLayer: 4,
            avg_humidity: "65.0",
            avg_temp: "12.5",
            comment: "Test workout",
            photoBefore: nil,
            photoAfter: nil,
            heartRateGraph: nil,
            activityGraph: nil,
            map: nil
        )
    }
}

// MARK: - Mock Service

class MockWorkoutService: WorkoutServiceProtocol {
    var mockWorkouts: [Workout] = []
    var mockMetadata: [String: WorkoutMetadata] = [:]
    var shouldThrowError = false
    
    func fetchWorkouts() async throws -> [Workout] {
        if shouldThrowError {
            throw WorkoutServiceError.fileNotFound
        }
        return mockWorkouts
    }
    
    func fetchMetadata(for workoutKey: String) async throws -> WorkoutMetadata? {
        if shouldThrowError {
            throw WorkoutServiceError.fileNotFound
        }
        return mockMetadata[workoutKey]
    }
    
    func fetchAllMetadata() async throws -> [String: WorkoutMetadata] {
        if shouldThrowError {
            throw WorkoutServiceError.fileNotFound
        }
        return mockMetadata
    }
}


