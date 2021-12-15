//
//  LocationManager.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import CoreLocation


class LocationManager: NSObject, CLLocationManagerDelegate {

    typealias UpdateLocationCompletionHandler = (CLLocation?) -> Void

    let locationManager = CLLocationManager()
    private(set) var currentLocation: CLLocation?

    var updateLocationCompletionHandlers = [UpdateLocationCompletionHandler]()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startMonitoringSignificantLocationChanges()
        
        currentLocation = locationManager.location

        karmiesLog("location services enabled = \(CLLocationManager.locationServicesEnabled())")
        karmiesLog("authorization status = \(CLLocationManager.authorizationStatus().krm_description)")
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func updateLocation(withCompletionHandler completionHandler: UpdateLocationCompletionHandler?) {
        locationManager.startUpdatingLocation()

        performSelector(#selector(self.completeUpdating(andEnablePassiveMode:)), withObject: false, afterDelay: 4)
        if let completionHandler = completionHandler {
            updateLocationCompletionHandlers.append(completionHandler)
        }
        
        currentLocation = locationManager.location
    }

    @objc
    private func completeUpdating(andEnablePassiveMode enablePassiveMode: NSNumber = true) {
        karmiesLog("begin with \(enablePassiveMode)")

        let enablePassiveMode = enablePassiveMode.boolValue

        if enablePassiveMode {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }

        if updateLocationCompletionHandlers.count > 0 {
            updateLocationCompletionHandlers.forEach { $0(currentLocation) }
            updateLocationCompletionHandlers = []
        }

        karmiesLog("end")
    }

    // MARK: Location Manager Delegate

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        karmiesLog("got the new location \(newLocation)")
        
        currentLocation = newLocation
        completeUpdating()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        karmiesLog("got the new locations \(locations)")
        
        if let location = locations.last {
            currentLocation = location
            completeUpdating()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        karmiesLog(error.localizedDescription)

        let authorizationStatus = CLLocationManager.authorizationStatus()
        let enablePassiveMode = CLLocationManager.locationServicesEnabled() && authorizationStatus != .Denied && authorizationStatus != .Restricted

        karmiesLog("location services enabled = \(CLLocationManager.locationServicesEnabled())")
        karmiesLog("authorization status = \(CLLocationManager.authorizationStatus().krm_description)")

        completeUpdating(andEnablePassiveMode: enablePassiveMode)
    }

}
