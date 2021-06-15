//
//  Coin.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 19..
//

import SpriteKit
import GameKit

class Coin: StaticObject, Object {
    internal var scene: GameScene

    var coinsCollected: Int = 0
    
    required init(scene: GameScene) {
        self.scene = scene
    }
    
    var className: String {
        return String(describing: Coin.self)
    }
    
    var hasMagneted: Bool {
        return objects.contains { (node) -> Bool in
            (node.userData!["magneted"] as? Bool) == true
        }
    }
    
    //MARK: - Display random coins
    func generateObjects() {
        let wait = SKAction.wait(forDuration: 4, withRange: 2)
        
        let generate = SKAction.run(createObject)
        let sequence = SKAction.sequence([wait, generate])
        scene.run(SKAction.repeatForever(sequence), withKey: .generateCoin)
    }
    
    //MARK: - Generate coins
    //creates a coin structure for a random shape
    internal func createObject() {
        let randomCoinNum = GKRandomSource().nextInt(upperBound: 10)
        guard let structure = CoinData.loadFrom(file: "coin\(randomCoinNum)")?.structure else {return}
        
        let randomYGenerator = GKRandomDistribution(lowestValue: Int(scene.frame.minY + 150), highestValue: Int(scene.size.height - 150))
        let randomY = randomYGenerator.nextInt()

        for j in 0..<structure.count {
            for i in 0..<structure[j].count {
                if structure[j][i] != 0 {
                    let yVal = randomY + ((structure.count - 1) - j * 17)
                    showCoin(y: yVal, offset: i)
                }
            }
        }
    }
    
    //MARK: - Show coin
    //Creates one coin and configures its node and physics body
    private func showCoin(y: Int, offset: Int) {
        let name = "Gold_1"
        
        let coin = SKSpriteNode(imageNamed: name)
        coin.zPosition = 100
        coin.setScale(0.03)
        let actualX = coin.size.width * CGFloat(offset)
        let pos = CGPoint(x: (scene.frame.maxX + 100) + actualX, y: CGFloat(y))
        coin.userData = [Key.ObjectType.rawValue: Key.Coin.rawValue]
        
        coin.position = pos
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = .coinCategory
        coin.physicsBody?.collisionBitMask = .none
        coin.physicsBody?.contactTestBitMask = .ninjaCategory
        
        handleIntersectedNodes(coin)
        
        coin.name = UUID().uuidString
        scene.addChild(coin)
        objects.append(coin)
    }
    
    //MARK: - Increment, reset count
    func incrementCoinCount() {
        coinsCollected += 1
        scene.coinHandler!(coinsCollected)
    }
    
    func resetCoinCount() {
        coinsCollected = 0
        scene.coinHandler?(coinsCollected)
    }
    
    //MARK: - Handle intersected nodes
    //If another node interesects with a coin we remove that from the scene
    internal func handleIntersectedNodes(_ node: SKSpriteNode) {
        let intersectedNodes = scene.children
            .filter {$0.intersects(node)}
            .filter {
                $0.userData != nil &&
                    (($0.userData as! [String:String])[Key.ObjectType.rawValue] == Key.Obstacle.rawValue ||
                        ($0.userData as! [String:String])[Key.ObjectType.rawValue] == Key.Powerup.rawValue)}
        
        let isIntersectedByOtherNode = intersectedNodes.count > 0
        if isIntersectedByOtherNode {
            intersectedNodes.forEach { (node) in
                node.removeFromParent()
            }
        }
    }
    
    //MARK: - Stop generating objects
    func stopGeneratingObjects() {
        scene.removeAction(forKey: .generateCoin)
    }
}
