//
//  Sound_CheckApp.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/5/24.
//

import SwiftUI

@main
struct Sound_CheckApp: App {

    let hkManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
