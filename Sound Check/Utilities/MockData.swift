//
//  MockData.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/31/24.
//

import SwiftUI

struct MockData {

    static var EnvironmentdB: [HealthMetric] {
        var array: [HealthMetric] = []

        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 20..<100))
            array.append(metric)
        }
        return array
    }

    static var HeadphonedB: [HealthMetric] {
        var array: [HealthMetric] = []

        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: (55 + Double(i/3)...75 + Double(i/3))))
            array.append(metric)
        }
        return array
    }
}

