    //
    //  HealthKitManager.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 7/6/24.
    //

import Foundation
import HealthKitUI
import Observation

@Observable class HealthKitManager {

    let store = HKHealthStore()

    let types: Set = [HKQuantityType(.environmentalAudioExposure), HKQuantityType(.headphoneAudioExposure)]

    var environmentData: [HealthMetric] = []
    var headphonesData: [HealthMetric] = []
    var decibelDiffData: [HealthMetric] = []
    
        /// Fetch last 28 days of environment decibel data from HealthKit
        /// - Returns: Array of ``HealthMetric``
    func fetchDecibelCount() async throws  -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.environmentalAudioExposure)) != .notDetermined else {
            throw SCError.authNotDetermine
        }

        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.environmentalAudioExposure),
            predicate: queryPredicate
        )
        let environmentQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteMax,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )

        do {
            let environmentLevels = try await environmentQuery.result(for: store)

            let defaultDecibel = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: 0.0)

            environmentData = environmentLevels.statistics().map { stat in
                let maxQuantity = stat.maximumQuantity() ?? defaultDecibel
                let maxValue = maxQuantity.doubleValue(for: .decibelAWeightedSoundPressureLevel())
                return HealthMetric(date: stat.startDate, value: maxValue)
            }

            return environmentData
        } catch HKError.errorNoData {
            throw SCError.noData
        } catch {
            throw SCError.unableToCompleteRequest
        }
    }
    
        /// Fetch most recent Headphone Decibel sample on each day for specified number of days back from today.
        /// - Parameter daysBack: Days back from today. Ex - 28 will return last 28 days.
        /// - Returns: Array of ``HealthMetric``
    func fetchHeadphoneDecibelCount(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.headphoneAudioExposure)) != .notDetermined else {
            throw SCError.authNotDetermine
        }

        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.headphoneAudioExposure),
            predicate: queryPredicate
        )
        let headphoneQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteMax,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )

        do {
            let headphoneLevels = try await headphoneQuery.result(for: store)

            let defaultDecibel = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: 0.0)

            headphonesData = headphoneLevels.statistics().map { stat in
                let maxQuantity = stat.maximumQuantity() ?? defaultDecibel
                let maxValue = maxQuantity.doubleValue(for: .decibelAWeightedSoundPressureLevel())
                return HealthMetric(date: stat.startDate, value: maxValue)
            }

            return headphonesData
        } catch HKError.errorNoData {
            throw SCError.noData
        } catch {
            throw SCError.unableToCompleteRequest
        }
    }
    
        /// Write environment decibel data to HealthKit. Requires HealthKit write permission.
        /// - Parameters:
        ///   - date: Date for decibel value
        ///   - value: Decibel value
        ///   - typeIdentifier: The ``HKQuantityTypeIdentifier`` specifies the type of HealthKit data being recorded (e.g., `environmentalAudioExposure` or `headphoneAudioExposure`).
        /// - Note: The method requires HealthKit permissions to be granted before calling. The method also accounts for a minimum time interval of 0.001 seconds for `HKQuantityTypeIdentifierEnvironmentalAudioExposure`.
    func addAudioExposureData(for date: Date, value: Double, typeIdentifier: HKQuantityTypeIdentifier) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(typeIdentifier))
        switch status {
            case .notDetermined:
                throw SCError.authNotDetermine
            case .sharingDenied:
                throw SCError.sharingDenied(quantityType: typeIdentifier == .environmentalAudioExposure ? "Environmental Sound Levels" : "Headphone Audio Levels")
            case .sharingAuthorized:
                break
            @unknown default:
                break
        }

        let quantity = HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: value)

            // HKQuantityTypeIdentifierEnvironmentalAudioExposure requires 0.001 second time interval
        let endDate = date.addingTimeInterval(0.001)

        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            print("Invalid quantity type identifier.")
            return
        }

        let sample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: date,
            end: endDate
        )

        do {
            try await store.save(sample)
            print("Successfully saved sample for \(typeIdentifier.rawValue).")
        } catch {
            print("Error saving sample for \(typeIdentifier.rawValue): \(error.localizedDescription)")
            throw SCError.unableToCompleteRequest
        }
    }

        /// Saves environmental sound level data to HealthKit. Requires HealthKit write permission.
        /// - Parameters:
        ///   - date: The date and time at which the decibel value was recorded.
        ///   - value: The decibel value to be saved.
    func addSoundData(for date: Date, value: Double) async throws {
        try await addAudioExposureData(for: date, value: value, typeIdentifier: .environmentalAudioExposure)
    }

        /// Saves headphone sound level data to HealthKit. Requires HealthKit write permission.
        /// - Parameters:
        ///   - date: The date and time at which the decibel value was recorded.
        ///   - value: The decibel value to be saved.
    func addHeadphoneData(for date: Date, value: Double) async throws {
        try await addAudioExposureData(for: date, value: value, typeIdentifier: .headphoneAudioExposure)
    }
    
        /// Creates a dateInterval between two dates
        /// - Parameters:
        ///   - date: End of date interval. Ex. -today
        ///   - daysBack: Start of date interval. Ex -28 days ago
        /// - Returns: Date range between two dates as a DateInterval
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate) else {
            fatalError("Unable to calculate the end date")
        }
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate) else {
            fatalError("Unable to calculate the start date")
        }
        return .init(start: startDate, end: endDate)
    }

//            func addSimulatorData() async {
//                var mockSamples: [HKQuantitySample] = []
//        
//                for i in 0..<15 {
//                    let decibelQuantity = HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: .random(in: 5...110))
//                    let headphoneQuantity = HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: .random(in: 5...110))
//
//                    let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//                    let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//        
//                    let environmentSample = HKQuantitySample(type: HKQuantityType(.environmentalAudioExposure) , quantity: decibelQuantity, start: startDate, end: endDate)
//                    let headphoneSample = HKQuantitySample(type: HKQuantityType(.headphoneAudioExposure) , quantity: headphoneQuantity, start: startDate, end: endDate)
//        
//                    mockSamples.append(headphoneSample)
//                    mockSamples.append(environmentSample)
//                }
//        
//                try! await store.save(mockSamples)
//                print("Dummy data sent ✅")
//            }
}
