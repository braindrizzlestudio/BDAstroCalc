//
//  BDAstroCalc.swift
//
//  v1.0
//

import CoreLocation

struct BDAstroCalc {
    
    
    // MARK: - Properties and Constants
    
    
    /// The obliquity of Earth
    static let obliquityOfEarth = rad * 23.4397
    
    
    /// Multiplier for conversion from degrees to radians
    static let rad = M_PI / 180
    
    /// A parameter used for finding the time of a solar transit near a Julian Date.
    // See Table 6 of http://aa.quae.nl/en/reken/zonpositie.html
    static let J0 = 0.0009
    
    /// The number of Julian days at January 1, 2000.
    static let J2000 = 2451545.0
    

    
    
    // MARK: - Date/Time Calculations
    
    
    /**
    
    The number of days since the Gregorian year 2000 began.
    
    :param: date A date in Unix Time.
    
    :returns: The number of days since the year 2000.
    
    */
    static func daysSinceJan12000 (#date: NSDate) -> Double {
        
        return toJulian(date: date) - J2000
    }
    
    
    /**
    
    Gives a date a certain number of hours after a given date/time.
    
    :param: date A date.
    
    :param: hours The number of hours after the given date/time that will be returned.
    
    :returns: An NSDate that is the given number of hours after the given date.
    
    */
    static func hoursLater (#date: NSDate, hours: Double) -> NSDate {
        
        let hourSeconds = 60.0 * 60.0
        
        return NSDate(timeIntervalSince1970: date.timeIntervalSince1970 + hours * hourSeconds)
    }
    
    
    /**
    
    The number of days since the beginning of the Julian Period.
    
    :param: date A Gregorian date.
    
    :returns: The number of days since the beginning of the Julian Period.
    
    */
    static func toJulian (#date: NSDate) -> Double {
        
        let daySeconds : Double = 60 * 60 * 24
        let J1970 = 2440588.0
        
        return date.timeIntervalSince1970 / daySeconds - 0.5 + J1970
        
    }
    
    
    /**
    
    The Gregorian date of a given number of Julian Days.
    
    :param: julianDays A number of days since the beginning of the Julian Period.
    
    :returns: A Gregorian calendar date from a number of Julian Days.
    
    */
    static func fromJulian (#julianDays: Double) -> NSDate {
    
        let daySeconds : Double = 60 * 60 * 24
        let J1970 = 2440588.0
        
        return NSDate(timeIntervalSince1970: (julianDays + 0.5 - J1970) * daySeconds)
    }
    
    
    
