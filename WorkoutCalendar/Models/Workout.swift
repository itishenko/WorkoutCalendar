//
//  Workout.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import Foundation

// MARK: - Workout List Response
struct WorkoutListResponse: Codable {
    let description: String
    let data: [Workout]
}

// MARK: - Workout
struct Workout: Codable, Identifiable {
    let workoutKey: String
    let workoutActivityType: String
    let workoutStartDate: String
    
    var id: String { workoutKey }
    
    var startDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: workoutStartDate)
    }
}

// MARK: - Metadata Response
struct MetadataResponse: Codable {
    let description: String
    let workouts: [String: WorkoutMetadata]
}

// MARK: - Workout Metadata
struct WorkoutMetadata: Codable {
    let workoutKey: String
    let workoutActivityType: String
    let workoutStartDate: String
    let distance: String
    let duration: String
    let maxLayer: Int
    let maxSubLayer: Int
    let avg_humidity: String
    let avg_temp: String
    let comment: String
    let photoBefore: String?
    let photoAfter: String?
    let heartRateGraph: String?
    let activityGraph: String?
    let map: String?
    
    var startDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: workoutStartDate)
    }
    
    var formattedDistance: String {
        if let dist = Double(distance), dist > 0 {
            if dist >= 1000 {
                return String(format: "%.2f км", dist / 1000)
            } else {
                return String(format: "%.0f м", dist)
            }
        }
        return "—"
    }
    
    var formattedDuration: String {
        guard let dur = Double(duration) else { return "—" }
        let hours = Int(dur) / 3600
        let minutes = (Int(dur) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dч %dмин", hours, minutes)
        } else {
            return String(format: "%dмин", minutes)
        }
    }
}

// MARK: - Diagram Data Response
struct DiagramDataResponse: Codable {
    let description: String
    let workouts: [String: DiagramData]
}

// MARK: - Diagram Data
struct DiagramData: Codable {
    let description: String
    let data: [DataPoint]
    let states: [String]
}

// MARK: - Data Point
struct DataPoint: Codable {
    let time_numeric: Int
    let heartRate: Int
    let speed_kmh: Double
    let distanceMeters: Int
    let steps: Int
    let elevation: Double
    let latitude: Double
    let longitude: Double
    let temperatureCelsius: Double
    let currentLayer: Int
    let currentSubLayer: Int
    let currentTimestamp: String
}

// MARK: - Activity Type Localization
extension String {
    var localizedActivityType: String {
        switch self {
        case "Walking/Running":
            return "Бег/ходьба"
        case "Yoga":
            return "Йога"
        case "Water":
            return "Водные процедуры"
        case "Cycling":
            return "Велоспорт"
        case "Strength":
            return "Силовые тренировки"
        default:
            return self
        }
    }
}
