//
//  ShopViewController.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 14..
//

import UIKit

class ShopViewController: UIViewController {
    
    @IBOutlet weak var coinCountLabel: UILabel!
    
    @IBOutlet weak var immortalityCountLabel: UILabel!
    @IBOutlet weak var lightspeedCountLabel: UILabel!
    @IBOutlet weak var magnetCountLabel: UILabel!
    
    private var dataManager = DataManager.shared
    
    private var coinCount = 0 {
        didSet {
            var text = ""
            if coinCount / 10 <= 0 {
                text.append("0")
            }
            if coinCount / 100 <= 0 {
                text.append("0")
            }
            if coinCount / 1000 <= 0 {
                text.append("0")
            }
            text.append("\(coinCount)")
            coinCountLabel.text = text
        }
    }
    
    private var immortalityCount = 0 {
        didSet {
            immortalityCountLabel.text = "\(immortalityCount)"
        }
    }
    
    private var lightspeedCount = 0 {
        didSet {
            lightspeedCountLabel.text = "\(lightspeedCount)"
        }
    }
    
    private var magnetCount = 0 {
        didSet {
            magnetCountLabel.text = "\(magnetCount)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coinCount = dataManager.get().coinCount
        (immortalityCount, lightspeedCount, magnetCount) = dataManager.getPurchasesCount()
    }
    
    private func purchase(powerup: PowerupType) -> Bool {
        guard coinCount >= 500 else { return false }
        coinCount -= 500
        dataManager.purchase(powerup: powerup)
        NotificationCenter.default.post(name: .coinCountChanged, object: nil)
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func immortalityAction(_ sender: Any) {
        if purchase(powerup: .Immortality) {
            immortalityCount += 1
        }
    }
    
    
    @IBAction func lightspeedAction(_ sender: Any) {
        if purchase(powerup: .Lightspeed) {
            lightspeedCount += 1
        }
    }
    
    
    @IBAction func magnetAction(_ sender: Any) {
        if purchase(powerup: .Magnet) {
            magnetCount += 1
        }
    }
}
