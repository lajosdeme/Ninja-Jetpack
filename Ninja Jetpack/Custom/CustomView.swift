//
//  CustomView.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 17..
//

import UIKit

//This is used for the buy powerups view when the game starts
//That view has a tap gesture recognizer and animation at the same time
//Without this, the animation blocks the tap gesture
class CustomView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pf = layer.presentation()!.frame
        let p = self.convert(point, to: superview!)
        if pf.contains(p) { return self }
        return nil
    }
}
