//
//  ContentView.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Sound Levels", systemImage: "waveform")
                                    .font(.title3.bold())
                                    .foregroundStyle(.pink)

                                Text("Avg: Sound")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)

                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                    VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Label("Sound Averages", systemImage: "chart.dots.scatter")
                                    .font(.title3.bold())
                                    .foregroundStyle(.pink)

                                Text("Last 28 Days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        .padding(.bottom, 12)

                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    ContentView()
}
