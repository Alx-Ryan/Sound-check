//
//  HeadphoneChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/31/24.
//

import SwiftUI
import Charts

struct HeadphoneChart: View {

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Headphone dB", systemImage: "ear.badge.waveform")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)

                        Text("Avg: Decibels")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            Chart {
                ForEach(chartData) { headphonedB in
                    LineMark(
                        x: .value("Day", headphonedB.date, unit: .day),
                        y: .value("Value", headphonedB.value)
                    )
                    .foregroundStyle(.indigo.gradient)
                    AreaMark(
                        x: .value("Day", headphonedB.date, unit: .day),
                        y: .value("Value", headphonedB.value)
                    )
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    HeadphoneChart(selectedStat: .headphones, chartData: MockData.HeadphonedB)
}
