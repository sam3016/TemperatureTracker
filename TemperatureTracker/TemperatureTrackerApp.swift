//
//  TemperatureTrackerApp.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/05.
//

import SwiftUI

@main
struct TemperatureTrackerApp: App {
    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                ContentView(calendar: .current)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}
