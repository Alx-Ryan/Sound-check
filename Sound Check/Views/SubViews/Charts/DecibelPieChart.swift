//
//  DecibelPieChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import SwiftUI
import Charts

struct DecibelPieChart: View {

    @State private var rawSelectedChartValue: Double? = 0
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    var selectedWeekday: DateValueChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0

        return chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
    }

    var body: some View {
        ChartContainer(chartType: .soundPie) {
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Decibels", weekday.value),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                        angularInset: 2
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(8)
                    .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                    .accessibilityLabel(weekday.date.weekdayTitle)
                    .accessibilityValue("\(Int(weekday.value)) decibels")
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.numericText())


                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityHidden(true)
                        }
                    }
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.pie", title: "No Data", description: "There is no sound data from the Health App")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedChartValue) { oldValue, newValue in
            if newValue == nil  {
                rawSelectedChartValue = oldValue ?? 0
            }
        }
    }
}

#Preview {
    DecibelPieChart(chartData: ChartHelper.averageWeekdayCount(for: MockData.EnvironmentdB))
        .padding()
}
