//
//  Constants.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit
import StoreKit

enum DefaultsKeys: String {
	case language = "Language"
	case sessions = "Sessions"
	case lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
}

struct DataModel {
	static var shared = DataModel()
	let defaults = UserDefaults.standard
	
    let makkahLat = 0.3738927226761722 //21.4224750 deg
    let makkahLon = 0.6950985611585316 //39.8262139 deg
	var lastCalibrated: Date?
		
	var mustCalibrate: Bool {
		if let diff = Calendar.current.dateComponents([.minute], from: lastCalibrated ?? Date.distantPast, to: Date()).minute, diff > 40 { return true }
		else { return false }
	}
	
	private init() {}
	
    func bearing(lat: Double, lon: Double) -> Double {
		let newLat = lat * Double.pi / 180.0
		let newLon = lon * Double.pi / 180.0
        let x = cos(makkahLat) * sin(makkahLon - newLon)
        let y = cos(newLat) * sin(makkahLat) - sin(newLat) * cos(makkahLat) * cos(makkahLon - newLon)
        return atan2(x, y)
    }
	
	mutating func refreshLastCalibrationDate() {
		lastCalibrated = Date()
	}
}

//MARK:- App Store Review Related
extension DataModel {
	var shouldAskForReview: Bool { appSessions >= 2 && currentAppVersion != lastPromptedForReviewAppVersion }
	
	var appSessions: Int { defaults.object(forKey: DefaultsKeys.sessions.rawValue) as? Int ?? 0 }
	
	var lastPromptedForReviewAppVersion: String {
		UserDefaults.standard.string(forKey: DefaultsKeys.lastVersionPromptedForReviewKey.rawValue) ?? "Invalid Old Version"
	}
	
	var currentAppVersion: String {
		let infoDictionaryKey = kCFBundleVersionKey as String
		return Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String ?? "Invalid Current Version"
	}
		
	func requestAppStoreReview() {
		SKStoreReviewController.requestReview()
		UserDefaults.standard.set(currentAppVersion, forKey: DefaultsKeys.lastVersionPromptedForReviewKey.rawValue)
		setSessionNumber(0)
	}
	
	func setSessionNumber(_ number: Int) {
		defaults.set(number, forKey: DefaultsKeys.sessions.rawValue)
	}
	
	func incrementSuccessSessionNumberIfNeeded() {
		if currentAppVersion != lastPromptedForReviewAppVersion {
			let newSessionNumber = appSessions + 1
			defaults.set(newSessionNumber, forKey: DefaultsKeys.sessions.rawValue)
		}
	}
}
