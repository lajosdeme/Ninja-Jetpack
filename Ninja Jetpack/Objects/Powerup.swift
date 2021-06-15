//
//  Powerup.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 19..
//

import SpriteKit
import GameplayKit

enum PowerupType: String, CaseIterable {
    case Immortality, Lightspeed, Magnet
}

class Powerup: StaticObject, Object {

    internal var scene: GameScene
    
    private var collectedPowerups = [SKNode]()
    
    required init(scene: GameScene) {
        self.scene = scene
    }
    
    var className: String {
        return String(describing: Powerup.self)
    }
    
    //MARK: - Generate objects
    func generateObjects() {
        let wait     = SKAction.wait(forDuration: 15, withRange: 8)
        let create   = SKAction.run(createObject)
        let sequence = SKAction.sequence([wait, create])
        
        scene.run(SKAction.repeatForever(sequence), withKey: .generatePowerup)
    }
    
    //MARK: - Create object
    internal func createObject() {
        let type = random()
        let atlas = SKTextureAtlas(named: type.rawValue)
        var frames: [SKTexture] = []
        
        let num = atlas.textureNames.count
        for i in 0..<num {
            let name = "\(type.rawValue)_\(i+1)"
            frames.append(atlas.textureNamed(name))
        }
        let powerup = SKSpriteNode(texture: frames[0])
        powerup.zPosition = 100
        
        let randomY = GKRandomDistribution(lowestValue: Int(scene.frame.minY + 150), highestValue: Int(scene.size.height) - 150).nextInt()
        let pos = CGPoint(x: scene.size.width + 150, y: CGFloat(randomY))

        powerup.position = pos
        powerup.userData = [
            Key.ObjectType.rawValue: Key.Powerup.rawValue,
            Key.PowerupType.rawValue: type.rawValue
        ]
        
        powerup.setScale(0.5)
        powerup.physicsBody = SKPhysicsBody(circleOfRadius: powerup.size.width/2)
        powerup.physicsBody?.affectedByGravity = false
        powerup.physicsBody?.categoryBitMask = .powerupCategory
        powerup.physicsBody?.collisionBitMask = .none
        powerup.physicsBody?.contactTestBitMask = .ninjaCategory
        
        let isIntersected = handleIntersectedNodes(powerup)
        
        if !isIntersected {
            powerup.name = UUID().uuidString
            scene.addChild(powerup)
            objects.append(powerup)
        }

        powerup.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1)), withKey: "\(type.rawValue)Anim")
    }
    
    //MARK: - Random powerup
    private func random() -> PowerupType {
        return PowerupType.allCases[Int(arc4random_uniform(3))]
    }
    
    //MARK: - Handle intersected nodes
    //If it intersects another node we move it 300 points
    //If it still intersects a node we simply not add this as a child
    //Could work on better logic in the future
    internal func handleIntersectedNodes(_ node: SKSpriteNode) -> Bool {
        let isIntersectedByOtherNode = scene.children.filter {$0.intersects(node)}.count > 1
        if isIntersectedByOtherNode {
            node.position.x += 300
        }
        return scene.children.filter {$0.intersects(node)}.count > 1
    }
    
    //MARK: - Stop generating objects
    func stopGeneratingObjects() {
        scene.removeAction(forKey: .generatePowerup)
    }
    
    //MARK: - Powerup duration
    //Returns the duration of each powerup type
    func powerupDuration(_ powerupType: PowerupType) -> Double {
        switch powerupType {
        case .Immortality, .Magnet:
            return 15
        case .Lightspeed:
            return 5
        }
    }
    
    //MARK: - Collect
    func collect(_ powerup: SKNode?) {
        guard let powerup = powerup else {return}
        //Removes powerup from visible objects array
        if let id = powerup.name, let idx = objects.firstIndex(where: { $0.name == id }) {
            objects.remove(at: idx)
        }
        
        //Animates the powerup to the top right of the screen
        powerup.physicsBody?.categoryBitMask = .collectedPowerupCategory
        powerup.physicsBody?.contactTestBitMask = .none
        powerup.physicsBody?.collisionBitMask = .none
        powerup.run(SKAction.move(to: CGPoint(x: (scene.frame.width - 120) - CGFloat(collectedPowerups.count * 30), y: scene.frame.height - 42), duration: 1))
        
        //Appends to collected
        collectedPowerups.append(powerup)
        
        //Posts notification that a powerup was collected
        NotificationCenter.default.post(name: .collectedPowerupsChanged,
                                        object: collectedPowerups
                                            .map {($0.userData as! [String:String])[Key.PowerupType.rawValue]})
        
        //Animates the active powerups in the top right of the screen
        let powerupTypeStr = (powerup.userData as! [String:String])["PowerupType"]!
        let powerupType = PowerupType(rawValue: powerupTypeStr)!

        powerup.run(
            SKAction.sequence([
                SKAction.wait(forDuration: powerupDuration(powerupType)),
                SKAction.run {
                    if let id = powerup.name, let idx = self.collectedPowerups.firstIndex(where: { $0.name == id }) {
                        
                        for i in idx..<self.collectedPowerups.count {
                            guard i > 0 else {continue}
                            self.collectedPowerups[i].run(SKAction.move(to: self.collectedPowerups[i-1].position, duration: 0.5))
                        }
                        let powerupToRemove = self.collectedPowerups[idx]
                        powerupToRemove.removeFromParent()
                        self.collectedPowerups.remove(at: idx)
                        NotificationCenter.default.post(name: .collectedPowerupsChanged,
                                                        object: self.collectedPowerups
                                                            .map {($0.userData as! [String:String])[Key.PowerupType.rawValue]})
                    }
                },
                SKAction.removeFromParent()
            ])
        )
    }
    
    //MARK: - Remove collected powerups
    func removeCollectedPowerups() {
        collectedPowerups.removeAll()
    }
}
