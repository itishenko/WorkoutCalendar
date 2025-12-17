//
//  EventDetailsViewModelTests.swift
//  WorkoutCalendarTests
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import XCTest
@testable import WorkoutCalendar

@MainActor
final class EventDetailsViewModelTests: XCTestCase {
    
    var sut: EventDetailsViewModel!
    var mockService: MockWorkoutService!
    
    override func setUp() {
        super.setUp()
        mockService = MockWorkoutService()
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Initialization
    
    func testInitialization() {
        // Given
        let workoutKey = "test123"
        
        // When
        sut = EventDetailsViewModel(workoutKey: workoutKey, workoutService: mockService)
        
        // Then
        XCTAssertEqual(sut.workoutKey, workoutKey, "Workout key should be set correctly")
        XCTAssertNil(sut.metadata, "Metadata should be nil initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
    }
    
    // MARK: - Test Data Loading
    
    func testLoadDataSuccess() async {
        // Given
        let testKey = "7823456789012345"
        let testMetadata = createMockMetadata(key: testKey)
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNil(sut.errorMessage, "Should not have error message")
        XCTAssertNotNil(sut.metadata, "Metadata should be loaded")
        XCTAssertEqual(sut.metadata?.workoutKey, testKey, "Should load correct metadata")
    }
    
    func testLoadDataNotFound() async {
        // Given
        let testKey = "nonexistent"
        mockService.mockMetadata = [:]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        XCTAssertNil(sut.metadata, "Metadata should be nil")
    }
    
    func testLoadDataFailure() async {
        // Given
        mockService.shouldThrowError = true
        sut = EventDetailsViewModel(workoutKey: "test", workoutService: mockService)
        
        // When
        await sut.loadData()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNotNil(sut.errorMessage, "Should have error message")
        XCTAssertNil(sut.metadata, "Metadata should be nil on error")
    }
    
    // MARK: - Test Computed Properties
    
    func testTitle() async {
        // Given
        let testKey = "test123"
        let testMetadata = createMockMetadata(key: testKey)
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        
        // When - Before loading
        let titleBeforeLoad = sut.title
        
        // Then
        XCTAssertEqual(titleBeforeLoad, "Тренировка", "Should return default title when metadata is nil")
        
        // When - After loading
        await sut.loadData()
        let titleAfterLoad = sut.title
        
        // Then
        XCTAssertEqual(titleAfterLoad, "Walking/Running", "Should return activity type after loading")
    }
    
    func testDateTimeString() async {
        // Given
        let testKey = "test123"
        let testMetadata = createMockMetadata(key: testKey)
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When
        let dateTimeString = sut.dateTimeString
        
        // Then
        XCTAssertNotEqual(dateTimeString, "—", "Should format date and time")
        XCTAssertTrue(dateTimeString.contains("2025"), "Should contain year")
        XCTAssertTrue(dateTimeString.contains("09:30"), "Should contain time")
    }
    
    func testDescription() async {
        // Given
        let testKey = "test123"
        let testMetadata = createMockMetadata(key: testKey, comment: "Test comment")
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When
        let description = sut.description
        
        // Then
        XCTAssertEqual(description, "Test comment", "Should return comment as description")
    }
    
    func testDistanceFormatting() async {
        // Given
        let testKey = "test123"
        
        // Test kilometers
        var testMetadata = createMockMetadata(key: testKey, distance: "5230.50")
        mockService.mockMetadata = [testKey: testMetadata]
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When/Then
        XCTAssertTrue(sut.distance.contains("км"), "Should format as kilometers")
        
        // Test meters
        testMetadata = createMockMetadata(key: testKey, distance: "500.0")
        mockService.mockMetadata = [testKey: testMetadata]
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When/Then
        XCTAssertTrue(sut.distance.contains("м"), "Should format as meters")
    }
    
    func testDurationFormatting() async {
        // Given
        let testKey = "test123"
        
        // Test hours and minutes
        var testMetadata = createMockMetadata(key: testKey, duration: "3660.0")
        mockService.mockMetadata = [testKey: testMetadata]
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When/Then
        XCTAssertTrue(sut.duration.contains("ч"), "Should format hours")
        XCTAssertTrue(sut.duration.contains("мин"), "Should format minutes")
        
        // Test only minutes
        testMetadata = createMockMetadata(key: testKey, duration: "300.0")
        mockService.mockMetadata = [testKey: testMetadata]
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When/Then
        XCTAssertFalse(sut.duration.contains("ч"), "Should not show hours when duration is less than 1 hour")
        XCTAssertTrue(sut.duration.contains("мин"), "Should show minutes")
    }
    
    func testAvgTempFormatting() async {
        // Given
        let testKey = "test123"
        let testMetadata = createMockMetadata(key: testKey, avgTemp: "12.5")
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When
        let avgTemp = sut.avgTemp
        
        // Then
        XCTAssertTrue(avgTemp.contains("12.5"), "Should format temperature")
        XCTAssertTrue(avgTemp.contains("°C"), "Should include celsius symbol")
    }
    
    func testAvgHumidityFormatting() async {
        // Given
        let testKey = "test123"
        let testMetadata = createMockMetadata(key: testKey, avgHumidity: "65.0")
        mockService.mockMetadata = [testKey: testMetadata]
        
        sut = EventDetailsViewModel(workoutKey: testKey, workoutService: mockService)
        await sut.loadData()
        
        // When
        let avgHumidity = sut.avgHumidity
        
        // Then
        XCTAssertTrue(avgHumidity.contains("65"), "Should format humidity")
        XCTAssertTrue(avgHumidity.contains("%"), "Should include percentage symbol")
    }
    
    // MARK: - Helper Methods
    
    private func createMockMetadata(
        key: String,
        distance: String = "5000.0",
        duration: String = "3600.0",
        comment: String = "Test workout",
        avgTemp: String = "12.5",
        avgHumidity: String = "65.0"
    ) -> WorkoutMetadata {
        WorkoutMetadata(
            workoutKey: key,
            workoutActivityType: "Walking/Running",
            workoutStartDate: "2025-11-25 09:30:00",
            distance: distance,
            duration: duration,
            maxLayer: 2,
            maxSubLayer: 4,
            avg_humidity: avgHumidity,
            avg_temp: avgTemp,
            comment: comment,
            photoBefore: nil,
            photoAfter: nil,
            heartRateGraph: nil,
            activityGraph: nil,
            map: nil
        )
    }
}


