//
//  UISearchBar.swift
//  Sorted
//
//  Created by NgQuocThang on 9/7/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//

import Foundation
import UIKit

// Change UI for search bar, make text input field white, change cancel button color
// https://stackoverflow.com/questions/13817330/how-to-change-inside-background-color-of-uisearchbar-component-on-ios
extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            @unknown default:
                fatalError()
            }
        }
    }
}
