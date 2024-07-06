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
}
