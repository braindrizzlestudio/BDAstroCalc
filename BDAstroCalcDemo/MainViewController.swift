//
//  MainViewController.swift
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

// Current Location. Default: 1 Infinite Loop
var currentLocation = CLLocationCoordinate2D(latitude: 40.4291167, longitude: -79.9228904)

// Current TimeZone. Default: PDT, for 1 Infinite Loop
var currentTimeZone = NSTimeZone(abbreviation: "PDT")


class MainViewController : UIViewController, CLLocationManagerDelegate {
    
    
    // MARK: - Properties
    
    // The current location
    let currentlLocationLabel = UILabel()
    
    // A location Manager
    let locationManager = CLLocationManager()

    // The Title
    let titleLabel = UILabel()
    
    // URL to braindrizzle.com
    let URLTextView = UITextView()
    
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupLocationManager()
        
        setupTitleLabel()
        
        setupMoonVCSegueButton()
        setupSunVCSegueButton()
        
        setupURLTextView()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // This label is in viewWillAppear becasue the location might update while the user is in one of the other VCs.
        setupCurrentLocationLabel()
    }

    
    
    // MARK: - Buttons
    
    // MARK: Button Configuration
    
    func setupMoonVCSegueButton () {
    
        let moonVCSegueButton = UIButton(type: UIButtonType.System)
        moonVCSegueButton.setTitle("Moon Information", forState: UIControlState.Normal)

        let origin = CGPoint(x: self.view.bounds.size.width / 4, y: self.view.bounds.size.height * 2 / 5)
        let size = CGSize(width: self.view.bounds.size.width / 2, height: self.view.bounds.size.height / 10)
        let moonVCSegueButtonFrame = CGRect(origin: origin, size: size)
        moonVCSegueButton.frame = moonVCSegueButtonFrame
        
        moonVCSegueButton.layer.borderWidth = 0.5
        moonVCSegueButton.layer.cornerRadius = 8
        moonVCSegueButton.layer.borderColor = UIColor.blueColor().CGColor
        
        moonVCSegueButton.addTarget(self, action: "moonVCSegueButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(moonVCSegueButton)
    }
    
    func setupSunVCSegueButton () {
        
        let sunVCSegueButton = UIButton(type: UIButtonType.System)
        sunVCSegueButton.setTitle("Sun Information", forState: UIControlState.Normal)
        
        let origin = CGPoint(x: self.view.bounds.size.width / 4, y: self.view.bounds.size.height * 3 / 5)
        let size = CGSize(width: self.view.bounds.size.width / 2, height: self.view.bounds.size.height / 10)
        let sunVCSegueButtonFrame = CGRect(origin: origin, size: size)
        sunVCSegueButton.frame = sunVCSegueButtonFrame
        
        sunVCSegueButton.layer.borderWidth = 0.5
        sunVCSegueButton.layer.cornerRadius = 8
        sunVCSegueButton.layer.borderColor = UIColor.blueColor().CGColor

        sunVCSegueButton.addTarget(self, action: "sunVCSegueButtonAction", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(sunVCSegueButton)
    }
    
    
    // MARK: Button Actions
    
    
    func moonVCSegueButtonAction () {
        
        self.navigationController?.pushViewController(MoonViewController(), animated: true)
    }
    
    func sunVCSegueButtonAction () {
        
        self.navigationController?.pushViewController(SunViewController(), animated: true)
    }
    
    
    // MARK: - Labels
    
    func setupTitleLabel () {
        
        titleLabel.text = "BDAstroCalc"
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .Center
        
        let origin = CGPoint(x: 0, y: self.view.bounds.size.height / 10)
        let size = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height / 5)
        titleLabel.frame = CGRect(origin: origin, size: size)

        self.view.addSubview(titleLabel)
    }
    
    func setupCurrentLocationLabel () {
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        currentlLocationLabel.text = "Current Location: (\(numberFormatter.stringFromNumber(currentLocation.latitude)!)\u{00B0}, \(numberFormatter.stringFromNumber(currentLocation.longitude)!)\u{00B0})"
        
        currentlLocationLabel.adjustsFontSizeToFitWidth = true
        currentlLocationLabel.textAlignment = .Center
        
        let origin = CGPoint(x: 0, y: self.view.bounds.size.height * 5 / 20)
        let size = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height / 10)
        currentlLocationLabel.frame = CGRect(origin: origin, size: size)
        
        self.view.addSubview(currentlLocationLabel)
    }
    
    
    // MARK: - TextViews
    
    func setupURLTextView () {
        
        URLTextView.text = "braindrizzlestudio.com"
        
        URLTextView.textAlignment = .Center
        
        URLTextView.editable = false
        URLTextView.dataDetectorTypes = UIDataDetectorTypes.Link
        
        let origin = CGPoint(x: 0, y: self.view.bounds.size.height * 9 / 10)
        let size = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height / 10)
        URLTextView.frame = CGRect(origin: origin, size: size)
        
        self.view.addSubview(URLTextView)
    }
    
    
    // MARK: - Location Manager
    
    func setupLocationManager () {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if CLLocationManager.authorizationStatus() == .NotDetermined { locationManager.requestWhenInUseAuthorization() }
        
        if CLLocationManager.locationServicesEnabled() { locationManager.startUpdatingLocation() }
    }
    
    
    // Updates the global currentLocation, and global currentTimeZone, when location is updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0].coordinate as CLLocationCoordinate2D
        
        currentTimeZone = NSTimeZone.systemTimeZone()

        locationManager.stopUpdatingLocation()
        
        self.setupCurrentLocationLabel()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Location Manager failed to get location: \(error)")
    }
}
