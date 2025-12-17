//
//  WorkoutService.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import Foundation

protocol WorkoutServiceProtocol {
    func fetchWorkouts() async throws -> [Workout]
    func fetchMetadata(for workoutKey: String) async throws -> WorkoutMetadata?
    func fetchAllMetadata() async throws -> [String: WorkoutMetadata]
    func fetchDiagramData(for workoutKey: String) async throws -> DiagramData?
}

class WorkoutService: WorkoutServiceProtocol {
    
    // MARK: - Singleton
    static let shared = WorkoutService()
    
    private init() {}
    
    // MARK: - Fetch Workouts
    func fetchWorkouts() async throws -> [Workout] {
        var url = Bundle.main.url(forResource: "list_workouts", withExtension: "json")
        
        guard let url = url else {
            throw WorkoutServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(WorkoutListResponse.self, from: data)
        return response.data
    }
    
    // MARK: - Fetch Metadata
    func fetchMetadata(for workoutKey: String) async throws -> WorkoutMetadata? {
        let allMetadata = try await fetchAllMetadata()
        return allMetadata[workoutKey]
    }
    
    func fetchAllMetadata() async throws -> [String: WorkoutMetadata] {
        var url = Bundle.main.url(forResource: "metadata", withExtension: "json")
        
        guard let url = url else {
            throw WorkoutServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(MetadataResponse.self, from: data)
        return response.workouts
    }
    
    // MARK: - Fetch Diagram Data
    func fetchDiagramData(for workoutKey: String) async throws -> DiagramData? {
        var url = Bundle.main.url(forResource: "diagram_data", withExtension: "json")
        
        guard let url = url else {
            throw WorkoutServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(DiagramDataResponse.self, from: data)
        return response.workouts[workoutKey]
    }
}

// MARK: - Service Errors
enum WorkoutServiceError: Error, LocalizedError {
    case fileNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Файл с данными не найден"
        case .decodingError:
            return "Ошибка декодирования данных"
        }
    }
}

