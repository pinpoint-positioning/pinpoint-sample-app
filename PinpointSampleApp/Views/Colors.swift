//
//  Colors.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 10.05.23.
//

import Foundation
import SwiftUI
import UIKit


struct CustomColor {
    static let pinpoint_orange = Color("pinpoint_orange")
    static let cgPinpoint_orange = UIColor(pinpoint_orange).cgColor
    static let uiPinpoint_orange = UIColor(pinpoint_orange)
    
    
    static let pinpoint_background = Color("pinpoint_background")
    
    
    static let pinpoint_gray = Color("pinpoint_gray")
    static let cgPinpointGray = UIColor(pinpoint_gray).cgColor
    static let uiPinpointGray = UIColor(pinpoint_gray)

    static let pinpoint_backgroundC = CGColor(red: 244, green: 245, blue: 244, alpha: 255)
    
}
