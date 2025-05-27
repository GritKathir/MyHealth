//
//  HealthKitManager.swift
//  MyHealthKit
//
//  Created by Michael S on 23/05/25.
//

import HealthKit

//class HealthKitManager: ObservableObject {
//    private let healthStore = HKHealthStore()
//
//    @Published var heartRate: Double = 0.0
//    @Published var hrv: Double = 0.0
//    @Published var spo2: Double = 0.0
//    @Published var activeEnergy: Double = 0.0
//    @Published var standHours: Int = 0
//    @Published var steps: Int = 0
//    @Published var distance: Double = 0.0
//    @Published var exerciseMinutes: Double = 0.0
//    @Published var flightsClimbed: Int = 0
//    @Published var restingEnergy: Double = 0.0
//    @Published var vo2Max: Double = 0.0
//    @Published var workoutMinutes: Double = 0.0
//    @Published var cardioRecovery: Double = 0.0
//    @Published var bodyTemperature: Double = 0.0
//    @Published var restingHeartRate: Double = 0.0
//    @Published var respiratoryRate: Double = 0.0
//    @Published var averageHRV: Double = 0.0
//
//    init() {
//        requestAuthorization()
//    }
//
//    // Step 1: Request permission
//    func requestAuthorization() {
//        guard HKHealthStore.isHealthDataAvailable() else { return }
//
//        let typesToRead: Set = [
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
//            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
//            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
//            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
//            HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
//            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
//            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
//            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
//            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
//            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
//            HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
//            HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
//            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
//            HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!,
//            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
//        ]
//
//        var allTypesToRead: Set<HKObjectType> = Set(typesToRead)
//
//        healthStore.requestAuthorization(toShare: [], read: allTypesToRead) { success, _ in
//            if success {
//                DispatchQueue.main.async {
//                    self.startObserving()
//                }
//            }
//        }
//    }
//
//    // Step 2: Observe all data types
//    private func startObserving() {
//        observe(type: .heartRate)
//        observe(type: .heartRateVariabilitySDNN)
//        observe(type: .oxygenSaturation)
//        observe(type: .activeEnergyBurned)
//        observe(type: .appleStandTime)
//        observe(type: .stepCount)
//        observe(type: .distanceWalkingRunning)
//        observe(type: .appleExerciseTime)
//        observe(type: .flightsClimbed)
//        observe(type: .basalEnergyBurned)
//        observe(type: .vo2Max)
//        observe(type: .bodyTemperature)
//        observe(type: .restingHeartRate)
//        observe(type: .respiratoryRate)
//        observe(type: .heartRateVariabilitySDNN) // averageHRV uses same identifier
//        observeWorkouts()
//    }
//
//    // Observe workouts separately since it's not a quantity type
//    private func observeWorkouts() {
//        let workoutType = HKObjectType.workoutType()
//        let observerQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, _, error in
//            guard let self = self, error == nil else { return }
//            self.fetchLatestWorkout()
//        }
//        healthStore.execute(observerQuery)
//        healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate) { success, error in
//            if success {
//                print("Workout background delivery enabled")
//            } else if let error = error {
//                print("Workout background delivery error: \(error.localizedDescription)")
//            }
//        }
//        fetchLatestWorkout()
//    }
//
//    private func fetchLatestWorkout() {
//        let workoutType = HKObjectType.workoutType()
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//        let query = HKSampleQuery(sampleType: workoutType,
//                                  predicate: nil,
//                                  limit: 1,
//                                  sortDescriptors: [sortDescriptor]) { _, samples, _ in
//            guard let sample = samples?.first as? HKWorkout else { return }
//            let durationMinutes = sample.duration / 60.0
//            DispatchQueue.main.async {
//                self.workoutMinutes = durationMinutes
//            }
//        }
//        healthStore.execute(query)
//    }
//
//    // ✅ Step 3: Declare `observe(type:)` here
//    private func observe(type identifier: HKQuantityTypeIdentifier) {
//        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return }
//
//        let observerQuery = HKObserverQuery(sampleType: quantityType, predicate: nil) { [weak self] _, _, error in
//            guard let self = self, error == nil else {
//                print("Observer error for \(identifier.rawValue): \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            print("Observer triggered for \(identifier.rawValue)")
//            self.fetchLatestSample(for: identifier)
//        }
//
//        healthStore.execute(observerQuery)
//
//        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { success, error in
//            if success {
//                print("✅ Enabled background delivery for \(identifier.rawValue)")
//            } else if let error = error {
//                print("❌ Background delivery error for \(identifier.rawValue): \(error.localizedDescription)")
//            }
//        }
//
//        // Always fetch the current value at setup time
//        self.fetchLatestSample(for: identifier)
//    }
//
//    // Step 4: Fetch latest sample
//    private func fetchLatestSample(for identifier: HKQuantityTypeIdentifier) {
//        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return }
//
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//        let query = HKSampleQuery(sampleType: quantityType,
//                                  predicate: nil,
//                                  limit: 1,
//                                  sortDescriptors: [sortDescriptor]) {
//            _,
//            samples,
//            _ in
//            guard let sample = samples?.first as? HKQuantitySample else { return }
//
//            let value: Double
//            switch identifier {
//                case .heartRate:
//                    value = sample.quantity.doubleValue(for: .init(from: "count/min"))
//                    print("❤️ Latest Heart Rate: \(value)")
//                    DispatchQueue.main.async {
//                        self.heartRate = value
//                    }
//
//                case .heartRateVariabilitySDNN:
//                    value = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
//                    DispatchQueue.main.async {
//                        self.hrv = value
//                        self.averageHRV = value
//                    }
//
//                case .oxygenSaturation:
//                    value = sample.quantity.doubleValue(for: .percent())
//                    DispatchQueue.main.async { self.spo2 = value }
//
//                case .activeEnergyBurned:
//                    value = sample.quantity.doubleValue(for: .kilocalorie())
//                    DispatchQueue.main.async { self.activeEnergy = value }
//
//                case .appleStandTime:
//                    value = sample.quantity.doubleValue(for: .count())
//                    DispatchQueue.main.async { self.standHours = Int(value) }
//
//                case .stepCount:
//                    value = sample.quantity.doubleValue(for: .count())
//                    DispatchQueue.main.async { self.steps = Int(value) }
//
//                case .distanceWalkingRunning:
//                    value = sample.quantity.doubleValue(for: .meter())
//                    DispatchQueue.main.async { self.distance = value }
//
//                case .appleExerciseTime:
//                    value = sample.quantity.doubleValue(for: .minute())
//                    DispatchQueue.main.async { self.exerciseMinutes = value }
//
//                case .flightsClimbed:
//                    value = sample.quantity.doubleValue(for: .count())
//                    DispatchQueue.main.async { self.flightsClimbed = Int(value) }
//
//                case .basalEnergyBurned:
//                    value = sample.quantity.doubleValue(for: .kilocalorie())
//                    DispatchQueue.main.async { self.restingEnergy = value }
//
//                case .vo2Max:
//                    value = sample.quantity
//                        .doubleValue(
//                            for: HKUnit(from: "ml/kg*min")
//                        );                DispatchQueue.main
//                        .async { self.vo2Max = value }
//
//                case .bodyTemperature:
//                    value = sample.quantity.doubleValue(for: .degreeCelsius())
//                    DispatchQueue.main.async { self.bodyTemperature = value }
//
//                case .restingHeartRate:
//                    value = sample.quantity.doubleValue(for: .init(from: "count/min"))
//                    DispatchQueue.main.async { self.restingHeartRate = value }
//
//                case .respiratoryRate:
//                    value = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
//                    DispatchQueue.main.async { self.respiratoryRate = value }
//
//                default: break
//            }
//        }
//
//        healthStore.execute(query)
//    }
//}

