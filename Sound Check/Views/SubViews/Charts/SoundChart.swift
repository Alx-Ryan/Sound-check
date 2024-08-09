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
    var averageSoundLevels: Double {
        Double(chartData.map { $0.value}.average)
    }

    var body: some View {
        let config = ChartContainerConfiguration(title: "Sound Levels",
                                                 symbol: "waveform",
                                                 subTitle: "Avg: \(averageSoundLevels.formatted(.number.precision(.fractionLength(2)))) Decibels",
                                                 context: .soundLevels,
                                                 isNav: true)
        ChartContainer(config: config) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .soundLevels, style: nil)
                }

                if !chartData.isEmpty {
                    RuleMark(y: .value("Average", averageSoundLevels))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                }

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
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no sound data from the Health App")
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
