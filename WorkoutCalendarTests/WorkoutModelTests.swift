//
//  WorkoutModelTests.swift
//  WorkoutCalendarTests
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import XCTest
@testable import WorkoutCalendar

final class WorkoutModelTests: XCTestCase {
    
    // MARK: - Test Workout Date Parsing
    
    func testWorkoutStartDateParsing() {
        // Given
        let workout = Workout(
            workoutKey: "test123",
            workoutActivityType: "Running",
            workoutStartDate: "2025-11-25 09:30:00"
        )
        
        // When
        let date = workout.startDate
        
        // Then
        XCTAssertNotNil(date, "Should parse valid date string")
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 11)
        XCTAssertEqual(components.day, 25)
        XCTAssertEqual(components.hour, 9)
        XCTAssertEqual(components.minute, 30)
    }
    
    func testWorkoutInvalidDateParsing() {
        // Given
        let workout = Workout(
            workoutKey: "test123",
            workoutActivityType: "Running",
            workoutStartDate: "invalid-date"
        )
        
        // When
        let date = workout.startDate
        
        // Then
        XCTAssertNil(date, "Should return nil for invalid date string")
    }
    
    // MARK: - Test Metadata Date Parsing
    
    func testMetadataStartDateParsing() {
        // Given
        let metadata = WorkoutMetadata(
            workoutKey: "test123",
            workoutActivityType: "Running",
            workoutStartDate: "2025-11-25 09:30:00",
            distance: "5000.0",
            duration: "3600.0",
            maxLayer: 2,
            maxSubLayer: 4,
            avg_humidity: "65.0",
            avg_temp: "12.5",
            comment: "Test",
            photoBefore: nil,
            photoAfter: nil,
            heartRateGraph: nil,
            activityGraph: nil,
            map: nil
        )
        
        // When
        let date = metadata.startDate
        
        // Then
        XCTAssertNotNil(date, "Should parse valid date string")
    }
    
    // MARK: - Test Distance Formatting
    
    func testFormattedDistanceKilometers() {
        // Given
        let metadata = createMetadata(distance: "5230.50")
        
        // When
        let formatted = metadata.formattedDistance
        
        // Then
        XCTAssertTrue(formatted.contains("км"), "Should format as kilometers")
        XCTAssertTrue(formatted.contains("5.23"), "Should show correct value")
    }
    
    func testFormattedDistanceMeters() {
        // Given
        let metadata = createMetadata(distance: "800.0")
        
        // When
        let formatted = metadata.formattedDistance
        
        // Then
        XCTAssertTrue(formatted.contains("м"), "Should format as meters")
        XCTAssertTrue(formatted.contains("800"), "Should show correct value")
    }
    
    func testFormattedDistanceZero() {
        // Given
        let metadata = createMetadata(distance: "0.0")
        
        // When
        let formatted = metadata.formattedDistance
        
        // Then
        XCTAssertEqual(formatted, "—", "Should return dash for zero distance")
    }
    
    func testFormattedDistanceInvalid() {
        // Given
        let metadata = createMetadata(distance: "invalid")
        
        // When
        let formatted = metadata.formattedDistance
        
        // Then
        XCTAssertEqual(formatted, "—", "Should return dash for invalid distance")
    }
    
    // MARK: - Test Duration Formatting
    
    func testFormattedDurationHoursAndMinutes() {
        // Given
        let metadata = createMetadata(duration: "3660.0") // 1 hour 1 minute
        
        // When
        let formatted = metadata.formattedDuration
        
        // Then
        XCTAssertTrue(formatted.contains("1ч"), "Should show 1 hour")
        XCTAssertTrue(formatted.contains("1мин"), "Should show 1 minute")
    }
    
    func testFormattedDurationMinutesOnly() {
        // Given
        let metadata = createMetadata(duration: "300.0") // 5 minutes
        
        // When
        let formatted = metadata.formattedDuration
        
        // Then
        XCTAssertFalse(formatted.contains("ч"), "Should not show hours")
        XCTAssertTrue(formatted.contains("5мин"), "Should show 5 minutes")
    }
    
    func testFormattedDurationHoursOnly() {
        // Given
        let metadata = createMetadata(duration: "7200.0") // 2 hours
        
        // When
        let formatted = metadata.formattedDuration
        
        // Then
        XCTAssertTrue(formatted.contains("2ч"), "Should show 2 hours")
        XCTAssertTrue(formatted.contains("0мин"), "Should show 0 minutes")
    }
    
    func testFormattedDurationInvalid() {
        // Given
        let metadata = createMetadata(duration: "invalid")
        
        // When
        let formatted = metadata.formattedDuration
        
        // Then
        XCTAssertEqual(formatted, "—", "Should return dash for invalid duration")
    }
    
    // MARK: - Test JSON Decoding
    
    func testWorkoutListDecoding() throws {
        // Given
        let json = """
        {
            "description": "Test",
            "data": [
                {
                    "workoutKey": "123",
                    "workoutActivityType": "Running",
                    "workoutStartDate": "2025-11-25 09:30:00"
                }
            ]
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(WorkoutListResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data[0].workoutKey, "123")
        XCTAssertEqual(response.data[0].workoutActivityType, "Running")
    }
    
    func testMetadataDecoding() throws {
        // Given
        let json = """
        {
            "description": "Test",
            "workouts": {
                "123": {
                    "workoutKey": "123",
                    "workoutActivityType": "Running",
                    "workoutStartDate": "2025-11-25 09:30:00",
                    "distance": "5000.0",
                    "duration": "3600.0",
                    "maxLayer": 2,
                    "maxSubLayer": 4,
                    "avg_humidity": "65.0",
                    "avg_temp": "12.5",
                    "comment": "Test workout",
                    "photoBefore": null,
                    "photoAfter": null,
                    "heartRateGraph": null,
                    "activityGraph": null,
                    "map": null
                }
            }
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(MetadataResponse.self, from: data)
        
        // Then
        XCTAssertEqual(response.workouts.count, 1)
        XCTAssertNotNil(response.workouts["123"])
        XCTAssertEqual(response.workouts["123"]?.comment, "Test workout")
    }
    
    // MARK: - Helper Methods
    
    private func createMetadata(distance: String = "5000.0", duration: String = "3600.0") -> WorkoutMetadata {
        WorkoutMetadata(
            workoutKey: "test",
            workoutActivityType: "Running",
            workoutStartDate: "2025-11-25 09:30:00",
            distance: distance,
            duration: duration,
            maxLayer: 2,
            maxSubLayer: 4,
            avg_humidity: "65.0",
            avg_temp: "12.5",
            comment: "Test",
            photoBefore: nil,
            photoAfter: nil,
            heartRateGraph: nil,
            activityGraph: nil,
            map: nil
        )
    }
}


