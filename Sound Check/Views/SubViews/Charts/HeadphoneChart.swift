//
//  HeadphoneChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/31/24.
//

import SwiftUI
import Charts

struct HeadphoneChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    var subtitle: Double {
        Double(chartData.map { $0.value}.average)
    }

    var body: some View {
        ChartContainer(chartType: .headphoneLine(average: subtitle)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .headphones, style: nil)
                }
                if !chartData.isEmpty {
                    RuleMark(y: .value("Goal", 55))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
                ForEach(chartData) { headphonedB in
                    Plot {
                        LineMark(
                            x: .value("Day", headphonedB.date, unit: .day),
                            y: .value("Value", headphonedB.value)
                        )
                        .foregroundStyle(.indigo.gradient)
                        .interpolationMethod(.cardinal)
                        .symbol(.circle)
                        .symbolSize(50)
                        
                        AreaMark(
                            x: .value("Day", headphonedB.date, unit: .day),
                            yStart: .value("Value", headphonedB.value),
                            yEnd: .value("Min Value", minValue - 15)
                        )
                        .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                        .interpolationMethod(.cardinal)
                    }
                    .accessibilityLabel(headphonedB.date.accessibilityDate)
                    .accessibilityValue("\(String(describing: Double(headphonedB.value.formatted(.number.precision(.fractionLength(2)))))) decibels")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis{
                AxisMarks{
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis{
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))

                    AxisValueLabel()
                }
            }
            .overlay{
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.xyaxis.line", title: "No Data", description: "There is no sound data from the Health App")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    HeadphoneChart(chartData: ChartHelper.convert(data: MockData.HeadphonedB))
}
