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

    func fetchDecibelCount() async {
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

        let environmentLevels = try! await environmentQuery.result(for: store)

            //        let defaultDecibel = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: 0.0)
            //
            //        for level in environmentLevels.statistics() {
            //            let maxQuantity = level.maximumQuantity() ?? defaultDecibel
            //            print("\(maxQuantity)")
            //        }
    }

    func fetchHeadphoneDecibelCount() async {
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

        let headphoneLevels = try! await headphoneQuery.result(for: store)

            //            let defaultDecibel = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: 0.0)
            //
            //            for level in headphoneLevels.statistics() {
            //                let maxQuantity = level.maximumQuantity() ?? defaultDecibel
            //                print("\(maxQuantity)")
            //            }
    }

        //    func addSimulatorData() async {
        //        var mockSamples: [HKQuantitySample] = []
        //
        //        for i in 0..<28 {
        //            let decibelQuantity = HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: .random(in: 5...110))
        //            //let headphoneQuantity = HKQuantity(unit: .decibelHearingLevel(), doubleValue: .random(in: 5...110))
        //
        //            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
        //            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
        //
        //            let environmentSample = HKQuantitySample(type: HKQuantityType(.environmentalAudioExposure) , quantity: decibelQuantity, start: startDate, end: endDate)
        //            let headphoneSample = HKQuantitySample(type: HKQuantityType(.headphoneAudioExposure) , quantity: decibelQuantity, start: startDate, end: endDate)
        //
        //            mockSamples.append(headphoneSample)
        //            mockSamples.append(environmentSample)
        //        }
        //
        //        try! await store.save(mockSamples)
        //        print("Dummy data sent ✅")
        //    }
}
