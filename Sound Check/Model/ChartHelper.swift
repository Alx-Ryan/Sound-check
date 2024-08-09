//
//  ChartHelper.swift
//  Sound Check
//
//  Created by Alex Ryan on 8/7/24.
//

import Foundation
import Algorithms

struct ChartHelper {
        /// Converts an array of ``HealthMetric`` objects into an array of ``DateValueChartData`` objects, preserving the date and value properties.
        /// - Parameter data: An array of ``HealthMetric`` objects to convert.
        /// - Returns: An array of ``DateValueChartData`` objects.
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value) }
    }

        /// Parses and returns the ``DateValueChartData`` object from a given array that matches the selected date.
        /// - Parameters:
        ///   - data: An array of ``DateValueChartData`` objects to search through.
        ///   - selectedDate: The date to find in the data array.
        /// - Returns: The ``DateValueChartData`` object that matches the selected date, or `nil` if no match is found.
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
        /// Calculates the average value of ``HealthMetric`` objects grouped by the day of the week.
        /// - Parameter metric: An array of ``HealthMetric`` objects to process.
        /// - Returns: An array of ``DateValueChartData`` with the average values for each day of the week.
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
        /// Calculates the daily differences in sound levels between consecutive ``HealthMetric`` objects.
        /// - Parameter decibel: An array of ``HealthMetric`` objects to calculate differences for.
        /// - Returns: An array of ``DateValueChartData`` with the average difference values grouped by the day of the week.
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
