//
//  Ninja.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 19..
//

import SpriteKit
import GameplayKit

enum NinjaMode: String, CaseIterable {
    case Idle, Run, Dead, Fly
    case FlyMagnet, FlyImmortal
    case RunMagnet, RunImmortal
}

class Ninja {
    
    //Reference to the scene
    private var scene: GameScene
    
    //The ninja node and ninja modes
    private var ninja = SKSpriteNode()
    private var ninjaModes = [NinjaMode: [SKTexture]]()
    private var reviveMode = [SKTexture]()
    
    //The current mode
    var currentMode: NinjaMode!
    //Whether the jetpack is active
    var isJetpackOn = false
    
    //Fire emiter and its birth rate
    private var jetpackFire: SKEmitterNode!
    private var particleBirthRate: CGFloat = 0
    //Emitter for light speed
    private var lightSpeedNode: SKEmitterNode!
    
    //Current position on the scene
    var pos: CGPoint {
        return ninja.position
    }
    
    init(scene: GameScene) {
        self.scene = scene
        createFrames()
    }
    
    //MARK: - Create frames
    //Initializes all frames to be used in different ninja modes
    func createFrames() {
        for mode in NinjaMode.allCases {
            let ninjaAtlas = SKTextureAtlas(named: mode.rawValue)
            var frames: [SKTexture] = []
            
            let numImgs = ninjaAtlas.textureNames.count
            for i in 0..<numImgs {
                let name = "\(mode.rawValue)__00\(i)"
                frames.append(ninjaAtlas.textureNamed(name))
            }
            ninjaModes[mode] = frames
        }
        
        let reviveAtlas = SKTextureAtlas(named: NinjaMode.Dead.rawValue)
        var frames: [SKTexture] = []
        let numImgs = reviveAtlas.textureNames.count
        for i in (0..<numImgs).reversed() {
            let name = "\(NinjaMode.Dead.rawValue)__00\(i)"
            frames.append(reviveAtlas.textureNamed(name))
        }
        reviveMode = frames
    }
    
    //MARK: - Build ninja
    //Config properties of ninja node and its physics body
    func buildNinja(mode: NinjaMode) {
        let firstFrameTexture = ninjaModes[mode]![0]
        ninja = SKSpriteNode(texture: firstFrameTexture)
        ninja.zPosition = 101
        
        ninja.setScale(0.15)
        ninja.position = CGPoint(x: scene.frame.minX + 200, y: scene.frame.minY + 70)
        ninja.name = "Ninja"
        ninja.physicsBody = SKPhysicsBody(texture: firstFrameTexture, size: ninja.size)
        ninja.physicsBody?.isDynamic = true
        ninja.physicsBody?.allowsRotation = false
        ninja.physicsBody?.affectedByGravity = true
        ninja.physicsBody?.categoryBitMask = .ninjaCategory
        ninja.physicsBody?.collisionBitMask = .groundCategory
        ninja.physicsBody?.contactTestBitMask = .groundCategory | .coinCategory | .bulletCategory
        scene.addChild(ninja)
    }
    
    //MARK: - Animate ninja
    func animateNinja(mode: NinjaMode) {
        //We dont want to animate again if current mode is the same, and disallow animations if ninja is dead already
        guard currentMode != mode || currentMode != .Dead else {return}
        let runSpeed = scene.gameSpeed < 10 ? (0.1 - Double(scene.gameSpeed / 200)) : 0.045

        let timePerFrame = (mode == .Run || mode == .RunImmortal || mode == .RunMagnet) ? runSpeed : 0.1
        
        //Animate dead ninja and return
        if mode == .Dead {
            killNinja()
            return
        }
        ninja.run(SKAction.repeatForever(SKAction.animate(with: ninjaModes[mode]!, timePerFrame: timePerFrame, resize: false, restore: false)), withKey: .ninjaAnimation)
        currentMode = mode
    }
    
