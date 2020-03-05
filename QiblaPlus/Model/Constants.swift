//
//  QiblaMode.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit


class Constants {
    let tips: [String : NSAttributedString]
    let makkahLat = 0.3738927226761722      //21.4224750 deg
    let makkahLon = 0.6950985611585316      //39.8262139 deg
    let defaults = UserDefaults.standard
    var lastCalibrated = Date()
    
    init() {
        tips = Constants.initTipsLabel()
    }
    
    static func initTipsLabel() -> [String : NSAttributedString] {
        //Setting paragraph style for the tips
        let enParagraphStyle = NSMutableParagraphStyle()
        enParagraphStyle.lineSpacing = 8
        enParagraphStyle.alignment = .left
        
        let arParagraphStyle = NSMutableParagraphStyle()
        arParagraphStyle.lineSpacing = 8
        arParagraphStyle.alignment = .right
        
        //Adding attributes to dictionary
        var tipsAttributes = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 15),
                              NSAttributedString.Key.paragraphStyle : enParagraphStyle,
                              NSAttributedString.Key.foregroundColor : UIColor.white]

        //Adding attributes to English string
        let enTipsAttributed : NSAttributedString = NSAttributedString(string: "Tips for better qibla accuracy:\n♾ Calibrate compass by moving iPhone in an 8-figure\n🧲  Move away from electronic devices\n📱 Lay your phone flat", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        //Switching alignment of text to right
        tipsAttributes[NSAttributedString.Key.paragraphStyle] = arParagraphStyle
    
        //Adding attributes to Arabic string
        let arTipsAttributed : NSAttributedString = NSAttributedString(string: "نصائح لقبلة أدق:\n♾ عاير البوصلة بتدوير الجهاز على شكل 8\n🧲  ابتعد عن الأجهزة الإلكترونية\n📱 ضع هاتفك بشكل مسطح", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        return ["en" : enTipsAttributed, "ar" : arTipsAttributed]
    }
    
    
    func getBearing(newLat: Double, newLon: Double) -> Double {
        let x = cos(makkahLat) * sin(makkahLon - newLon)
        let y = cos(newLat) * sin(makkahLat) - sin(newLat) * cos(makkahLat) * cos(makkahLon - newLon)
        return atan2(x, y)
    }
}
