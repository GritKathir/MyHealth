import HealthKit
import Foundation

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    // Published health metrics
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
    @Published var bodyTemperature: Double = 0.0
    @Published var restingHeartRate: Double = 0.0
    @Published var respiratoryRate: Double = 0.0
    @Published var averageHRV: Double = 0.0
    @Published var cardioRecovery: Double = 35 

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
            .activeEnergyBurned, .stepCount, .distanceWalkingRunning,
            .appleExerciseTime, .flightsClimbed, .basalEnergyBurned,
            .vo2Max, .bodyTemperature, .restingHeartRate, .respiratoryRate
        ]

        let typesToRead: Set<HKObjectType> = Set(identifiers.compactMap {
            HKObjectType.quantityType(forIdentifier: $0)
        } + [HKObjectType.workoutType(), HKObjectType.activitySummaryType()])

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
            fetchTodayCumulative(for: $0)
        }

        observeWorkouts()
        fetchActivitySummary()
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

        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { success, error in
            if !success {
                print("⚠️ Background delivery failed for \(identifier.rawValue): \(error?.localizedDescription ?? "unknown")")
            }
        }
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
        let cumulativeTypes: Set<HKQuantityTypeIdentifier> = [
            .activeEnergyBurned, .basalEnergyBurned, .stepCount,
            .appleExerciseTime, .appleStandTime, .distanceWalkingRunning, .flightsClimbed
        ]

        guard cumulativeTypes.contains(identifier),
              let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            print("⚠️ Skipping cumulative fetch for \(identifier.rawValue)")
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(quantityType: quantityType,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, let quantity = result?.sumQuantity(), error == nil else {
                print("❌ Error or no value for \(identifier.rawValue)")
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

    private func fetchActivitySummary() {
        let calendar = Calendar.current
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.calendar = Calendar.current
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        let query = HKActivitySummaryQuery(predicate: predicate) { [weak self] _, summaries, _ in
            guard let summary = summaries?.first else { return }

            DispatchQueue.main.async {
                self?.standHours = Int(summary.appleStandHours.doubleValue(for: .count()))
            }
        }

        healthStore.execute(query)
    }

    private func updatePublishedValue(identifier: HKQuantityTypeIdentifier, sample: HKQuantitySample) {
        let value: Double

        switch identifier {
        case .heartRate:
            value = sample.quantity.doubleValue(for: .init(from: "count/min"))
            assign(\.heartRate, value)

        case .heartRateVariabilitySDNN:
            value = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
            assign(\.hrv, value)
            assign(\.averageHRV, value)

        case .oxygenSaturation:
            value = sample.quantity.doubleValue(for: .percent())
            assign(\.spo2, value)

        case .vo2Max:
            value = sample.quantity.doubleValue(for: HKUnit(from: "ml/kg*min"))
            assign(\.vo2Max, value)

        case .bodyTemperature:
            value = sample.quantity.doubleValue(for: .degreeCelsius())
            assign(\.bodyTemperature, value)

        case .restingHeartRate:
            value = sample.quantity.doubleValue(for: .init(from: "count/min"))
            assign(\.restingHeartRate, value)

        case .respiratoryRate:
            value = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
            assign(\.respiratoryRate, value)

        default:
            return
        }
    }

    private func observeWorkouts() {
        let workoutType = HKObjectType.workoutType()

        let observerQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, _, _ in
            self?.fetchTodayWorkouts()
        }

        healthStore.execute(observerQuery)

        healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate) { success, error in
            if !success {
                print("⚠️ Workout background delivery failed: \(error?.localizedDescription ?? "unknown")")
            }
        }

        fetchTodayWorkouts()
    }

    private func fetchTodayWorkouts() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { [weak self] _, samples, _ in
            guard let workouts = samples as? [HKWorkout] else { return }
            let totalDuration = workouts.reduce(0.0) { $0 + $1.duration }

            DispatchQueue.main.async {
                self?.workoutMinutes = totalDuration / 60.0
            }
        }

        healthStore.execute(query)
    }

    // Helper to reduce repetition
    private func assign<T>(_ keyPath: ReferenceWritableKeyPath<HealthKitManager, T>, _ value: T) {
        DispatchQueue.main.async {
            self[keyPath: keyPath] = value
        }
    }
}
