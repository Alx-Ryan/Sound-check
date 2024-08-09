//
//  ChartContainer.swift
//  Sound Check
//
//  Created by Alex Ryan on 8/7/24.
//

import SwiftUI

enum ChartType {
    case soundChart(average: Double)
    case soundPie
    case headphoneLine(average: Double)
    case headphoneDiff
}

struct ChartContainer<Content: View>: View {

    let chartType: ChartType
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }

            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }

    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .soundLevels ? .pink : .indigo)

            Text(subTitle)
                .font(.caption)
        }
    }

    var isNav: Bool {
        switch chartType {
            case .soundChart(_), .headphoneLine(_):
                return true
            case .soundPie, .headphoneDiff:
                return false
        }
    }

    var context: HealthMetricContext {
        switch chartType {
            case .soundChart(_), .soundPie:
                    .soundLevels
            case .headphoneLine(_), .headphoneDiff:
                    .headphones
        }
    }

    var title: String {
        switch chartType {
            case .soundChart(_):
                "Environment Sound Levels"
            case .soundPie:
                "Sound Averages"
            case .headphoneLine(_):
                "Headphone dB"
            case .headphoneDiff:
                "Average Decibel Change"
        }
    }

    var symbol: String {
        switch chartType {
            case .soundChart(_):
                "waveform"
            case .soundPie:
                "chart.dots.scatter"
            case .headphoneLine(_):
                "ear.badge.waveform"
            case .headphoneDiff:
                "ear.badge.waveform"
        }
    }

    var subTitle: String {
        switch chartType {
            case .soundChart(let average):
                "Avg: \(average.formatted(.number.precision(.fractionLength(2)))) Decibels"
            case .soundPie:
                "Last 28 Days"
            case .headphoneLine(let average):
                "Avg: \(average.formatted(.number.precision(.fractionLength(2)))) Decibels, Goal: 55"
            case .headphoneDiff:
                "Per WeekDay (Last 28 Days)"
        }
    }
}

#Preview {
    Group {
        ChartContainer(chartType: .headphoneLine(average: 55)) {
            Text("Chart here")
                .frame(height: 150)
        ChartContainer(chartType: .headphoneDiff) {
            Text("Chart here")
                .frame(height: 150)
            }
        }
    }
    .padding()
}
