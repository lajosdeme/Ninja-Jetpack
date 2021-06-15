//
//  Object.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 20..
//

import SpriteKit
import GameplayKit

//MARK: - Object protocol
//Objects used on the game scene implement this protocol
//It is initialized with the current game scene
protocol Object {
    var scene: GameScene { get }
    init(scene: GameScene)
    
    var className: String { get }
    
    //This method is used to start the generation of objects at random times on the screen
    //Only called once for all objects, when the game starts
    func generateObjects()
    
    //This method is responsible for creating a single instance of the given object
    func createObject()
    
    //This method is used to stop the generation of objects in the scene
    func stopGeneratingObjects()
    
    //This method is responsible for handling all interceptions with other nodes in the scene
    func handleIntersectedNodes(_ node: SKSpriteNode)
}

extension Object {
    func handleIntersectedNodes(_ node: SKSpriteNode) { }
}


//MARK: - Static object
//This is used when we want an object to be static on the scene
//This is achieved by moving the object in the opposite direction than the background
//Then removing the object from parent when it's out of bounds
class StaticObject {
    internal var objects = [SKSpriteNode]()
    
    //Move all objects
    func moveAllObjects(_ scene: GameScene) {
        objects.forEach {moveObject($0, in: scene)}
    }
    
    //Move one object
    private func moveObject(_ objectNode: SKSpriteNode, in scene: GameScene) {
        objectNode.position = CGPoint(x: objectNode.position.x - scene.gameSpeed, y: objectNode.position.y)
        if objectNode.position.x < -objectNode.size.width {
            objectNode.removeFromParent()
        }
    }
    
    //Remove all objects
    func removeAllObjects() {
        objects.removeAll()
    }

    //Remove one object fom parent and objects array
    func remove(_ object: SKNode?) {
        object?.removeFromParent()
        if let id = object?.name, let idx = objects.firstIndex(where: { $0.name == id }) {
            objects.remove(at: idx)
        }
    }
}
