//
//  WorkoutCalendarApp.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import SwiftUI

@main
struct WorkoutCalendarApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            CalendarView(viewModel: CalendarViewModel())
                .environmentObject(coordinator)
        }
    }
}
