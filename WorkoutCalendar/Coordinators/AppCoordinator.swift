//
//  AppCoordinator.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import SwiftUI

// MARK: - Navigation Path
enum NavigationDestination: Hashable {
    case eventDetails(workoutKey: String)
}

// MARK: - App Coordinator
@MainActor
class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: NavigationDestination?
    
    // MARK: - Navigation Methods
    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(_ destination: NavigationDestination) {
        presentedSheet = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    // MARK: - View Builder
    @ViewBuilder
    func build(destination: NavigationDestination) -> some View {
        switch destination {
        case .eventDetails(let workoutKey):
            EventDetailsView(viewModel: EventDetailsViewModel(workoutKey: workoutKey))
        }
    }
}


