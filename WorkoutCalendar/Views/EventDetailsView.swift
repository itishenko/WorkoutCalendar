//
//  EventDetailsView.swift
//  WorkoutCalendar
//
//  Created by Ivan Tishchenko on 16.12.2025.
//

import SwiftUI

struct EventDetailsView: View {
    @StateObject var viewModel: EventDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let metadata = viewModel.metadata {
                    // Header
                    headerView(metadata: metadata)
                    
                    Divider()
                    
                    // Date and Time
                    infoSection(title: "Дата и время", value: viewModel.dateTimeString, icon: "calendar")
                    
                    // Description
                    if !viewModel.description.isEmpty {
                        infoSection(title: "Описание", value: viewModel.description, icon: "text.alignleft")
                    }
                    
                    Divider()
                    
                    // Statistics
                    statisticsSection(metadata: metadata)
                    
                    // Weather
                    weatherSection
                    
                    // Heart Rate Chart
                    if let diagramData = viewModel.diagramData {
                        Divider()
                        heartRateChartSection(diagramData: diagramData)
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Header View
    private func headerView(metadata: WorkoutMetadata) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(activityColor(for: metadata.workoutActivityType).opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: activityIcon(for: metadata.workoutActivityType))
                    .font(.system(size: 48))
                    .foregroundColor(activityColor(for: metadata.workoutActivityType))
            }
            
            Text(metadata.workoutActivityType.localizedActivityType)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    // MARK: - Info Section
    private func infoSection(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Statistics Section
    private func statisticsSection(metadata: WorkoutMetadata) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Дистанция", value: viewModel.distance, icon: "location.fill", color: .blue)
                StatCard(title: "Длительность", value: viewModel.duration, icon: "clock.fill", color: .green)
            }
        }
    }
    
    // MARK: - Weather Section
    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Погода")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Температура", value: viewModel.avgTemp, icon: "thermometer", color: .orange)
                StatCard(title: "Влажность", value: viewModel.avgHumidity, icon: "humidity.fill", color: .cyan)
            }
        }
    }
    
    // MARK: - Heart Rate Chart Section
    private func heartRateChartSection(diagramData: DiagramData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("График пульса")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HeartRateChart(data: diagramData.data)
                .frame(height: 200)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Ошибка")
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    private func activityIcon(for type: String) -> String {
        switch type {
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
    
    private func activityColor(for type: String) -> Color {
        switch type {
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

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Heart Rate Chart
struct HeartRateChart: View {
    let data: [DataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Calculate min and max heart rate for scaling
            let heartRates = data.map { $0.heartRate }
            let minHR = heartRates.min() ?? 60
            let maxHR = heartRates.max() ?? 180
            let range = CGFloat(maxHR - minHR)
            
            ZStack(alignment: .topLeading) {
                // Background grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        HStack {
                            Text("\(maxHR - (maxHR - minHR) * i / 4)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                        }
                        
                        if i < 4 {
                            Spacer()
                        }
                    }
                }
                
                // Heart rate line chart
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let xStep = (width - 40) / CGFloat(max(data.count - 1, 1))
                    
                    for (index, point) in data.enumerated() {
                        let x = 40 + CGFloat(index) * xStep
                        let normalizedHR = CGFloat(point.heartRate - minHR) / range
                        let y = height * (1 - normalizedHR)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                
                // Filled area under the line
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let xStep = (width - 40) / CGFloat(max(data.count - 1, 1))
                    
                    // Start from bottom left
                    path.move(to: CGPoint(x: 40, y: height))
                    
                    // Draw line following heart rate
                    for (index, point) in data.enumerated() {
                        let x = 40 + CGFloat(index) * xStep
                        let normalizedHR = CGFloat(point.heartRate - minHR) / range
                        let y = height * (1 - normalizedHR)
                        
                        if index == 0 {
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    
                    // Close path at bottom right
                    if let lastPoint = data.last {
                        let lastX = 40 + CGFloat(data.count - 1) * xStep
                        path.addLine(to: CGPoint(x: lastX, y: height))
                    }
                    
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [.red.opacity(0.3), .pink.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Statistics overlay
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Средний: \(averageHeartRate) bpm")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(8)
                    .background(Color(uiColor: .systemBackground).opacity(0.9))
                    .cornerRadius(8)
                    
                    HStack {
                        Image(systemName: "arrow.up.heart.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("Макс: \(maxHR) bpm")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(uiColor: .systemBackground).opacity(0.9))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
    
    private var averageHeartRate: Int {
        guard !data.isEmpty else { return 0 }
        let sum = data.reduce(0) { $0 + $1.heartRate }
        return sum / data.count
    }
}

#Preview {
    NavigationStack {
        EventDetailsView(viewModel: EventDetailsViewModel(workoutKey: "7823456789012345"))
    }
}
