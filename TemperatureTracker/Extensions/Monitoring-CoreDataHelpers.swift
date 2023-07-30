//
//  Measurement-CoreDataHelpers.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/06.
//

import Foundation

extension Monitoring {
    var measurementID: UUID {
        id ?? UUID()
    }

    var measurementCreationDate: Date {
        get { creationDate ?? .now }
        set { creationDate = newValue }
    }

    var measurementDate: Date {
        get { date ?? .now }
        set { date = newValue }
    }

    var measurementTemperature: Double {
        get { temperature }
        set { temperature = newValue }
    }

    static var example: Monitoring {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let measurement = Monitoring(context: viewContext)
        measurement.id = UUID()
        measurement.creationDate = .now
        measurement.date = .now
        measurement.temperature = 35.7

        return measurement
    }
}

extension Monitoring: Comparable {
    public static func <(lhs: Monitoring, rhs: Monitoring) -> Bool {
        let left = lhs.measurementCreationDate
        let right = rhs.measurementCreationDate

        return left < right
    }
}
