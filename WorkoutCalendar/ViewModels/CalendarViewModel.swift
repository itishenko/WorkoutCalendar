//
//  CalendarViewModel.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var workouts: [Workout] = []
    @Published var metadata: [String: WorkoutMetadata] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let workoutService: WorkoutServiceProtocol
    private let calendar = Calendar.current
    
    // MARK: - Computed Properties
    var daysInMonth: [Date?] {
        generateDaysInMonth(for: currentMonth)
    }
    
    var eventsForSelectedDate: [Workout] {
        filterWorkouts(for: selectedDate)
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: currentMonth).capitalized
    }
    
    // MARK: - Init
    init(workoutService: WorkoutServiceProtocol = WorkoutService.shared) {
        self.workoutService = workoutService
    }
    
    // MARK: - Public Methods
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            workouts = try await workoutService.fetchWorkouts()
            metadata = try await workoutService.fetchAllMetadata()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func moveToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func moveToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func selectDate(_ date: Date?) {
        guard let date = date else { return }
        selectedDate = date
    }
    
    func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return calendar.isDateInToday(date)
    }
    
    func isSelected(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func hasEvents(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return !filterWorkouts(for: date).isEmpty
    }
    
    // MARK: - Private Methods
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let daysCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        
        var days: [Date?] = []
        
        // Calculate offset for the first day of month
        let firstDayOfMonth = monthInterval.start
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Adjust for Monday as first day of week (weekday: 1=Sunday, 2=Monday, ..., 7=Saturday)
        let offset = (weekdayOfFirstDay + 5) % 7
        
        // Add empty cells for days before the first day of month
        for _ in 0..<offset {
            days.append(nil)
        }
        
        // Add all days of the month
        for day in 1...daysCount {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        // Fill remaining cells to complete the last week
        let remainingCells = 7 - (days.count % 7)
        if remainingCells < 7 {
            for _ in 0..<remainingCells {
                days.append(nil)
            }
        }
        
        return days
    }
    
    private func filterWorkouts(for date: Date) -> [Workout] {
        workouts.filter { workout in
            guard let workoutDate = workout.startDate else { return false }
            return calendar.isDate(workoutDate, inSameDayAs: date)
        }
    }
}


