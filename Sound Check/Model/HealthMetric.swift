//
//  HealthMetric.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/7/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double

}