    //MARK: - Show, hide flames
    func showFlames() {
        if jetpackFire == nil {
            jetpackFire = SKEmitterNode(fileNamed: "jetpackfire")
            jetpackFire!.particleSize = CGSize(width: 50, height: 50)
            jetpackFire!.position = CGPoint(x: -(ninja.frame.width + 55), y: -(ninja.frame.height + 38))
            jetpackFire!.targetNode = scene
            particleBirthRate = jetpackFire!.particleBirthRate
            ninja.addChild(jetpackFire!)
        } else {
            jetpackFire.particleBirthRate = particleBirthRate
        }
    }
    
    func hideFlames() {
        jetpackFire?.particleBirthRate = 0
    }
    
    //MARK: - Animate lightspeed
    func animateLightSpeed(on: Bool) {
        if on && lightSpeedNode == nil {
            lightSpeedNode = SKEmitterNode(fileNamed: "lightspeed")
            lightSpeedNode.particleSize = CGSize(width: 50, height: 50)
            lightSpeedNode.position = CGPoint(x: -(ninja.frame.width), y: -(ninja.frame.height + 38))
            lightSpeedNode.targetNode = scene
            ninja.addChild(lightSpeedNode!)
        } else if !on && lightSpeedNode != nil {
            lightSpeedNode.particleBirthRate = 0
            lightSpeedNode.removeFromParent()
            lightSpeedNode = nil
        }
    }
    
    //MARK: - Kill ninja
    private func killNinja() {
        ninja.removeAllActions()
        hideFlames()
        
        let rotate = SKAction.rotate(byAngle: -(.pi * 2), duration: 0.7)
        let move = SKAction.moveBy(x: 100, y: 100, duration: 0.7)
        let moveDown = SKAction.moveTo(y: scene.frame.minY + 70, duration: 0.7)
        let animate = SKAction.animate(with: ninjaModes[.Dead]!, timePerFrame: 0.2, resize: true, restore: false)
        let group = SKAction.group([rotate, move, animate, moveDown])
        
        ninja.run(group)
        ninja = SKSpriteNode(texture: ninjaModes[.Dead]!.first!)
        currentMode = .Dead
    }
    
    //MARK: - Revive ninja
    func reviveNinja() {
        let ninjaNode = scene.childNode(withName: "Ninja")
        
        let rotate = SKAction.rotate(byAngle: (.pi * 2), duration: 0.5)
        let move = SKAction.moveBy(x: -100, y: 100, duration: 0.5)
        let animate = SKAction.animate(with: reviveMode, timePerFrame: 0.05, resize: true, restore: false)
        let group = SKAction.group([rotate, move, animate])

        let setRun = SKAction.sequence([group, SKAction.run {
            let runSpeed = self.scene.gameSpeed < 10 ? (0.1 - Double(self.scene.gameSpeed / 200)) : 0.045

            ninjaNode?.run(SKAction.repeatForever(SKAction.animate(with: self.ninjaModes[.Run]!, timePerFrame: runSpeed, resize: true, restore: false)), withKey: .ninjaAnimation)
            self.currentMode = .Run
        }])
        ninjaNode?.run(setRun)
        ninja = ninjaNode as! SKSpriteNode
        
    }
    
    //MARK: - Reset
    func reset() {
        ninja.removeFromParent()
        jetpackFire = nil
        
        buildNinja(mode: .Run)
        animateNinja(mode: .Idle)
    }
    
    //MARK: - Toggle lightspeed
    //To be decided whether to allow touches during lightspeed
    func toggleLightSpeed(on: Bool) {
        if on {
            isJetpackOn = true
            hideFlames()
            ninja.physicsBody?.affectedByGravity = false
            ninja.physicsBody?.isDynamic = false
            ninja.position = CGPoint(x: scene.frame.minX + 200, y: scene.frame.height / 2)
        } else {
            isJetpackOn = false
            ninja.physicsBody?.affectedByGravity = true
            ninja.physicsBody?.isDynamic = true
        }
        animateLightSpeed(on: on)
    }
}
