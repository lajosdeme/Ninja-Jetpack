//
//  Key.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 21..
//

import SpriteKit
import GameplayKit
import SwiftKeychainWrapper

enum Key: String, CaseIterable {
    case generateObstacle, generateBullet, generateCoin, generatePowerup, generateRobot
    case ninjaAnimation
    case robotMoveAnim
    case ObjectType, PowerupType
    case Obstacle, Bullet, Coin, Powerup, Robot, BG
    case Direction
    
    //User defaults
    case highScore, coinCount
    case immortality, lightspeed, magnet
    case immortalityCount, lightspeedCount, magnetCount
}

extension SKNode {
    func run(_ action: SKAction, withKey key: Key) {
        self.run(action, withKey: key.rawValue)
    }
    
    func removeAction(forKey key: Key) {
        self.removeAction(forKey: key.rawValue)
    }
}

extension Notification.Name {
    static let collectedPowerupsChanged = Notification.Name("collectedPowerupsChanged")
    static let coinCountChanged = Notification.Name("coinCountChanged")
}

extension UserDefaults {
    func setValue(_ value: Any?, forKey key: Key) {
        setValue(value, forKey: key.rawValue)
    }
    
    func integer(forKey defaultName: Key) -> Int {
        integer(forKey: defaultName.rawValue)
    }
}
