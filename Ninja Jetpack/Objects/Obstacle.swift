//
//  Obstacle.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 20..
//

import SpriteKit
import GameplayKit

enum ObstaclePosition: String, CaseIterable {
    case vertical, horizontal, rotating
    
    static func random() -> ObstaclePosition {
        return allCases[Int(arc4random_uniform(UInt32(self.allCases.count)))]
    }
}

class Obstacle: StaticObject, Object {
    internal var scene: GameScene

    required init(scene: GameScene) {
        self.scene = scene
    }
    
    var className: String {
        return String(describing: Obstacle.self)
    }
    
    //MARK: - Generate objects
    //Sets the interval that elapses between objects and starts generating the objects
    func generateObjects() {
        let wait = SKAction.wait(forDuration: 2, withRange: 1)
        
        let create = SKAction.run(createObject)
        let sequence = SKAction.sequence([wait, create])
        scene.run(SKAction.repeatForever(sequence), withKey: .generateObstacle)
    }
    
    //MARK: - Create object
    //Creates a single obstacle object at a random position and with a random orientation
    internal func createObject() {
        let name = "obstacle"
        
        let obstacle = SKSpriteNode(imageNamed: name)
        obstacle.zPosition = 102
        obstacle.setScale(0.3)
        
        let randomY = GKRandomDistribution(lowestValue: Int(scene.frame.minY + 70), highestValue: Int(scene.size.height) - 70).nextInt()
        let pos = CGPoint(x: scene.size.width + obstacle.size.width, y: CGFloat(randomY))
        
        obstacle.position = pos
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.categoryBitMask = .obstacleCategory
        obstacle.physicsBody?.collisionBitMask = .none
        obstacle.physicsBody?.contactTestBitMask = .ninjaCategory
        
        obstacle.userData = [Key.ObjectType.rawValue: Key.Obstacle.rawValue]
        
        let obstaclePos = ObstaclePosition.random()
        switch obstaclePos {
        case .horizontal:
            break
        case .vertical:
            obstacle.zRotation = .pi / 2
        case .rotating:
            obstacle.run(SKAction.repeatForever(SKAction.rotate(byAngle: 2 * .pi, duration: 3)))
        }
        
        let isIntersected = handleIntersectedNodes(obstacle)
        if !isIntersected {
            obstacle.name = UUID().uuidString
            scene.addChild(obstacle)
            objects.append(obstacle)
        } else {
            Logger.shared.debugPrint("Intersected true. ")
        }
    }
    
    //MARK: - Handle intersected nodes
    //If it intersects another node we move it 400 points
    //If it still intersects a node we simply not add this as a child
    //Could improve this logic in the future
    internal func handleIntersectedNodes(_ node: SKSpriteNode) -> Bool {
        var isIntersectedByOtherNode = scene.children.filter {$0.intersects(node)}.count > 1
        if isIntersectedByOtherNode {
            node.position.x += 400
        }
        isIntersectedByOtherNode = scene.children.filter {$0.intersects(node)}.count > 1
        return isIntersectedByOtherNode
    }
    
    //Stops generating the obstacles
    func stopGeneratingObjects() {
        scene.removeAction(forKey: .generateObstacle)
    }
}
