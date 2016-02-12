//
//  DateExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/9/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public func -(left:NSDate, right:NSDate) -> (month:Int, day:Int, year:Int, hour:Int, minute:Int, second:Int)
{
    return left.subtractDate(right)
}

public extension NSDate
{
    public func addDays(numberOfDays:Int) -> NSDate
    {
        let dayComponent = NSDateComponents()
        dayComponent.day = numberOfDays
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dayComponent, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    /// Is this day the same day as the other date? Ignoreing time
    /// :param:date The other day to compare this day to.
    public func isSameDay(date:NSDate) -> Bool
    {
        let calendar = NSCalendar.currentCalendar()
        let components1 = calendar.components([.Month, .Day, .Year], fromDate:self)
        let components2 = calendar.components([.Month, .Day, .Year], fromDate:date)
        
        return components1.month == components2.month &&
               components1.day == components2.day &&
               components1.year == components2.year
    }
    
    /// Subtract two dates and return them as a tuple. 
    /// :param: The other date to compare with
    /// :returns: The difference in the two dates.
    public func subtractDate(otherDate:NSDate) -> (month:Int, day:Int, year:Int, hour:Int, minute:Int, second:Int)
    {
        let calendar = NSCalendar.currentCalendar()
        let flags:NSCalendarUnit = [.Month, .Day, .Year, .Hour, .Minute, .Second]
        let components = calendar.components(flags, fromDate: self, toDate: otherDate, options: NSCalendarOptions(rawValue: 0))
        return (month:components.month,
            day:components.day,
            year:components.year,
            hour:components.hour,
            minute:components.minute,
            second:components.second)
    }
    
    public func toMonthDayYearHourMinutesSeconds() -> (month:Int, day:Int, year:Int, hour:Int, minutes:Int, seconds:Int) {
        
        let flags:NSCalendarUnit = [.Month, .Day, .Year, .Hour, .Minute, .Second]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        
        let m = components.month
        let d = components.day
        let y = components.year
        let h = components.hour
        let min = components.minute
        let s = components.second
        
        return (month:m, day:d, year:y, hour:h, minutes:min, seconds:s)
    }
    
    /**
     Extract out the m/d/y parts of a date into a Tuple
     - Returns:A tuple as three ints that include month day year
    */
    public func toMonthDayYear() -> (month:Int, day:Int, year:Int) {
        let flags:NSCalendarUnit = [.Month, .Day, .Year]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        let m = components.month
        let d = components.day
        let y = components.year
        return (month:m, day:d, year:y)
    }
    
    public func toJullianDayNumber() -> Double {
        
        let components = self.toMonthDayYear()
        
        let a = floor( Double((14 - components.month) / 12 ))
        let y = Double(components.year) + 4800.0 - a
        let m = Double(components.month) + 12.0 * a - 3.0
        
        var f:Double = (153.0 * m + 2.0) / 5.0
        f += 365.0 * y
        f += floor(y / 4.0)
        f -= floor(y / 100.0)
        f += floor(y / 400.0)
        f -= 32045
        
        let jdn:Double = Double(components.day) + f
        
        return jdn
    }
    
    public static func fromMonth(month:Int, day:Int, year:Int) -> NSDate? {
        let components = NSDateComponents()
        components.month = month
        components.day = day
        components.year = year
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
    
    public func fromDay(percentage:Double) -> NSDate? {
        
        let secondsInDay = Double(24 * 60 * 60)
        
        let secondsPct = Double(percentage * secondsInDay)
        
        let totalMinutes = secondsPct / 60.0
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        let s = secondsPct % 60.0
        
        let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        gregorian.timeZone = NSTimeZone(abbreviation: "GMT")!
        let components = NSDateComponents()
        
        let mdy = self.toMonthDayYear()
        
        components.month = mdy.month
        components.day = mdy.day
        components.year = mdy.year
        components.hour = Int(h)
        components.minute = Int(m)
        components.second = Int(s)
        
        return gregorian.dateFromComponents(components)        
    }
	
	/**
	Is this date between startDate and endDate
	*/
	public func isBetween(startDate: NSDate, endDate: NSDate) -> Bool {
		return timeIntervalSinceReferenceDate >= startDate.timeIntervalSinceReferenceDate &&
		       timeIntervalSinceReferenceDate <= endDate.timeIntervalSinceReferenceDate
	}

    
    

    
}