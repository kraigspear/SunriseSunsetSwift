//: Playground - noun: a place where people can play

import UIKit

let lat = 42.9612
let lng = -85.6557

let dateFormatter = NSDateFormatter()
dateFormatter.timeStyle = .ShortStyle

let sunriseSunset = SunriseSunset(lat: lat, lng: lng)
let sunriseText = dateFormatter.stringFromDate(sunriseSunset.sunrise)
let sunsetText = dateFormatter.stringFromDate(sunriseSunset.sunset)

print("Sunrise is at \(sunriseText), sunset is at \(sunsetText)")



