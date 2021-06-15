//
//  Bullet.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 19..
//

import SpriteKit
import GameplayKit

class Bullet: Object {
    
    internal var scene: GameScene
    private var bullet = SKSpriteNode()
    private var bulletSize = CGSize(width: 35, height: 29)
    // CGSize(width: 87, height: 20)
    required init(scene: GameScene) {
        self.scene = scene
    }
    
    var className: String {
        return String(describing: Bullet.self)
    }
    
    var shootDuration = 0.4
    
    //MARK: - Start bullets
    func generateObjects() {
        let wait = SKAction.wait(forDuration: 3, withRange: 2)
        let shoot = SKAction.run(createObject)
        let sequence = SKAction.sequence([wait, shoot])
        scene.run(SKAction.repeatForever(sequence), withKey: .generateBullet)
    }
    
    //MARK: - Shoot bullet
    internal func createObject() {
        bullet = SKSpriteNode(imageNamed: "laser")
        bullet.size = bulletSize
        
        var yPos = GKRandomSource.sharedRandom().nextInt(upperBound: Int(scene.size.height))
        if yPos < 70 { yPos += 70 }
        
        bullet.position = CGPoint(x: scene.size.width + 50, y: CGFloat(yPos))
        bullet.userData = [Key.ObjectType.rawValue: Key.Bullet.rawValue]
        
        bullet.zPosition = 100
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bulletSize.width / 2)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = .bulletCategory
        bullet.physicsBody?.collisionBitMask = .none
        bullet.physicsBody?.contactTestBitMask = .ninjaCategory
        scene.addChild(bullet)

        bullet.run(SKAction.sequence([
            SKAction.run {self.showWarning(yPos: CGFloat(yPos))},
            SKAction.wait(forDuration: 0.8),
            SKAction.move(to: CGPoint(x: 0, y: yPos), duration: shootDuration),
            SKAction.removeFromParent()
        ]))
    }
    
    func stopGeneratingObjects() {
        scene.removeAction(forKey: .generateBullet)
    }
    
    //MARK: - Show warning
    private func showWarning(yPos: CGFloat) {
        let warningSign = SKSpriteNode(imageNamed: "warning")
        warningSign.physicsBody?.affectedByGravity = false
        warningSign.position = CGPoint(x: UIScreen.main.bounds.width - 50, y: yPos)
        warningSign.zPosition = 100
        let scale = SKAction.scale(by: 1.4, duration: 0.1).reversed()
        let scaleAnim = SKAction.repeatForever(SKAction.sequence([scale, scale.reversed()]))
        scene.run(SKAction.sequence([
            SKAction.run {self.scene.addChild(warningSign)},
            SKAction.wait(forDuration:  0.8),
            SKAction.run {warningSign.removeFromParent()}
        ]))
        warningSign.run(scaleAnim)
    }
}
