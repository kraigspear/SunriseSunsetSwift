//
//  SunCalc.swift
//  WeatherKit
//
//  Created by Kraig Spear on 1/1/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation
import CoreLocation

func radians(value:Double) -> Double {
    return value * M_PI / 180.0
}

func degrees(value:Double) -> Double {
    return value * 180.0 / M_PI
}

public class SunriseSunset {
    let date:NSDate
    let lat:Double
    let lng:Double
    
    public init(date:NSDate, lat:Double, lng:Double) {
        self.date = date
        self.lat = lat
        self.lng = lng
    }
    
    public convenience init(lat: Double, lng: Double) {
        self.init(date: NSDate(), lat:lat, lng:lng)
    }
    
    public convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(date: NSDate(), lat: coordinate.latitude, lng: coordinate.longitude)
    }
    
    private lazy var jullian:Double = {
        return self.date.toJullianDayNumber()
    }()
    
    private lazy var jullianCentury:Double = {
        return (self.jullian - 2451545) / 36525
    }()
    
    private lazy var longSun: Double = {
        let s = 280.46646+self.jullianCentury*(36000.76983 + self.jullianCentury*0.0003032)
        return s % 360
    }()
    
    private lazy var anomSun: Double = {
        return 357.52911 + self.jullianCentury*(35999.05029 - 0.0001537 * self.jullianCentury)
    }()
    
    private lazy var accentEarthOrbit:Double = {
        return 0.016708634-self.jullianCentury*(0.000042037+0.0000001267*self.jullianCentury)
    }()
    
    private lazy var sunEqOfCenter: Double =  {
        return sin(radians(self.anomSun))*(1.914602-self.jullianCentury*(0.004817+0.000014*self.jullianCentury))+sin(radians(2*self.anomSun))*(0.019993-0.000101*self.jullianCentury)+sin(radians(3*self.anomSun))*0.000289
    }()

    private lazy var sunTrueLong: Double = {
        return self.longSun + self.sunEqOfCenter
    }()
    
    private lazy var sunTrueAnom: Double = {
        return self.anomSun + self.sunEqOfCenter
    }()
    
    private lazy var sunRadVector: Double = {
        return (1.000001018*(1-self.accentEarthOrbit*self.accentEarthOrbit))/(1+self.accentEarthOrbit*cos(radians(self.sunTrueAnom)))
    }()

    private lazy var sunAppLong: Double = {
        return self.sunTrueLong-0.00569-0.00478*sin(radians(125.04-1934.136*self.jullianCentury))
    }()
    
    private lazy var obliqEcliptic:Double = {
        return 23+(26+((21.448-self.jullianCentury*(46.815+self.jullianCentury*(0.00059-self.jullianCentury*0.001813))))/60)/60
    }()
    
    private lazy var obliqCorr:Double = {
        return self.obliqEcliptic+0.00256*cos(radians(125.04-1934.136*self.jullianCentury))
    }()
    
    private lazy var sunRtAcen:Double = {
        let p2 = 271.07
        let r2 = 23.43
        
        let c = cos(radians(r2))*sin(radians(p2))
        let c2 = cos(radians(p2))
        
        return degrees( atan2(c, c2) )
    }()
    
    private lazy var sunDeclin:Double = {
        return degrees(asin(sin(radians(self.obliqCorr))*sin(radians(self.sunAppLong))))
    }()
    
    private lazy var varY: Double = {
        return tan(radians(self.obliqCorr/2))*tan(radians(self.obliqCorr/2))
    }()
    
    private lazy var eqOfTime:Double = {
        
        let u2:Double = self.varY
        let i2:Double = self.longSun
        
        let k2:Double = self.accentEarthOrbit
        let j2:Double = self.anomSun
        
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
        
    }()
    
    private lazy var sunriseDegrees:Double = {
        
        let t2 = self.sunDeclin
        
        let step1 = radians(90.833)
        let step2 = cos(step1)
        let step3 = radians(self.lat)
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
    }()
    
    private lazy var solarNoon:Double = {
        let percentage = (720 - 4 * self.lng - self.eqOfTime)/1440
        return percentage
    }()
    
    public lazy var sunrise:NSDate = {
        let percentage = self.solarNoon - self.sunriseDegrees * 4 / 1440
        return self.date.fromDay(percentage)!
    }()
    
    public lazy var sunset:NSDate = {
        let percentage = self.solarNoon + self.sunriseDegrees * 4 / 1440
        return self.date.fromDay(percentage)!
    }()
    
    public func isDay(atDate: NSDate = NSDate()) -> Bool {
        return atDate.isBetween(sunrise, endDate: sunset)
    }
    
}
