//
//  ChartMath.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import Foundation
import Algorithms

struct ChartMath {

    static func averageWeekdayCount(for metric: [HealthMetric]) -> [WeekDayChartData] {

        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }

        var weekdayChartData: [WeekDayChartData] = []

        for array in weekdayArray {
            guard let firstValue = array.first?.value else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgDecibel = total / Double(array.count)

            weekdayChartData.append(.init(date: array.first!.date, value: avgDecibel))
        }
        return weekdayChartData
    }
}
