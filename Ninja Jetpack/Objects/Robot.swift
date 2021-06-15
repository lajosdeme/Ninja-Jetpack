//
//  Robot.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 20..
//

import SpriteKit
import GameplayKit

enum RobotDirection: String, CaseIterable {
    case forward, backward
}

enum RobotType: String, CaseIterable {
    case robot0, robot1, robot2, robot3
    case robot0backward, robot1backward, robot2backward, robot3backward
    
    static let forward = [robot0,robot1,robot2,robot3]
    static let backward = [robot0backward,robot1backward,robot2backward,robot3backward]
}

class Robot: Object {
    internal var scene: GameScene
    //Containing each direction robot in its own array
    private var forwardRobots = [SKSpriteNode]()
    private var backwardRobots = [SKSpriteNode]()
    
    var isGameOver = false
    
    required init(scene: GameScene) {
        self.scene = scene
    }
    
    var className: String {
        return String(describing: Robot.self)
    }
    
    //How many seconds it takes for the robots to move in either direction
    private var forwardSpeed: TimeInterval = 15
    private var backwardSpeed: TimeInterval = 1
    
    //Save the current speed values when uses enters lightspeed
    private var forwardSpeedBackup: TimeInterval = 15
    private var backwardSpeedBackup: TimeInterval = 1
    
    //MARK: - Generate objects
    func generateObjects() {
        let wait = SKAction.wait(forDuration: 1.5, withRange: 0.5)
        let generate = SKAction.run(createObject)
        let sequence = SKAction.sequence([wait, generate])
        scene.run(SKAction.repeatForever(sequence), withKey: .generateRobot)
    }
    
    //MARK: - Create object
    internal func createObject() {
        let atlas = SKTextureAtlas(named: "Robot")
        var frames: [SKTexture] = []

        let direction = randomDir()
        let robotTpye = randomRobot(direction)
        
        for i in 0..<8 {
            let name = "\(robotTpye.rawValue)_\(i+1)"
            frames.append(atlas.textureNamed(name))
        }
        let randomY = GKRandomDistribution(lowestValue: Int(scene.frame.minY) + 50, highestValue: Int(scene.frame.minY) + 70).nextInt()
        let robot = SKSpriteNode(texture: frames[0])
        robot.zPosition = 100
        
        robot.userData = [
            Key.ObjectType.rawValue: Key.Robot.rawValue,
            Key.Direction.rawValue: direction.rawValue
        ]
        
        robot.setScale(1.5)
        scene.addChild(robot)
        
        //Adding to robots array
        switch direction {
        case .forward:
            forwardRobots.append(robot)
        case .backward:
            backwardRobots.append(robot)
        }
        let name = UUID().uuidString
        robot.name = name
        
        robot.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1)), withKey: "RobotAnim")
        
        //Removing robot from array when animation completes
        let removeAction = SKAction.run {
            switch direction {
            case .forward:
                self.forwardRobots.removeAll { $0.name == name }
            case .backward:
                self.backwardRobots.removeAll { $0.name == name }
            }
        }
        
        //Change animation if game is over
        if isGameOver && direction == .forward {
            let pos = CGPoint(x: -50, y: CGFloat(randomY))
            robot.position = pos
            let speed = forwardSpeed
            robot.run(SKAction.sequence([SKAction.moveTo(x: scene.size.width + 50, duration: speed), SKAction.removeFromParent(), removeAction]), withKey: "robotMoveAnim")
        } else {
            let pos = CGPoint(x: scene.size.width + 50, y: CGFloat(randomY))
            robot.position = pos
            let speed = direction == .forward ? forwardSpeed : backwardSpeed
            robot.run(SKAction.sequence([SKAction.moveTo(x: 0, duration: speed), SKAction.removeFromParent(), removeAction]), withKey: "robotMoveAnim")
        }
    }
    
    //MARK: - Random robot
    private func randomRobot(_ direction: RobotDirection) -> RobotType {
        switch direction {
        case .forward:
            return RobotType.forward[Int(arc4random_uniform(4))]
        case .backward:
            return RobotType.backward[Int(arc4random_uniform(4))]
        }
    }
    
    //MARK: - Random direction
    private func randomDir() -> RobotDirection {
        return RobotDirection.allCases[Int(arc4random_uniform(2))]
    }
    
    //MARK: - Stop generating objects
    func stopGeneratingObjects() {
        scene.removeAction(forKey: .generateRobot)
    }
    
    //MARK: - Toggle light speed
    func toggleLightSpeed(on: Bool) {
        if on {
            forwardSpeedBackup = forwardSpeed
            backwardSpeedBackup = backwardSpeed
            forwardSpeed = 0.2
            backwardSpeed = 0.2
            changeRobotSpeed()
        } else {
            forwardSpeed = forwardSpeedBackup
            backwardSpeed = backwardSpeedBackup
            changeRobotSpeed()
        }
    }

    //MARK: - Change robot direction, speed
    func changeForwardRobotDir() {
        forwardRobots.forEach {
            $0.removeAction(forKey: .robotMoveAnim)
            $0.run(SKAction.sequence([SKAction.moveTo(x: scene.frame.width + 50, duration: forwardSpeed - 10), SKAction.removeFromParent()]), withKey: "robotMoveAnim")
        }
    }
    
    //Increases robot speed as the gamespeed also increases
    func increaseRobotSpeed() {
        forwardSpeed -= 0.005
    }
    
    //Changes the robot speed
    private func changeRobotSpeed() {
        forwardRobots.forEach {
            $0.removeAction(forKey: .robotMoveAnim)
            $0.run(SKAction.sequence([SKAction.moveTo(x: scene.frame.width + 50, duration: forwardSpeed), SKAction.removeFromParent()]), withKey: "robotMoveAnim")
        }
        backwardRobots.forEach {
            $0.removeAction(forKey: .robotMoveAnim)
            $0.run(SKAction.sequence([SKAction.moveTo(x: scene.frame.width + 50, duration: backwardSpeed), SKAction.removeFromParent()]), withKey: "robotMoveAnim")
        }
    }
}
