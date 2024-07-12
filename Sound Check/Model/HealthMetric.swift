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

    static var mockData: [HealthMetric] {
        var array: [HealthMetric] = []

        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                value: .random(in: 20..<100))
            array.append(metric)
        }
        return array
    }
}
