    //
    //  DashboardView.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 7/5/24.
    //

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case soundLevels, headphones
    var id: Self { self }
    
    var title: String {
        switch self {
            case .soundLevels:
                return "Sound Levels"
            case .headphones:
                return "Headphones"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager

    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    
    @State private var isShowingPermissionSheet = false
    @State private var selectedStat: HealthMetricContext = .soundLevels

    var isSteps: Bool { selectedStat == .soundLevels }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    SoundChart(selectedStat: selectedStat, chartData: hkManager.environmentData)

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
            .task {
//                await hkManager.addSimulatorData()
                    await hkManager.fetchDecibelCount()
                    //await hkManager.fetchHeadphoneDecibelCount()
               // ChartMath.averageWeekdayCount(for: hkManager.environmentData)
                isShowingPermissionSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionSheet) {
                    // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }

    
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
