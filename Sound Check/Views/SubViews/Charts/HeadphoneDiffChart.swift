    //
    //  HeadphoneDiffChart.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 8/5/24.
    //

import SwiftUI
import Charts

struct HeadphoneDiffChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }

    var body: some View {
        ChartContainer(
            title: "Average Decibel Change",
            symbol: "ear.badge.waveform",
            subTitle: "Per WeekDay (Last 28 Days)",
            context: .headphones,
            isNav: false) {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no sound data from the Health App")
            } else {
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                ChartAnnotationView(data: selectedData, context: .headphones, style: ((selectedData.value) <= 0 ? .indigo : .purple))
                            }
                    }
                    ForEach(chartData) { DecibelDiff in
                        BarMark(
                            x: .value("Day", DecibelDiff.date, unit: .day),
                            y: .value("Decibel Diff", DecibelDiff.value)
                        )
                        .foregroundStyle(DecibelDiff.value <= 0 ? Color.indigo.gradient : Color.purple.gradient)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                        AxisValueLabel(format: .dateTime.day(), centered: true)
                            .offset(y: 12)
                    }
                }
                .chartYAxis{
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel()
                    }
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
    HeadphoneDiffChart(chartData: MockData.decibelDiffs)
}
