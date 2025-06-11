//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation

extension String {
    /*
     Used to massage text input to force a valid URL.
     Assume https://\(self).com
     But if the field provides a scheme/domain it will be used
     */
    public var urlString: String {
        var newText = self
        if !newText.contains("://") {
            newText = "https://" + newText
        }
        if !newText.contains(".") {
            newText = newText + ".com"
        }
        return newText
    }
}
