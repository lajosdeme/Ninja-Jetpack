//
//  Int_Extension.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 27..
//

import Foundation

extension Int {
    func createLabelText() -> String {
        var text = ""
        if self / 10 <= 0 {
            text.append("0")
        }
        if self / 100 <= 0 {
            text.append("0")
        }
        if self / 1000 <= 0 {
            text.append("0")
        }
        text.append("\(self)")
        return text
    }
}
