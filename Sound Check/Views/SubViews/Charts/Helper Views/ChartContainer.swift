//
//  ChartContainer.swift
//  Sound Check
//
//  Created by Alex Ryan on 8/7/24.
//

import SwiftUI

struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subTitle: String
    let context: HealthMetricContext
    let isNav: Bool
}

struct ChartContainer<Content: View>: View {

    let config: ChartContainerConfiguration
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
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
        NavigationLink(value: config.context) {
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
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .soundLevels ? .pink : .indigo)

            Text(config.subTitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(config: .init(title: "Test", symbol: "waveform", subTitle: "Test Sub", context: .soundLevels, isNav: true)) {
        Text("Chart here")
            .frame(height: 150)
    }
}
