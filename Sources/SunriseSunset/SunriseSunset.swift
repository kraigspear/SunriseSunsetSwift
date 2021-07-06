
import Foundation
import CoreLocation
import SpearDates

private func radians(_ value: Double) -> Double {
    return value * .pi / 180.0
}

private func degrees(_ value: Double) -> Double {
    return value * 180.0 / .pi
}

// Calculate the sunrise & sunset at a given Coordinate.
public struct SunriseSunset {

    private struct SunriseCalc {
        let date: Date
        let julianCentury: Double
        let coordinate: CLLocationCoordinate2D

        init(date: Date,
             coordinate: CLLocationCoordinate2D) {
            self.date = date
            self.julianCentury = date.julianCentury
            self.coordinate = coordinate
        }

        private var obliqEcliptic: Double {
            23+(26+((21.448-julianCentury*(46.815+julianCentury*(0.00059-julianCentury*0.001813))))/60)/60
        }

        private var obliqCorr: Double {
            obliqEcliptic+0.00256*cos(radians(125.04-1934.136*julianCentury))
        }

        private var varY: Double {
            tan(radians(obliqCorr/2))*tan(radians(obliqCorr/2))
        }

        private var longSun: Double {
            let s = 280.46646+julianCentury*(36000.76983 + julianCentury*0.0003032)
            return s.truncatingRemainder(dividingBy: 360)
        }

        private var accentEarthOrbit: Double {
            0.016708634-julianCentury*(0.000042037+0.0000001267*julianCentury)
        }

        private var anomSun: Double {
            357.52911 + julianCentury*(35999.05029 - 0.0001537 * julianCentury)
        }

        private var eqOfTime: Double {

            let u2 = self.varY
            let i2 = self.longSun

            let k2 = self.accentEarthOrbit
            let j2 = self.anomSun

            let step1 = sin(radians(i2) * 2) * u2
            let step2 = k2 * 2
            let step3 = sin(radians(j2))
            let step4 = step2 * step3
            let step5 = step1 - step4
            let step6 = 4 * k2
            let step7 = step6 * u2
            let step8 = radians(j2)
            let step9 = sin(step8)
            let step10 = step7 * step9
            let step11 = radians(i2)
            let step12 = cos(2*step11)
            let step13 = step10 * step12
            let step14 = step5 + step13
            let step15 = 0.5 * u2
            let step16 = step15 * u2
            let step17 = 4 * step11
            let step18 = sin(step17)
            let step19 = step16 * step18
            let step20 = step14 - step19
            let step21 = 1.25 * k2
            let step22 = step21 * k2
            let step23 = sin(radians(j2) * 2)
            let step24 = step22 * step23
            let step25 = step20 - step24
            let step26 = degrees(step25)
            let step27 = step26 * 4

            return step27
        }

        private var solarNoon: Double {
            (720 - 4 * coordinate.longitude - eqOfTime)/1440
        }

        private var sunEqOfCenter: Double {
            sin(radians(anomSun))*(1.914602-julianCentury*(0.004817+0.000014*julianCentury))+sin(radians(2*anomSun))*(0.019993-0.000101*julianCentury)+sin(radians(3*anomSun))*0.000289
        }

        private var sunTrueLong: Double {
            longSun + sunEqOfCenter
        }

        private var sunAppLong: Double {
            sunTrueLong-0.00569-0.00478*sin(radians(125.04-1934.136*julianCentury))
        }

        private var sunDeclin: Double {
            return degrees(asin(sin(radians(obliqCorr))*sin(radians(sunAppLong))))
        }

        private var sunriseDegrees: Double {

            let t2 = sunDeclin

            let step1 = radians(90.833)
            let step2 = cos(step1)
            let step3 = radians(coordinate.latitude)
            let step4 = cos(step3)
            let step5 = radians(t2)
            let step6 = cos(step5)
            let step7 = step4 * step6
            let step8 = step2 / step7
            let step9 = tan(step3)
            let step10 = tan(step5)
            let step11 = step9 * step10
            let step12 = step8 - step11
            let step13 = acos(step12)
            let step14 = degrees(step13)

            return step14
        }

        private func dateFromPercentage(_ percentage: Double) -> Date? {
            let secondsInDay = Double(24 * 60 * 60)
            let secondsPct = Double(percentage * secondsInDay)
            let totalMinutes = secondsPct / 60.0
            let h = totalMinutes / 60
            let m = totalMinutes.truncatingRemainder(dividingBy: 60)
            let s = secondsPct.truncatingRemainder(dividingBy: 60.0)

            var gregorianCalendar = Calendar(identifier: .gregorian)
            gregorianCalendar.timeZone = TimeZone(abbreviation: "GMT")!

            var components = DateComponents()
            let mdy = date.toMonthDayYear()
            components.month = mdy.month
            components.day = mdy.day
            components.year = mdy.year
            components.hour = Int(h)
            components.minute = Int(m)
            components.second = Int(s)

            return gregorianCalendar.date(from: components)

        }

        func calc() -> (sunrise: Date, sunset: Date) {
            let sunrisePercentage = self.solarNoon - self.sunriseDegrees * 4 / 1440
            let sunrise = dateFromPercentage(sunrisePercentage)!
            let sunsetPercentage = self.solarNoon + self.sunriseDegrees * 4 / 1440
            let sunset = dateFromPercentage(sunsetPercentage)!
            return (sunrise: sunrise, sunset: sunset)
        }
    }

    //MARK: - Sunrise / Sunset

    /**
     Calculate the Sunrise & Sunset times for a given CLLocationCoordinate2D

     Swift implementation of the NOAA sunrise / sunset calculations found at
     https://gml.noaa.gov/grad/solcalc/calcdetails.html

     - parameters:
     - date: Date of interest to calculate the sunrise and sunset times for
     - coordinate: The Coordinate of interest to get the sunrise and sunset times for

     ### Example
     ```swift
     let cupertino = CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322)
     let result = SunriseSunset.calc(date: Date(), coordinate: cupertino)

     print("Sunrise is at: \(result.sunrise)"
     print("Sunset is at: \(result.sunset)"
     ```
     */
    public static func calc(date: Date, coordinate: CLLocationCoordinate2D) -> (sunrise: Date, sunset: Date) {
        SunriseCalc(date: date, coordinate: coordinate).calc()
    }
}

private extension Date {
    var julianCentury: Double {
        (self.toJulianDayNumber() - 2451545) / 36525
    }
}
