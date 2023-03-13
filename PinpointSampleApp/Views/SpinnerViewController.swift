//
//  SpinnerViewController.swift
//  minimalBT
//
//  Created by Christoph Scherbeck on 08.03.23.
//

import Foundation
import UIKit


 class SpinnerViewController {
    var activityIndicator = UIActivityIndicatorView(style: .large)
     
    func initSpinner(view:UIView) {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}


