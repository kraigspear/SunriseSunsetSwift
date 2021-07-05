import XCTest
import CoreLocation

@testable import SunriseSunset

// Unit Test check the results of this web site
//   https://sunrise-sunset.org/us/caledonia-mi

final class SunriseSunsetTests: XCTestCase {
    func testWhenDayIsJuly52021ThenSunriseSunsetIs610AndSunsetIs923() throws {


        let caledonia = CLLocationCoordinate2D(latitude: 42.7892, longitude: -85.5167)
        let july5th2021 = Date(timeIntervalSince1970: 1625514657)

        let result = SunriseSunset.calc(date: july5th2021, coordinate: caledonia)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")

        let sunrise = dateFormatter.string(from: result.sunrise)
        let sunset = dateFormatter.string(from: result.sunset)

        XCTAssertEqual("6:10:35 AM", sunrise)
        XCTAssertEqual("9:23:07 PM", sunset)
    }
}
