//
//  HealthDashboardView.swift
//  MyHealthKit
//
//  Created by Michael S on 23/05/25.
//

import SwiftUI
struct HealthDashboardView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {   
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        ScrollView {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            LazyVGrid(columns: columns, spacing: 16) {
                healthMetricCard(icon: "❤️", value: "\(String(format: "%.1f", healthKitManager.heartRate)) bpm", label: "Heart Rate")
                healthMetricCard(icon: "📉", value: "\(String(format: "%.1f", healthKitManager.hrv)) ms", label: "HRV")
                healthMetricCard(icon: "🫁", value: "\(String(format: "%.1f", healthKitManager.spo2 * 100))%", label: "SpO₂")
                healthMetricCard(icon: "🔥", value: "\(String(format: "%.0f", healthKitManager.activeEnergy)) kcal", label: "Active Energy")
                healthMetricCard(icon: "🧍‍♂️", value: "\(healthKitManager.standHours) hrs", label: "Stand Hours")
                healthMetricCard(icon: "👣", value: "\(healthKitManager.steps)", label: "Steps")
                healthMetricCard(icon: "📏", value: "\(String(format: "%.2f", healthKitManager.distance / 1000)) km", label: "Distance")
                healthMetricCard(icon: "🏃‍♂️", value: "\(String(format: "%.0f", healthKitManager.exerciseMinutes)) min", label: "Exercise")
                healthMetricCard(icon: "🪜", value: "\(healthKitManager.flightsClimbed)", label: "Flights Climbed")
                healthMetricCard(icon: "🧘‍♀️", value: "\(String(format: "%.0f", healthKitManager.restingEnergy)) kcal", label: "Resting Energy")
                healthMetricCard(icon: "💨", value: "\(String(format: "%.2f", healthKitManager.vo2Max)) ml/kg·min", label: "VO₂ Max")
                healthMetricCard(icon: "🏋️‍♀️", value: "\(String(format: "%.0f", healthKitManager.workoutMinutes)) min", label: "Workouts")
                healthMetricCard(icon: "💓", value: "\(String(format: "%.1f", healthKitManager.cardioRecovery)) bpm", label: "Cardio Recovery")
                healthMetricCard(icon: "🌡️", value: "\(String(format: "%.1f", healthKitManager.bodyTemperature)) °C", label: "Body Temp")
                healthMetricCard(icon: "💤", value: "\(String(format: "%.1f", healthKitManager.restingHeartRate)) bpm", label: "Resting HR")
                healthMetricCard(icon: "🌬️", value: "\(String(format: "%.1f", healthKitManager.respiratoryRate)) br/min", label: "Resp Rate")
                healthMetricCard(icon: "📊", value: "\(String(format: "%.1f", healthKitManager.averageHRV)) ms", label: "Avg HRV")
            }
            .padding()

        }
    }

    @ViewBuilder
    private func healthMetricCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            
            Text(icon)
                .font(.largeTitle)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.black)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


struct HealthDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Inject mock data for preview
        HealthDashboardView_PreviewWrapper()
            .previewDevice("iPhone 14 Pro")
    }
}

struct HealthDashboardView_PreviewWrapper: View {
    @StateObject private var mockHealthKitManager = MockHealthKitManager()

    var body: some View {
        HealthDashboardView()
            .environmentObject(mockHealthKitManager)
    }
}

// Mock version of HealthKitManager to populate preview with static values
class MockHealthKitManager: HealthKitManager {
    override init() {
        super.init()
        self.heartRate = 72.5
        self.hrv = 55.3
        self.spo2 = 0.98
        self.activeEnergy = 430
        self.standHours = 10
        self.steps = 7450
        self.distance = 5800
        self.exerciseMinutes = 45
        self.flightsClimbed = 6
        self.restingEnergy = 1300
        self.vo2Max = 42.5
        self.workoutMinutes = 60
        self.cardioRecovery = 18.7
        self.bodyTemperature = 36.7
        self.restingHeartRate = 62
        self.respiratoryRate = 16.4
        self.averageHRV = 58.2
    }
}
