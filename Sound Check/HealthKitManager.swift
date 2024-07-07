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
