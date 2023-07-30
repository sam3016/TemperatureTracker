//
//  DetailView.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/16.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            if let measurement = dataController.selectedMeasurement {
                EditingView(monitoring: measurement)
            } else {
                NoMeasurementView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
