//
//  EventDetailsViewModel.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import Foundation

@MainActor
class EventDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var metadata: WorkoutMetadata?
    @Published var diagramData: DiagramData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    let workoutKey: String
    private let workoutService: WorkoutServiceProtocol
    
    // MARK: - Computed Properties
    var title: String {
        metadata?.workoutActivityType.localizedActivityType ?? "Тренировка"
    }
    
    var dateTimeString: String {
        guard let metadata = metadata,
              let date = metadata.startDate else {
            return "—"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var description: String {
        metadata?.comment ?? "Нет описания"
    }
    
    var distance: String {
        metadata?.formattedDistance ?? "—"
    }
    
    var duration: String {
        metadata?.formattedDuration ?? "—"
    }
    
    var avgTemp: String {
        guard let metadata = metadata,
              let temp = Double(metadata.avg_temp) else {
            return "—"
        }
        return String(format: "%.1f°C", temp)
    }
    
    var avgHumidity: String {
        guard let metadata = metadata,
              let humidity = Double(metadata.avg_humidity) else {
            return "—"
        }
        return String(format: "%.0f%%", humidity)
    }
    
    // MARK: - Init
    init(workoutKey: String, workoutService: WorkoutServiceProtocol = WorkoutService.shared) {
        self.workoutKey = workoutKey
        self.workoutService = workoutService
    }
    
    // MARK: - Public Methods
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            metadata = try await workoutService.fetchMetadata(for: workoutKey)
            diagramData = try await workoutService.fetchDiagramData(for: workoutKey)
            
            if metadata == nil {
                errorMessage = "Метаданные тренировки не найдены"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}


