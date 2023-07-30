//
//  MeasurementTests.swift
//  TemperatureTrackerTests
//
//  Created by Sam Hui on 2023/07/22.
//

import CoreData
import XCTest
@testable import TemperatureTracker

final class MeasurementTests: BaseTestCase {
    func testCreatingMeasurement() {
        let count = 10

        for _ in 0..<count {
            _ = Monitoring(context: managedObjectContext)
        }

        XCTAssertEqual(dataController.count(
            for: Monitoring.fetchRequest()),
            count,
            "Expected \(count) measurement."
        )
    }

    func testDeletingCoupon() throws {
        dataController.createSampleData()

        let request = NSFetchRequest<Monitoring>(entityName: "Monitoring")
        let measurements = try managedObjectContext.fetch(request)

        dataController.delete(measurements[0])

        XCTAssertEqual(dataController.count(
            for: Monitoring.fetchRequest()),
            4,
            "There should be 4 measurements after deleting 1 from our sample data."
        )
    }
}
