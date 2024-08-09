//
//  ChartMath.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import Foundation
import Algorithms

struct ChartMath {

    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt, order: .forward))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }

        var weekdayChartData: [DateValueChartData] = []

        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgDecibel = total / Double(array.count)

            weekdayChartData.append(.init(date: firstValue.date, value: avgDecibel))
        }
        return weekdayChartData
    }

    static func averageDailySoundDiffs(for decibel: [HealthMetric]) -> [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []

        guard !decibel.isEmpty, decibel.count > 1 else { return [] }
        for i in 1..<decibel.count {
                let date = decibel[i].date
                let diff = decibel[i].value - decibel[i - 1].value
                diffValues.append((date: date, value: diff))
            }

        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }

        var weekdayChartData: [DateValueChartData] = []

        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgDecibelDiff = total / Double(array.count)

            weekdayChartData.append(.init(date: firstValue.date, value: avgDecibelDiff))
        }
        
        return weekdayChartData
    }
}
