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

    func addSoundData(for date: Date, value: Double) async throws {
        try await addAudioExposureData(for: date, value: value, typeIdentifier: .environmentalAudioExposure)
    }

    func addHeadphoneData(for date: Date, value: Double) async throws {
        try await addAudioExposureData(for: date, value: value, typeIdentifier: .headphoneAudioExposure)
    }
    
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
