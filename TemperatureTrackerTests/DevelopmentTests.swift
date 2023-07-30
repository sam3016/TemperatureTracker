//
//  DevelopmentTests.swift
//  TemperatureTrackerTests
//
//  Created by Sam Hui on 2023/07/23.
//

import CoreData
import XCTest
@testable import TemperatureTracker

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() {
        dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Monitoring.fetchRequest()), 5, "There should be 5 sample measurement.")
    }

    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(
            for: Monitoring.fetchRequest()),
            0,
            "deleteAll() should leave 0 sample measurements."
        )
    }

    func testExampleMeasurementHasNormalTemperature() {
        let measurement = Monitoring.example
        XCTAssertEqual(measurement.measurementTemperature, 35.7, "The example measurement should be 35.7.")
    }
}
