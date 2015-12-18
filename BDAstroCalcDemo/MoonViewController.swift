//
//  ViewController.swift
//  BDAstroCalcDemo
//
//
/**

The MIT License (MIT)

Copyright (c) 2015 Braindrizzle Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import CoreLocation
import UIKit

class MoonViewController: UIViewController {
    
    
    // MARK: - Constants and Properties
    
    // MARK: Constants
    
    /// For Conversion from radians to degrees.
    let radiansToDegrees = 180 / M_PI
    
    
    // MARK: Date Picker
    
    let datePicker = UIDatePicker()
    
    
    // MARK: Labels
    
    let altitudeLabel = UILabel()
    let azimuthLabel = UILabel()
    let declinationLabel = UILabel()
    let headingLabel = UILabel()
    let phaseIlluminationLabel = UILabel()
    let phasePhaseLabel = UILabel()
    let phaseAngleLabel = UILabel()
    let rightAscensionLabel = UILabel()
    let riseLabel = UILabel()
    let setLabel = UILabel()
    
    
    // MARK: - View Controller
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        setupDatePicker()
        
        setupHeading()
        
        setupLabels()
        
        updateLabels()
    }
    
    
    // MARK: - Setup
    
    
    // MARK: DatePicker
    
    /// DatePicker calls updateLabels, which updates the text of all labels for the new date.
    func setupDatePicker () {
        
        let datePickerFrame = CGRect(x: 0, y: self.view.bounds.size.height * 0.5, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.4)
        
        datePicker.frame = datePickerFrame
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        datePicker.timeZone = currentTimeZone!
        datePicker.addTarget(self, action: "updateLabels", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(datePicker)
    }
    
    
    // MARK: Heading
    
    func setupHeading () {
        
        headingLabel.text = "Moon Information"
        headingLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        
        let origin = CGPoint(x: self.view.bounds.size.width * 0.125, y: self.view.bounds.size.height * 0.01)
        let size = CGSize(width: self.view.bounds.size.width * 0.75, height: self.view.bounds.size.height * 0.10)
        headingLabel.frame = CGRect(origin: origin, size: size)
        
        headingLabel.adjustsFontSizeToFitWidth = true
        headingLabel.textAlignment = .Center
        
        self.view.addSubview(headingLabel)
    }
    
    
    // MARK: Labels
    
    func setupLabels () {
        
        setLabelProperties(riseLabel, heightPercentage: 0.100, initialText: "Rise: ")
        setLabelProperties(setLabel, heightPercentage: 0.135, initialText: "Set: ")
        
        setLabelProperties(altitudeLabel, heightPercentage: 0.185, initialText: "Altitude: ")
        setLabelProperties(azimuthLabel, heightPercentage: 0.220, initialText: "Azimuth: ")
        
        setLabelProperties(declinationLabel, heightPercentage: 0.270, initialText: "Declination: ")
        setLabelProperties(rightAscensionLabel, heightPercentage: 0.305, initialText: "Right Ascension: ")

        setLabelProperties(phaseAngleLabel, heightPercentage: 0.355, initialText: "Phase Angle: ")
        setLabelProperties(phaseIlluminationLabel, heightPercentage: 0.390, initialText: "Illuminaton Fraction: ")
        setLabelProperties(phasePhaseLabel, heightPercentage: 0.425, initialText: "Phase Fraction: ")

    }
    
    func setLabelProperties(label: UILabel, heightPercentage: CGFloat, initialText: String) {
        
        label.text = initialText
        
        let origin = CGPoint(x: self.view.bounds.size.width * 1 / 8, y: self.view.bounds.size.height * heightPercentage)
        let size = CGSize(width: self.view.bounds.size.width * 3 / 4, height: self.view.bounds.size.height * 0.05)
        label.frame = CGRect(origin: origin, size: size)
        
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        
        self.view.addSubview(label)
    }
    
    
    
    // MARK: - Actions
    
    /// Updates the text of all of the labels.
    func updateLabels() {
        
        let newDate = datePicker.date
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: datePicker.date)

        
        let moonRiseAndSet = BDAstroCalc.moonRiseAndSet(date: datePicker.date, location: currentLocation)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = currentTimeZone!
        
        riseLabel.text = "Rise:   \(dateFormatter.stringFromDate(moonRiseAndSet.rise))"
        setLabel.text = "Set:   \(dateFormatter.stringFromDate(moonRiseAndSet.set))"
        
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        
        altitudeLabel.text = "Altitude:   "
            + numberFormatter.stringFromNumber(BDAstroCalc.moonPosition(date: datePicker.date, location: currentLocation).altitude * radiansToDegrees)!
            + "\u{00B0}"
        azimuthLabel.text = "Azimuth:   "
            + numberFormatter.stringFromNumber((BDAstroCalc.moonPosition(date: datePicker.date, location: currentLocation).azimuth + M_PI) * radiansToDegrees % 360)!
            + "\u{00B0}"
        
        declinationLabel.text = "Declination:   "
            + numberFormatter.stringFromNumber(BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date).declination * radiansToDegrees)!
            + "\u{00B0}"
        rightAscensionLabel.text = "Right Ascension:   "
            + numberFormatter.stringFromNumber((BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date).rightAscension * radiansToDegrees + 360) % 360)!
            + "\u{00B0}"

        let phase = BDAstroCalc.moonPhase(date: newDate)
        phaseIlluminationLabel.text = "Illumination Fraction:   "
            + numberFormatter.stringFromNumber(phase.fractionOfMoonIlluminated * 100)!
            + "%"
        phasePhaseLabel.text = "Phase Fraction:   "
            + numberFormatter.stringFromNumber(phase.phase * 100)!
            + "%"
        phaseAngleLabel.text = "Phase Angle:   "
            + numberFormatter.stringFromNumber(phase.angle  * radiansToDegrees)!
            + "\u{00B0}"
    }
}

