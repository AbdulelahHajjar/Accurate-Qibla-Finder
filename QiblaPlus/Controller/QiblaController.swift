//
//  QiblaController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 06/03/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation
import CoreLocation

protocol QiblaDirectionProtocol {
    func didSuccessfullyFindHeading(rotationAngle: Double)
    func didFindError(error: [String : String])
	func showCalibration(force: Bool)
}

class QiblaController: NSObject, CLLocationManagerDelegate {
	private(set) static var shared = QiblaController()
	
    let locationManager = CLLocationManager()
    var qiblaDelegate: QiblaDirectionProtocol?
        
	var errorDescription: [String : String]? {
		if(CLLocationManager.headingAvailable() == false) {
			return Constants.shared.noTrueHeadingError
		}
		else if CLLocationManager.locationServicesEnabled() == false {
			return Constants.shared.locationDisabled
		}
		else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
			return Constants.shared.wrongAuthInSettings
		}
		else {
			return nil
		}
	}
	
	var canFindQibla: Bool {
		errorDescription == nil
	}
	
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		startMonitoringQibla()
    }
	
    func startMonitoringQibla() {
		locationManager.requestWhenInUseAuthorization()
		if canFindQibla {
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
		} else {
			qiblaDelegate?.didFindError(error: errorDescription ?? [:])
		}
    }
	
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var heading = newHeading.trueHeading
		let location = manager.location
		
		if heading.isInvalid {
			qiblaDelegate?.didFindError(error: Constants.shared.cannotCalibrate)
		}
		else if location?.isInvalid ?? true {
			qiblaDelegate?.didFindError(error: Constants.shared.cannotFindLocation)
		}
        else {
			let latitude = location!.coordinate.latitude
			let longitude = location!.coordinate.longitude
			
			let bearingAngle = Constants.shared.bearing(lat: latitude, lon: longitude)
			
            heading *= Double.pi/180.0
			qiblaDelegate?.didSuccessfullyFindHeading(rotationAngle: bearingAngle - heading + Double.pi * 2)
        }
    }
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		startMonitoringQibla()
		qiblaDelegate?.showCalibration(force: true)
	}
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
}

extension CLLocationDirection {
	var isInvalid: Bool {
		return self == -1.0 || self.isNaN
	}
}

extension CLLocation {
	var isInvalid: Bool {
		return horizontalAccuracy < 0
	}
}
