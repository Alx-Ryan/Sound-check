//
//  SoundChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import SwiftUI
import Charts

struct SoundChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }

    var body: some View {
        ChartContainer(
            title: "Sound Levels",
            symbol: "waveform",
            subTitle: "Avg: \(Double(ChartHelper.averageValue(for: chartData)).formatted(.number.precision(.significantDigits(4)))) Decibels",
            context: .soundLevels,
            isNav: true) {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no sound data from the Health App")
                } else {
                    Chart {
                        if let selectedData {
                            RuleMark(x: .value("Selected Metric", selectedData.date, unit: .day))
                                .foregroundStyle(Color.secondary.opacity(0.3))
                                .offset(y: -10)
                                .annotation(
                                    position: .top,
                                    alignment: .center,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                        ChartAnnotationView(data: selectedData, context: .soundLevels, style: nil)
                                    }
                        }

                        RuleMark(y: .value("Average", ChartHelper.averageValue(for: chartData)))
                            .foregroundStyle(Color.secondary)
                            .lineStyle(.init(lineWidth: 1, dash: [5]))

                        ForEach(chartData) { decibel in
                            PointMark(
                                x: .value("Date", decibel.date, unit: .day),
                                y: .value("Decibels", decibel.value)
                            )
                            .opacity(rawSelectedDate == nil || decibel.date == selectedData?.date ? 1.0 : 0.3)
                            LineMark(
                                x: .value("Date", decibel.date, unit: .day),
                                y: .value("Decibels", decibel.value)
                            )
                            .opacity(0.3)
                        }
                        .foregroundStyle(Color.pink.gradient)
                    }
                    .frame(height: 150)
                    .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))

                    .chartXAxis{
                        AxisMarks{
                            AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                        }
                    }
                    .chartYAxis{
                        AxisMarks { value in
                            AxisGridLine()
                                .foregroundStyle(Color.secondary.opacity(0.3))

                            AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
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
    SoundChart(chartData: ChartHelper.convert(data: MockData.EnvironmentdB))
        .padding()
}
