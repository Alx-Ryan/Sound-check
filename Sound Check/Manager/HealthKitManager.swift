    //
    //  HealthKitManager.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 7/6/24.
    //

import Foundation
import HealthKitUI
import Observation

enum SCError: LocalizedError {
    case authNotDetermine
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue

    var errorDescription: String? {
        switch self {
            case .authNotDetermine:
                "Need access to Health Data."
            case .sharingDenied(_):
                "No write access."
            case .noData:
                "No data."
            case .unableToCompleteRequest:
                "Unable to complete request."
            case .invalidValue:
                "Invalid Valuew"
        }
    }

    var failureReason: String {
        switch self {
            case .authNotDetermine:
                "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
            case .sharingDenied(let quantityType):
                "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings > Health > Data Access & Devices."
            case .noData:
                "There is no data for the Health statistic."
            case .unableToCompleteRequest:
                "We are unable to complete your request at this time. \n\nPlease try again later or contact support."
            case .invalidValue:
                "Must be a number with a maximum of one decimal place."
        }
    }
}

@Observable class HealthKitManager {

    let store = HKHealthStore()

    let types: Set = [HKQuantityType(.environmentalAudioExposure), HKQuantityType(.headphoneAudioExposure)]

    var environmentData: [HealthMetric] = []
    var headphonesData: [HealthMetric] = []
    var decibelDiffData: [HealthMetric] = []

    func fetchDecibelCount() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.environmentalAudioExposure)) != .notDetermined else {
            throw SCError.authNotDetermine
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("Unable to calculate the end date")
        }
        guard let startDate = calendar.date(byAdding: .day, value: -28, to: endDate) else {
            fatalError("Unable to calculate the start date")
        }

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.environmentalAudioExposure),
            predicate: queryPredicate
        )
        let environmentQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteMax,
            anchorDate: endDate,
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
        } catch HKError.errorNoData {
            throw SCError.noData
        } catch {
            throw SCError.unableToCompleteRequest
        }
    }

    func fetchHeadphoneDecibelCount() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.headphoneAudioExposure)) != .notDetermined else {
            throw SCError.authNotDetermine
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("Unable to calculate the end date")
        }
        guard let startDate = calendar.date(byAdding: .day, value: -28, to: endDate) else {
            fatalError("Unable to calculate the start date")
        }

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.headphoneAudioExposure),
            predicate: queryPredicate
        )
        let headphoneQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteMax,
            anchorDate: endDate,
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
        } catch HKError.errorNoData {
            throw SCError.noData
        } catch {
            throw SCError.unableToCompleteRequest
        }
    }

    func fetchHeadphoneDecibelCountDiff() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.headphoneAudioExposure)) != .notDetermined else {
            throw SCError.authNotDetermine
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("Unable to calculate the end date")
        }
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: endDate) else {
            fatalError("Unable to calculate the start date")
        }

        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.headphoneAudioExposure),
            predicate: queryPredicate
        )
        let headphoneQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteMax,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )

        do {
            let headphoneLevels = try await headphoneQuery.result(for: store)

            let defaultDecibel = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: 0.0)

            decibelDiffData = headphoneLevels.statistics().map { stat in
                let maxQuantity = stat.maximumQuantity() ?? defaultDecibel
                let maxValue = maxQuantity.doubleValue(for: .decibelAWeightedSoundPressureLevel())
                return HealthMetric(date: stat.startDate, value: maxValue)
            }
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