    // MARK: - General Position Calculations
    
    
    /**
    
    Calculates the altitude of a celestial body.
    
    :param: hourAngle An angle in radians. The hour angle indicates how far the celestial body has passed beyond the celestial meridian.
    
    :param: latiude The latitude of observation in radians.
    
    :param: declination The declination in radians.
    
    :returns: The altitude above the horizon in radians.
    
    */
    static func altitude (#hourAngle: Double, latitude: Double, declination: Double) -> Double {
        
        return asin(sin(latitude) * sin(declination) + cos(latitude) * cos(declination) * cos(hourAngle))
        
    }
    
    
    /**
    
    Calculates the azimuth of a celestial body in radians, measured from South to West.
    
    :param: hourAngle An angle in radians, measured. The hour angle indicates how far the celestial body has passed beyond the celestial meridian.
    
    :param: latiude The latitude of observation in radians.
    
    :param: declination The declination in radians.
    
    :returns: The azimuth of the body in radians, measured from South to West. (Note that it it standard to measure from North to East; simply add/subtract M_PI to the result if you need to conform.)
    
    */
    static func azimuth (#hourAngle: Double, latitude: Double, declination: Double) -> Double {
        
        return atan2(sin(hourAngle), cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude))
    }
    
    
    
    /**
    
    Calculates declination given latitude and longitude.
    
    :param: latitude The latitude in radians.
    
    :param: longitude The longitude in radians.
    
    :returns: The declination in radians.
    
    */
    static func declination (#latitude: Double, longitude: Double) -> Double {
        
        return asin(sin(latitude) * cos(obliquityOfEarth) + cos(latitude) * sin(obliquityOfEarth) * sin(longitude))
    }
    

    
    /**
    
    Calculates right ascension given latitude and longitude.
    
    :param: latitude The latitude in radians.
    
    :param: longitude The longitude in radians.
    
    :returns: The right asnension in radians.
    
    */
    static func rightAscension (#latitude: Double, longitude: Double) -> Double {
                
        return atan2(sin(longitude) * cos(obliquityOfEarth) - tan(latitude) * sin(obliquityOfEarth), cos(longitude))
    }
    
    
    /**
    
    The sidereal time.
    
    :param: daysSinceJan12000 The number of days since January 1, 2000.
    
    :param: longitude The longitude west of the prime meridian in radians.
    
    :returns: The sidereal time in radians.
    
    */
    static func siderealTime (#daysSinceJan12000: Double, longitude: Double) -> Double {
        
        return rad * (280.16 + 360.9856235 * daysSinceJan12000) - longitude
    }

    
    
    // MARK: - Moon Calculations
    

    /**
    
    The geocentric ecliptic coordinates of the moon.
    
    :param: daysSinceJan12000 The number of days since Jan 1, 2000.
    
    :returns: The right ascension and declination in radians, and distance in kilometers, of the moon for the given date.
    
    */
    static func moonCoordinates (#daysSinceJan12000: Double) -> (declination: Double, distance: Double, rightAscension: Double) {
        
        let eclipticLongitude = rad * (218.316 + 13.176396 * daysSinceJan12000)
        let meanAnomaly = rad * (134.963 + 13.064993 * daysSinceJan12000)
        let meanDistance = rad * (93.272 + 13.229350 * daysSinceJan12000)
        
        let longitude = eclipticLongitude + rad * 6.289 * sin(meanAnomaly)
        let latitude = rad * 5.128 * sin(meanDistance)
        let distance = 385001 - 20905 * cos(meanAnomaly)
        
        return (declination(latitude: latitude, longitude: longitude), distance, rightAscension(latitude: latitude, longitude: longitude)	)
    }
    
    
    /**
    
    The moons position on a given date from a given location.
    
    :param: date A date.
    
    :location: A location. Requires CLLocationCoordinate2D to reduce confusion, as these are in degrees while other methods require radians.
    
    :returns: The moon's altitude and azimuth in radians, and distance in kilometers.
    
    */
    static func moonPosition(#date: NSDate, location: CLLocationCoordinate2D) -> (altitude: Double, azimuth: Double, distance: Double) {
        
        let longitude = rad * -location.longitude
        let phi = rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        
        let coordinates = moonCoordinates(daysSinceJan12000: days)
        
        let hourAngle = siderealTime(daysSinceJan12000: days, longitude: longitude) - coordinates.rightAscension
        
        var moonAltitude = altitude(hourAngle: hourAngle, latitude: phi, declination: coordinates.declination)
        moonAltitude = moonAltitude + rad * 0.017 / tan(moonAltitude + rad * 10.26 / (moonAltitude + rad * 5.10))
        
        //println("Time: \(date),mAltitude: \(moonAltitude / rad)")
        
        return (moonAltitude, azimuth(hourAngle: hourAngle, latitude: phi, declination: coordinates.declination), coordinates.distance)
    }
    

    
    
    /**
    
    The fraction of the moon's visible surface that is illuminated, its phase, and the midpoint angle, going east, of the illuminated limb.
    
    :param: A date.
    
    :returns: The fraction of the moon illuminated is a number from 0 to 1, where 0 is a new moon and 1 is a full moon. The phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning. The angle is the midpoint of the illuminated limb of the moon going east, in radians.
    
    */
    static func moonPhase (#date: NSDate) -> (fractionOfMoonIlluminated: Double, phase: Double, angle: Double) {
        
        let days = daysSinceJan12000(date: date)
        let sunCoords = sunCoordinates(daysSinceJan12000: days)
        let moonCoords = moonCoordinates(daysSinceJan12000: days)
        
        let sunDistance = 149598000.0   // 1 AU
        
        // Geocentric elongation of the Moon from the Sun
        let phi = acos(sin(sunCoords.declination) * sin(moonCoords.declination) + cos(sunCoords.declination) * cos(moonCoords.declination) * cos(sunCoords.rightAscension - moonCoords.rightAscension))
        
        // Selenocentric elongation of the Earth from the Sun
        let inc = atan2(sunDistance * sin(phi), moonCoords.distance - sunDistance * cos(phi))
        
        
        let angle = atan2(cos(sunCoords.declination) * sin(sunCoords.rightAscension - moonCoords.rightAscension), sin(sunCoords.declination) * cos(moonCoords.declination) - cos(sunCoords.declination) * sin(moonCoords.declination) * cos(sunCoords.rightAscension - moonCoords.rightAscension))
        
        let fractionOfMoonIlluminated = (1 + cos(inc)) / 2
        
        let phase = 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Double(M_PI)
        
        return (fractionOfMoonIlluminated, phase, angle)
    }
    
    
    
    /**
    
    The moon's rise and set times for a given date and location.
    
    :param: date A date.
    
    :param: location A location. Requires CLLocationCoordinate2D to reduce confusion, as these are in degrees while other methods require radians.
    
    :returns: The rise and set NSDates of the moon, if there are any. If the moon is always up for the given date: returns NSDate.distantFuture() for both rise and set. If the moon is always down for the given date: returns NSDate.distantPast() for both rise and set.
    
    */
    static func moonRiseAndSet (#date: NSDate, location: CLLocationCoordinate2D) -> (rise: NSDate, set: NSDate) {
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let day = calendar.dateFromComponents(dateComponents)!
        
        let hc = 0.133 * rad
        var h0 = moonPosition(date: day, location: location).altitude - hc
        
        var rise : Double?
        var set : Double?
        
        var a:Double, b:Double, d:Double, h1:Double, h2:Double, roots:Int, xe:Double
        var x1 = 0.0, x2 = 0.0, ye = 0.0
		
        for var i : Double = 1; i <= 24; i += 2 {
            
            h1 = moonPosition(date: hoursLater(date: day, hours: i), location: location).altitude - hc
            h2 = moonPosition(date: hoursLater(date: day, hours: i + 1), location: location).altitude - hc
            
            a = (h0 + h2) / 2 - h1
            b = (h2 - h0) / 2
            xe = -b / (2 * a)
            ye = (a * xe + b) * xe + h1
            d = b * b - 4 * a * h1
			
            roots = 0
            
            if d >= 0 {
                
                let dx = sqrt(d) / (abs(a) * 2)
                x1 = xe - dx
                x2 = xe + dx
                if abs(x1) <= 1 { roots++ }
                if abs(x2) <= 1 { roots++ }
                if x1 < -1 { x1 = x2 }
            }
            
            if roots == 1 {
                
                if h0 < 0 { rise = i + x1 }
                else { set = i + x1 }
                
            } else if roots == 2 {
                
                rise = i + (ye < 0 ? x2 : x1)
                set = i + (ye < 0 ? x1 : x2)
            }
            
            if rise != nil && set != nil { break }
            
            h0 = h2
        }
        
        var result = (rise: day, set: day)
        
        if rise != nil { result.rise = hoursLater(date: day, hours: rise!) }
        if set != nil { result.set = hoursLater(date: day, hours: set!) }
        
        if rise == nil && set == nil {
            
            if ye > 0 {
                
                result.rise = NSDate.distantFuture() as! NSDate
                result.set = NSDate.distantFuture() as! NSDate
                
            } else {
                
                result.rise = NSDate.distantPast() as! NSDate
                result.set = NSDate.distantPast() as! NSDate
            }
        }
        
        return result
    }

    
    
    // MARK: - Sun Calculations
    
    
    /**
    
    The approximate solar transit, the time at which it passes through the celestial meridian.
    
    :param: julianCycleNumber The Julian cycle number.
    
    :param: longitude The longitude in radians.
    
    :param: targetHourAngle The target hour angle.
    
    :returns: The approximate solar transit.
    
    */
    static func approximateTransit (#julianCycleNumber: Double, longitude: Double, targetHourAngle: Double) -> Double {
        
        return J0 + julianCycleNumber + (targetHourAngle + longitude) / (2 * M_PI)
    }
    
    
    /**
    
    The ecliptic longitude: the position along the ecliptic relative to the vernal equinox.
    
    :param: meanAnomaly The mean anomaly: the positon a planet/satellite would have relative to its perihelion if the orbit of the planet were a circle.
    
    :returns: The ecliptic longitude in radians.
    
    */
    static func eclipticLongitude (#meanAnomaly: Double) -> Double {
        
        // Equation of Center
        let center = rad * (1.9148 * sin(meanAnomaly) + 0.02 * sin(2 * meanAnomaly) + 0.0003 * sin(3 * meanAnomaly))
        
        // Perihelion of Earth
        let perihelion = rad * 102.9372
        
        return meanAnomaly + center + perihelion + Double(M_PI)
    }
    
    
    /**
    
    The hour angle: the difference in right ascension between a body and the meridian of right ascension that is due south at that time.
    
    :param: altitude The altitude of the body.
    
    :latitude: The latitude.
    
    :declination: The declination.
    
    :returns: The hour angle in radians.
    
    */
    static func hourAngle (#altitude: Double, latitude: Double, declination: Double) -> Double {
        
        return acos((sin(altitude) - sin(latitude) * sin(declination)) / (cos(latitude) * cos(declination)))
    }
    
    
    /**
    
    The Julian cycle number. (See http://aa.quae.nl/en/reken/zonpositie.html )
    
    :param: daysSinceJan12000 The number of days since January 1, 2000.
    
    :param: longitude The longitude in radians.
    
    :returns: The Julian cycle number.
    
    */
    static func julianCycle (#daysSinceJan12000: Double, longitude: Double) -> Double {
        
        return round(daysSinceJan12000 - J0 - longitude / (2 * M_PI))
    }
    
    
    /**
    
    The Julian time of the sunset.
    
    :param: altitude The altitude of the sun in radians.
    
    :param: declination The declination of the sun in radians.
    
    :param: latitude The latitude in radians.
    
    :param: longitude The longitude in radians.
    
    :param: julianCycleNumber The Julian cycle number.
    
    :param: meanAnomaly The mean anomaly.
    
    :param: meanLongitude The mean longitude.
    
    :returns: The Julian time of the sunset.
    
    */
    static func julianSet (#altitude: Double, declination: Double, latitude: Double, longitude: Double, julianCycleNumber: Double, meanAnomaly: Double, meanLongitude: Double) -> Double {
        
        let hrAngle = hourAngle(altitude: altitude, latitude: latitude, declination: declination)
        let approxTransit = approximateTransit(julianCycleNumber: julianCycleNumber, longitude: longitude, targetHourAngle: hrAngle)
        
        return julianSolarTransit(approximateTransit: approxTransit, longitude: meanLongitude, meanAnomaly: meanAnomaly)
    }
    
    
    /**
    
    The Julian date of the solar transit.
    
    :param: approximateTransit The approximate solar transit.
    
    :param: meanLongitude The mean longitude in radians.
    
    :param: meanAnomaly The mean anomaly in radians.
    
    :returns: The Julian date of the solar transit.
    
    */
    static func julianSolarTransit (#approximateTransit: Double, longitude: Double, meanAnomaly: Double) -> Double {
    
        return J2000 + approximateTransit + 0.0053 * sin(meanAnomaly) - 0.0069 * sin(2 * longitude)
    }
    
    
    /**
    
    The solar mean anomaly.
    
    :param: daysSinceJan12000 The number of days since January 1, 2000.
    
    :returns: The solar mean anomaly in radians.
    
    */
    static func solarMeanAnomaly (#daysSinceJan12000: Double) -> Double {
        
        return rad * (357.5291 + 0.98560028 * daysSinceJan12000)
    }
    

    /**
    
    The sun's right ascension and declination on a given day.
    
    :param: daysSinceJan12000 The number of days since January 1, 2000.
    
    :returns: The sun's right ascension and declination in radians.
    
    */
    static func sunCoordinates (#daysSinceJan12000: Double) -> (declination: Double, rightAscension: Double) {
        
        let solarMA = solarMeanAnomaly(daysSinceJan12000: daysSinceJan12000)
        let eLongitude = eclipticLongitude(meanAnomaly: solarMA)
        
        return (declination(latitude: 0, longitude: eLongitude), rightAscension(latitude: 0, longitude: eLongitude))
        
    }
    
    
    /**
    
    The sun's position on a given date from a given location.
    
    :param: date A date.
    
    :param: A location. Requires CLLocationCoordinate2D to reduce confusion, as these are in degrees while other methods require radians.
    
    :returns: The sun's azimuth and altitude in radians. (Note:
    
    */
    static func sunPosition (#date: NSDate, location: CLLocationCoordinate2D) -> (altitude: Double, azimuth: Double) {
        
        let longitude = rad * -location.longitude
        let latitude = rad * location.latitude
        let days = daysSinceJan12000(date: date)
        
        let coordinates = sunCoordinates(daysSinceJan12000: days)
        let hourAngle = siderealTime(daysSinceJan12000: days, longitude: longitude) - coordinates.rightAscension
        
        return (altitude(hourAngle: hourAngle, latitude: latitude, declination: coordinates.declination),
            azimuth(hourAngle: hourAngle, latitude: latitude, declination: coordinates.declination))
    }
    
    
    /**
    
    The sun's times of rise and set for a given date and location.
    
    :param: date A date.
    
    :param: location A location.
    
    :returns: The sun's rise, set, solar noon, and nadir for the given date and location.
    
    */
    static func sunRiseAndSet (#date: NSDate, location: CLLocationCoordinate2D) -> (rise: NSDate, set: NSDate, solarNoon: NSDate, nadir: NSDate) {
        
        // Standard altitude of the end of sunrise and start of sunset
        let sunRiseEndSetStartAltitude = -0.3
        
        let longitude = rad * -location.longitude
        let latitude = rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        let julCycle = julianCycle(daysSinceJan12000: days, longitude: longitude)
        let approxTransit = approximateTransit(julianCycleNumber: julCycle, longitude: longitude, targetHourAngle: 0)
        
        let meanAnomaly = solarMeanAnomaly(daysSinceJan12000: days)
        let eclipLongitude = eclipticLongitude(meanAnomaly: meanAnomaly)
        let declinatn = declination(latitude: 0, longitude: eclipLongitude)
        
        let julianNoon = julianSolarTransit(approximateTransit: approxTransit, longitude: eclipLongitude, meanAnomaly: meanAnomaly)
        
        let solarNoon = fromJulian(julianDays: julianNoon)
        let nadir = fromJulian(julianDays: julianNoon - 0.5)
        var result = (rise: date, set: date, solarNoon: solarNoon, nadir: nadir)
        
        var i:Int, length:Int, time:Double, julinSet:Double, julianRise:Double

        julinSet = julianSet(altitude: rad * sunRiseEndSetStartAltitude,
            declination: declinatn,
            latitude: latitude,
            longitude: longitude,
            julianCycleNumber: julCycle,
            meanAnomaly: meanAnomaly,
            meanLongitude: eclipLongitude)
        
        julianRise = julianNoon - (julinSet - julianNoon)
        
        result.rise = fromJulian(julianDays: julianRise)
        result.set = fromJulian(julianDays: julinSet)
        
        return result
    }
    
    
    /**
    
    Various significant times related to the sun's altitude. Additions can be hardcoded into the method.
    
    :param: date A date.
    
    :param: location A location.
    
    :returns: The method returns a dictionary of significant times during the day. Currently returns: sunriseStart, sunriseEnd, sunsetStart, sunsetEnd, dawn, dusk, nauticalDawn, nauticalDusk, nightStart, nightEnd, goldenHourStart, goldenHourEnd. The time are accessed via a String and given as an NSDate.
    
    */
    static func sunSignificantTimes (#date: NSDate, location: CLLocationCoordinate2D) -> [String: NSDate] {

        // Various standard altitudes of the sun. Feel free to add your own times, in the same format, to this array--they'll be added to the returned dictionary.
        let times = [
            [-0.833, "sunriseStart", "sunsetEnd"],
            [-0.3, "sunriseEnd", "sunsetStart"],
            [-6.0, "dawn", "dusk"],
            [-12.0, "nauticalDawn", "nauticalDusk"],
            [-18.0, "nightEnd", "nightStart"],
            [6.0, "goldenHourEnd", "goldenHourStart"]
        ]
        
        let longitude = rad * -location.longitude
        let latitude = rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        let julCycle = julianCycle(daysSinceJan12000: days, longitude: longitude)
        let approxTransit = approximateTransit(julianCycleNumber: julCycle, longitude: longitude, targetHourAngle: 0)
        
        let meanAnomaly = solarMeanAnomaly(daysSinceJan12000: days)
        let eclipLongitude = eclipticLongitude(meanAnomaly: meanAnomaly)
        let declinatn = declination(latitude: 0, longitude: eclipLongitude)
        
        let julianNoon = julianSolarTransit(approximateTransit: approxTransit, longitude: eclipLongitude, meanAnomaly: meanAnomaly)
        
        let solarNoon = fromJulian(julianDays: julianNoon)
        let nadir = fromJulian(julianDays: julianNoon - 0.5)
        var result = [String: NSDate]()
        
        var i:Int, julianEnd=0.0, julianStart:Double, length:Int
        
        for i = 0, length = times.count; i < length; i++ {
            
            let time = times[i]
            
            if let altitude = time[0] as? Double {
                julianEnd = julianSet(altitude: rad * altitude,
                    declination: declinatn,
                    latitude: latitude,
                    longitude: longitude,
                    julianCycleNumber: julCycle,
                    meanAnomaly: meanAnomaly,
                    meanLongitude: eclipLongitude)
            }
            
            julianStart = julianNoon - (julianEnd - julianNoon)
            
            if let earlierTime = time[1] as? String {
                result[earlierTime] = fromJulian(julianDays: julianStart)
            }
            if let laterTime = time[2] as? String {
                result[laterTime] = fromJulian(julianDays: julianEnd)
            }
        }
        
        return result
    }
}