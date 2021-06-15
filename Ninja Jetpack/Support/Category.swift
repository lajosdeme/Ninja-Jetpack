//
//  Category.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 22..
//

import SpriteKit

extension UInt32 {
    static let none:UInt32 = 0x1 << 0
    static let groundCategory:UInt32 = 0x1 << 1
    static let ninjaCategory:UInt32 = 0x1 << 2
    static let bulletCategory:UInt32 = 0x1 << 3
    static let coinCategory:UInt32 = 0x1 << 4
    static let powerupCategory:UInt32 = 0x1 << 5
    static let collectedPowerupCategory:UInt32 = 0x1 << 6
    static let obstacleCategory:UInt32 = 0x1 << 7
    static let ninjaCircleCategory:UInt32 = 0x1 << 8
}
