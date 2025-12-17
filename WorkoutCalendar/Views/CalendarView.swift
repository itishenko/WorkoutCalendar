//
//  CalendarView.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var viewModel: CalendarViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 0) {
                // Month Header
                monthHeaderView
                
                // Calendar Grid
                ScrollView {
                    VStack(spacing: 16) {
                        calendarGridView
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Events List
                        eventsListView
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Календарь тренировок")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationDestination.self) { destination in
                coordinator.build(destination: destination)
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Month Header
    private var monthHeaderView: some View {
        HStack {
            Button(action: {
                viewModel.moveToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                viewModel.moveToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Calendar Grid
    private var calendarGridView: some View {
        VStack(spacing: 8) {
            // Week days header
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Days grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(viewModel.daysInMonth.enumerated()), id: \.offset) { index, date in
                    DayCell(
                        date: date,
                        isToday: viewModel.isToday(date),
                        isSelected: viewModel.isSelected(date),
                        hasEvents: viewModel.hasEvents(date)
                    )
                    .onTapGesture {
                        if let date = date {
                            viewModel.selectDate(date)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Events List
    private var eventsListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("События дня")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            if viewModel.eventsForSelectedDate.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.eventsForSelectedDate) { workout in
                    EventRow(workout: workout, metadata: viewModel.metadata[workout.workoutKey])
                        .onTapGesture {
                            coordinator.push(.eventDetails(workoutKey: workout.workoutKey))
                        }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Нет тренировок")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("В этот день не запланировано тренировок")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date?
    let isToday: Bool
    let isSelected: Bool
    let hasEvents: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            if let date = date {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(textColor)
                    .frame(width: 40, height: 40)
                    .background(backgroundColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                
                if hasEvents {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            } else {
                Spacer()
                    .frame(width: 40, height: 40)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .accentColor
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else {
            return .clear
        }
    }
}

// MARK: - Event Row
struct EventRow: View {
    let workout: Workout
    let metadata: WorkoutMetadata?
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: activityIcon)
                    .font(.system(size: 20))
                    .foregroundColor(activityColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.workoutActivityType.localizedActivityType)
                    .font(.headline)
                
                if let date = workout.startDate {
                    Text(timeString(from: date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let comment = metadata?.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var activityIcon: String {
        switch workout.workoutActivityType {
        case "Walking/Running":
            return "figure.run"
        case "Cycling":
            return "bicycle"
        case "Yoga":
            return "figure.yoga"
        case "Water":
            return "figure.open.water.swim"
        case "Strength":
            return "dumbbell.fill"
        default:
            return "figure.mixed.cardio"
        }
    }
    
    private var activityColor: Color {
        switch workout.workoutActivityType {
        case "Walking/Running":
            return .green
        case "Cycling":
            return .blue
        case "Yoga":
            return .purple
        case "Water":
            return .cyan
        case "Strength":
            return .orange
        default:
            return .gray
        }
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel())
        .environmentObject(AppCoordinator())
}