import HealthKit
import Foundation
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var heartRate: Double = 0.0
    @Published var hrv: Double = 0.0
    @Published var spo2: Double = 0.0
    @Published var activeEnergy: Double = 0.0
    @Published var standHours: Int = 0
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0
    @Published var exerciseMinutes: Double = 0.0
    @Published var flightsClimbed: Int = 0
    @Published var restingEnergy: Double = 0.0
    @Published var vo2Max: Double = 0.0
    @Published var workoutMinutes: Double = 0.0
    @Published var cardioRecovery: Double = 0.0
    @Published var bodyTemperature: Double = 0.0
    @Published var restingHeartRate: Double = 0.0
    @Published var respiratoryRate: Double = 0.0
    @Published var averageHRV: Double = 0.0

    private var debounceTimer: Timer?

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.requestAuthorization()
        }
    }

    private func requestAuthorization(retry: Bool = true) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available.")
            return
        }

        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate, .heartRateVariabilitySDNN, .oxygenSaturation,
            .activeEnergyBurned, .appleStandTime, .stepCount,
            .distanceWalkingRunning, .appleExerciseTime, .flightsClimbed,
            .basalEnergyBurned, .vo2Max, .bodyTemperature,
            .restingHeartRate, .respiratoryRate
        ]

        let typesToRead: Set<HKObjectType> = Set(identifiers.compactMap {
            HKObjectType.quantityType(forIdentifier: $0)
        } + [HKObjectType.workoutType()])

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("✅ HealthKit authorization successful.")
                DispatchQueue.main.async {
                    self.startObserving(types: identifiers)
                }
            } else if let error = error {
                print("❌ Authorization error: \(error.localizedDescription)")
                if retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.requestAuthorization(retry: false)
                    }
                }
            }
        }
    }

    private func startObserving(types: [HKQuantityTypeIdentifier]) {
        types.forEach {
            observe(type: $0)
            fetchTodayCumulative(for: $0) // Now safe due to type check inside
        }

        observeWorkouts()
    }

    private func observe(type identifier: HKQuantityTypeIdentifier) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return }

        let observerQuery = HKObserverQuery(sampleType: quantityType, predicate: nil) { [weak self] _, _, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Observer error for \(identifier.rawValue): \(error.localizedDescription)")
                return
            }
            self.fetchLatestSample(for: identifier)
            self.fetchTodayCumulative(for: identifier)
        }

        healthStore.execute(observerQuery)

        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { _, _ in }
    }

    private func fetchLatestSample(for identifier: HKQuantityTypeIdentifier) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return }

        let query = HKSampleQuery(sampleType: quantityType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let self = self,
                  let sample = samples?.first as? HKQuantitySample else { return }

            self.updatePublishedValue(identifier: identifier, sample: sample)
        }

        healthStore.execute(query)
    }

    private func fetchTodayCumulative(for identifier: HKQuantityTypeIdentifier) {
        // Only use cumulativeSum for compatible types
        let cumulativeTypes: Set<HKQuantityTypeIdentifier> = [
            .activeEnergyBurned,
            .basalEnergyBurned,
            .stepCount,
            .appleExerciseTime,
            .appleStandTime,
            .distanceWalkingRunning,
            .flightsClimbed
        ]
        
        guard cumulativeTypes.contains(identifier) else {
            print("⚠️ Skipping cumulative fetch for \(identifier.rawValue) — not a cumulative type.")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            print("❌ Invalid quantity type for identifier: \(identifier.rawValue)")
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: quantityType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, result, error in
            if let error = error {
                print("❌ Stats query error for \(identifier.rawValue): \(error.localizedDescription)")
                return
            }
            
            guard let quantity = result?.sumQuantity() else {
                print("⚠️ No cumulative value found for \(identifier.rawValue)")
                return
            }

            let value: Double
            switch identifier {
            case .activeEnergyBurned, .basalEnergyBurned:
                value = quantity.doubleValue(for: .kilocalorie())
                DispatchQueue.main.async {
                    if identifier == .activeEnergyBurned {
                        self.activeEnergy = value
                    } else {
                        self.restingEnergy = value
                    }
                }
            case .stepCount, .flightsClimbed, .appleStandTime:
                value = quantity.doubleValue(for: .count())
                DispatchQueue.main.async {
                    switch identifier {
                    case .stepCount: self.steps = Int(value)
                    case .flightsClimbed: self.flightsClimbed = Int(value)
                    case .appleStandTime: self.standHours = Int(value)
                    default: break
                    }
                }
            case .appleExerciseTime:
                value = quantity.doubleValue(for: .minute())
                DispatchQueue.main.async { self.exerciseMinutes = value }
            case .distanceWalkingRunning:
                value = quantity.doubleValue(for: .meter())
                DispatchQueue.main.async { self.distance = value }
            default:
                break
            }
        }

        healthStore.execute(query)
    }

    private func updatePublishedValue(identifier: HKQuantityTypeIdentifier, sample: HKQuantitySample) {
        let value: Double

        switch identifier {
            case .heartRate:
                value = sample.quantity.doubleValue(for: .init(from: "count/min"))
                DispatchQueue.main.async { self.heartRate = value }

            case .heartRateVariabilitySDNN:
                value = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
                DispatchQueue.main.async {
                    self.hrv = value
                    self.averageHRV = value
                }

            case .oxygenSaturation:
                value = sample.quantity.doubleValue(for: .percent())
                DispatchQueue.main.async { self.spo2 = value }

            case .vo2Max:
                value = sample.quantity.doubleValue(for: HKUnit(from: "ml/kg*min"))
                DispatchQueue.main.async { self.vo2Max = value }

            case .bodyTemperature:
                value = sample.quantity.doubleValue(for: .degreeCelsius())
                DispatchQueue.main.async { self.bodyTemperature = value }

            case .restingHeartRate:
                value = sample.quantity.doubleValue(for: .init(from: "count/min"))
                DispatchQueue.main.async { self.restingHeartRate = value }

            case .respiratoryRate:
                value = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
                DispatchQueue.main.async { self.respiratoryRate = value }

            default:
                return
        }

        // Debounce print
        DispatchQueue.main.async {
            self.debounceTimer?.invalidate()
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.printAllHealthData()
            }
        }
    }

    private func observeWorkouts() {
        let workoutType = HKObjectType.workoutType()

        let observerQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestWorkout()
        }

        healthStore.execute(observerQuery)

        healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate) { _, _ in }

        fetchLatestWorkout()
    }

    private func fetchLatestWorkout() {
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let self = self,
                  let workout = samples?.first as? HKWorkout else { return }

            DispatchQueue.main.async {
                self.workoutMinutes = workout.duration / 60.0
            }
        }

        healthStore.execute(query)
    }

    private func printAllHealthData() {
        print("""
        🩺 Health Summary:
        Heart Rate: \(heartRate)
        HRV: \(hrv)
        SpO2: \(spo2)
        Active Energy: \(activeEnergy)
        Resting Energy: \(restingEnergy)
        Stand Hours: \(standHours)
        Steps: \(steps)
        Distance: \(distance)
        Exercise Minutes: \(exerciseMinutes)
        Flights Climbed: \(flightsClimbed)
        VO2 Max: \(vo2Max)
        Temp: \(bodyTemperature)
        Resting HR: \(restingHeartRate)
        Resp Rate: \(respiratoryRate)
        Workout Duration (min): \(workoutMinutes)
        """)
    }
}
