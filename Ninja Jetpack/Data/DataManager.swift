//
//  DataManager.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 10..
//

import Foundation
import SwiftKeychainWrapper

class DataManager {
    static let shared = DataManager()
    private init(){}
    
    private let userDefaults = UserDefaults.standard
    private let keychainWrapper = KeychainWrapper.standard
    
    func save(_ highScore: Int, _ coinCount: Int) {
        set(highScore, forKey: .highScore, withAccessibility: .afterFirstUnlock)
        set(coinCount, forKey: .coinCount, withAccessibility: .afterFirstUnlock)
    }
    
    func get() -> (highScore: Int, coinCount: Int) {
        return (get(.highScore),
                get(.coinCount))
    }
    
    func purchase(powerup: PowerupType) {
        let coinCount = get(.coinCount)
        guard coinCount >= 500 else {return}
        set(coinCount - 500, forKey: .coinCount)
        
        switch powerup {
        case .Immortality:
            set(get(.immortality) + 1, forKey: .immortality)
        case .Lightspeed:
            set(get(.lightspeed) + 1, forKey: .lightspeed)
        case .Magnet:
            set(get(.magnet) + 1, forKey: .magnet)
        }
    }
    
    func spend(powerup: PowerupType) {
        switch powerup {
        case .Immortality:
            set(get(.immortality) - 1, forKey: .immortality)
        case .Lightspeed:
            set(get(.lightspeed) - 1, forKey: .lightspeed)
        case .Magnet:
            set(get(.magnet) - 1, forKey: .magnet)
        }
    }
    
    func getPurchasesCount() -> (immortality: Int, lightspeed: Int, magnet: Int) {
        return (get(.immortality), get(.lightspeed), get(.magnet))
    }
    
    func spendRevive() {
        set(get(.coinCount) - 500, forKey: .coinCount)
    }
    
    private func set(_ value: Int, forKey key: Key, withAccessibility accessibility: KeychainItemAccessibility? = nil, isSynchronizable: Bool = false) {
        //We dont let negative values to be set
        let val = value < 0 ? 0 : value
        keychainWrapper.set(val, forKey: key.rawValue, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
    }
    
    private func get(_ key: Key) -> Int {
        return keychainWrapper.integer(forKey: key.rawValue) ?? 0
    }
}
