//
//  GameScene.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 07..
//

//optimize tips
//https://www.hackingwithswift.com/articles/184/tips-to-optimize-your-spritekit-game

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Objects
    private var ninja   : Ninja!
    private var bullet  : Bullet!
    private var coin    : Coin!
    private var powerup : Powerup!
    private var robot   : Robot!
    private var obstacle: Obstacle!
    
    //SceneKit automatically unpauses the screen when app reenters foreground.
    //Override create a new variable and override isPaused so the scene stays paused
    var realPaused: Bool = false {
        didSet {
            self.isPaused = realPaused
        }
    }
    override var isPaused: Bool {
        didSet {
            if (self.isPaused == false && self.realPaused == true) {
                self.isPaused = true
            }
        }
    }
    
    //Distance traveled by ninja
    private var distance : Double = 0 {
        didSet {
            //Update display
            distanceHandler?(distance)
            //Round to int for calculating whether to increare speed
            let distInt = Int(distance.rounded(.toNearestOrAwayFromZero))
            if distInt != prevDist && distInt % 100 == 0 && !isLightspeed {
                gameSpeed += 0.5
                
                robot.increaseRobotSpeed()
                if gameSpeed > 7 && distanceIncreaser < 0.2 {
                    distanceIncreaser += 0.001
                }
                if bullet.shootDuration > 0.2 {
                    bullet.shootDuration -= 0.001
                }
                prevDist = distInt
                simulationGravity = (CGVector(dx: 0, dy: simulationGravity.jetpackOn.dy + 0.01),
                                     CGVector(dx: 0, dy: simulationGravity.jetpackOff.dy - 0.01))
            }
        }
    }
    //We only want to increase the game speed & other values when the game speed rounded to int changes, not when the CGFloat value is increased
    //For this purpose we keep track of the previous distance value
    private var prevDist = 0
    
    //Value by which the traveled distance is increased
    private var distanceIncreaser = 0.18
    
    //Gravity of the physics simulation
    private var simulationGravity = (jetpackOn: (CGVector(dx: 0, dy: 10)), jetpackOff: (CGVector(dx: 0, dy: -8)))
    
    //Current gravity of the simulation
    private var gravity  = CGVector(dx: 0, dy: -5)
    
    //Is game started, is game over
    private var isGameStarted = false
    private var isGameOver    = false
    
    //Used for animating the transitions from fly/run with/without powerups
    private var lastMode: NinjaMode?
    
    //MARK: - Is immortal
    //Is immortality powerup on
    var isImmortal = false {
        didSet {
            var mode: NinjaMode {
                if isImmortal {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .FlyImmortal : .RunImmortal
                } else if isMagnet {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .FlyMagnet : .RunMagnet
                } else {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .Fly : .Run
                }
            }
            lastMode = mode
            ninja.animateNinja(mode: mode)
        }
    }
    
    //MARK: - Is lightspeed
    //Is lightspeed powerup on
    var isLightspeed = false {
        didSet {
            setTemporaryImmortality()
            ninja.toggleLightSpeed(on: isLightspeed)
            robot.toggleLightSpeed(on: isLightspeed)
            animateFly()
            if !isLightspeed {
                physicsWorld.gravity = simulationGravity.jetpackOff
                ninja.hideFlames()
                if ninja.pos.y < 55 {
                    animateRun()
                }
            }
        }
    }
    
    //MARK: - Is magnet
    //Is magnet powerup on
    var isMagnet = false {
        didSet {
            var mode: NinjaMode {
                if isMagnet {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .FlyMagnet : .RunMagnet
                } else if isImmortal {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .FlyImmortal : .RunImmortal
                } else {
                    return (ninja.isJetpackOn || ninja.pos.y > 55) ? .Fly : .Run
                }
            }
            lastMode = mode
            ninja.animateNinja(mode: mode)
        }
    }
    
    //Set to give extra 2 seconds after lightspeed deactivates
    private var temporaryImmortality = false
    
    //How fast the background moves
    var gameSpeed      : CGFloat = 6
    //Set when ninja dies, so speed can be restored incase of revived
    var lastGameSpeed  : CGFloat?
    
    //Closures for updating the distance, coin count in the GameVC
    var distanceHandler: ((Double) -> ())?
    var coinHandler    : ((Int) -> ())?
    var gameOverHandler: (() -> ())?
    var gameStartHandler: (() -> ())?
    var powerupAlertHandler: ((_ type: PowerupType) -> ())?
    
    //MARK: - Init
    override init(size: CGSize) {
        super.init(size: size)
        physicsWorld.gravity = gravity
        initAllObjects()
        NotificationCenter.default.addObserver(self, selector: #selector(collectedPowerupsChanged(_:)), name: .collectedPowerupsChanged, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Create bg, scene, ninja on start
    override func didMove(to view: SKView) {
        createBackground()
        createScene()
        ninja.buildNinja(mode: .Run)
        ninja.animateNinja(mode: .Idle)
    }
    
    //MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard !isPaused else {return}
        
        // Called before each frame is rendered
        if isGameStarted == true {
            
            //Increasing the distance
            distance += gameSpeed != 0 ? (isLightspeed ? 0.4 : distanceIncreaser) : 0
            //Moving all static objects so they seem stationary
            moveAllObjects()
            //Increasing game speed
            let speed = self.isLightspeed ? 50.0 : self.gameSpeed
            //Moving background
            enumerateChildNodes(withName: "background", using: ({
                (node, error) in
                let bg = node as! SKSpriteNode

                bg.position = CGPoint(x: bg.position.x - speed, y: bg.position.y)
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                }
            }))
            //Move coins towards ninja if powerup enabled
            if isMagnet || coin.hasMagneted {
                moveCoins()
            }
        }
    }
    //MARK: - Handle touches
    //Creates scene objects if the game hasent been started
    //Animates ninja, sets gravity
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //If the touch event is from activating a purchased powerup we ignore it
        guard !(touches.first?.gestureRecognizers?.count ?? 0 > 1) else { return }
        //If game is over or lightspeed we ignore touches
        guard !isGameOver && !isLightspeed else {return}
        //If this is the first touch event we create objects and start game
        if !isGameStarted {
            createAllObjects()
            gameStartHandler?()
            isGameStarted = true
        }
        //Ninja animation change when jetpack on
        ninja.isJetpackOn = true
        animateFly()
        ninja.showFlames()
        //Change gravity
        physicsWorld.gravity = simulationGravity.jetpackOn
    }
    
    //Sets gravity, animates ninja
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //If game is over or lightspeed we ignore event
        guard !isGameOver && !isLightspeed else {return}
        //Set ninja properties, simulation gravity
        ninja.isJetpackOn = false
        physicsWorld.gravity = simulationGravity.jetpackOff
        ninja.hideFlames()
        if ninja.pos.y < 55 {
            animateRun()
        }
    }
    
    //MARK: - Create scene
    private func createScene() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + 20, width:   self.frame.width, height: self.frame.height - 20))
        self.physicsBody?.categoryBitMask = .groundCategory
        self.physicsBody?.contactTestBitMask = .ninjaCategory
        self.physicsBody?.collisionBitMask = .ninjaCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
    
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    }
    
    //MARK: - Create background
    private func createBackground() {
        //Create two background images which we will move when game starts
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "background1")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:(CGFloat(i) * self.frame.width), y:0)
            background.name = "background"
            background.size = size
            background.userData = [Key.ObjectType.rawValue: Key.BG.rawValue]
            background.physicsBody?.isDynamic = false
            addChild(background)
        }
    }
    
    //MARK: - Set speed to zero
    //When game is over setting speed to zero
    //Saving the last speed in case of revival
    private func setSpeedToZero() {
        if gameSpeed != 0 {
            lastGameSpeed = gameSpeed
        }
        gameSpeed = 0
    }
    
    //MARK: - Object logic
    //Initializes all objects for use with the current scene
    private func initAllObjects() {
        ninja = Ninja(scene: self)
        bullet = Bullet(scene: self)
        coin = Coin(scene: self)
        powerup = Powerup(scene: self)
        robot = Robot(scene: self)
        obstacle = Obstacle(scene: self)
    }
    
    //Starts generating all objects with random times and random y positions on the current scene
    private func createAllObjects() {
        bullet.generateObjects()
        coin.generateObjects()
        powerup.generateObjects()
        robot.generateObjects()
        obstacle.generateObjects()
    }
    
    //Moves all static objects in the opposite direction that the background moves
    //This makes them seem like they are actually standing in place
    private func moveAllObjects() {
        coin.moveAllObjects(self)
        powerup.moveAllObjects(self)
        obstacle.moveAllObjects(self)
    }
    
    //MARK: - Finish, reset game
    //Called when player dies, sets game over to true and stops generating objects
    private func finishGame() {
        isGameOver = true
        robot.isGameOver = true
        physicsWorld.gravity = gravity
        powerup.stopGeneratingObjects()
        coin.stopGeneratingObjects()
        obstacle.stopGeneratingObjects()
    }
    
    //Resets every value to its starting state
    //Stops generating objects
    //Called when user selects retry or quit
    func resetGame(retry: Bool = false) {
        finishGame()
        
        self.removeAllChildren()
        isGameStarted = false
        isGameOver = false
        robot.isGameOver = false
        gameSpeed = 6
        simulationGravity = (jetpackOn: (CGVector(dx: 0, dy: 9)), jetpackOff: (CGVector(dx: 0, dy: -5)))
        bullet.shootDuration = 0.4
        
        robot.stopGeneratingObjects()
        bullet.stopGeneratingObjects()
        
        coin.removeAllObjects()
        obstacle.removeAllObjects()
        powerup.removeAllObjects()
        
        distance = 0
        prevDist = 0
        coin.resetCoinCount()
        
        powerup.removeCollectedPowerups()
        
        createBackground()
        createScene()
        ninja.reset()
        
        isImmortal = false
        isMagnet = false
        isLightspeed = false
        
        if retry {
            createAllObjects()
            isGameStarted = true
            ninja.animateNinja(mode: .Run)
        } else {
            ninja.animateNinja(mode: .Idle)
        }
    }
    
    //MARK: - Animate dead, revive
    //Called when ninja node contacts bullet/obstacle
    //Animates the shot emitter and dead ninja
    func animateDead(contact: SKPhysicsContact, isBullet: Bool = false) {
        isGameOver = true
        if let node = SKEmitterNode(fileNamed: "shot") {
            node.position = contact.contactPoint
            let size = isBullet ? CGSize(width: 10, height: 10) : CGSize(width: 15, height: 15)
            node.particleSize = size
            node.particleZPosition = 101
            addChild(node)
            ninja.animateNinja(mode: .Dead)
            finishGame()
        }
        robot.changeForwardRobotDir()
    }
    
    //Called when user uses a revive purchase
    //Resets pause, game over + sets a temporary immortality to avoid collision with objects while animating
    //Animates the ninja and resets the game speed
    //Restarts the generation of objects
    func animateRevive() {
        realPaused = false
        isGameOver = false
        robot.isGameOver = false
        ninja.reviveNinja()
        self.setTemporaryImmortality(4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.gameSpeed = self.lastGameSpeed ?? 6
        }
        powerup.generateObjects()
        coin.generateObjects()
        obstacle.generateObjects()
    }
    
    //MARK: - Powerups changed
    @objc func collectedPowerupsChanged(_ notification: Notification) {
        if let p = notification.object as? [String] {
            let powerups = Set(p)
            
            let newImmortal = powerups.contains(PowerupType.Immortality.rawValue)
            let newLightspeed = powerups.contains(PowerupType.Lightspeed.rawValue)
            let newMagnet = powerups.contains(PowerupType.Magnet.rawValue)
            
            if isImmortal != newImmortal {
                isImmortal = newImmortal
                if newImmortal {
                    powerupAlertHandler?(.Immortality)
                }
            }
            if isLightspeed != newLightspeed {
                isLightspeed = newLightspeed
                if newLightspeed {
                    powerupAlertHandler?(.Lightspeed)
                }
            }
            if isMagnet != newMagnet {
                isMagnet = newMagnet
                if newMagnet {
                    powerupAlertHandler?(.Magnet)
                }
            }
        }
    }
    
    //MARK: - Move coins
    //Moves coins towards the user
    //The "magneted" tag is used for coins that already started moving towards the user when the magnet expires
    private func moveCoins() {
        for c in coin.objects {
            if isMagnet {
                  c.userData!["magneted"] = true
            }
            guard (c.userData!["magneted"] as? Bool) == true else {return}
            let location = ninja.pos
            
            //Aim
            let dx = location.x - c.position.x
            let dy = location.y - c.position.y
            let angle = atan2(dy, dx)

            //Seek
            let vx = cos(angle) * 16
            let vy = sin(angle) * 16

            c.position.x += vx
            c.position.y += vy
        }
    }
    
    //MARK: - Set temporary immortality
    //After lightspeed ends we give 2 seconds of immortality to user
    //So we avoid death from collision with objects when changing to regular speed
    private func setTemporaryImmortality(_ time: TimeInterval = 3) {
        run(SKAction.sequence([
            SKAction.run { self.temporaryImmortality = true },
            SKAction.wait(forDuration: time),
            SKAction.run {self.temporaryImmortality = false }
        ]))
    }
    
    //MARK: - Animate fly, run
    //Pick the correct texture depending on mode and animate ninja
    private func animateFly() {
        if lastMode == .FlyImmortal || lastMode == .RunImmortal {
            ninja.animateNinja(mode: .FlyImmortal)
        } else if lastMode == .FlyMagnet || lastMode == .RunMagnet {
            ninja.animateNinja(mode: .FlyMagnet)
        } else {
            ninja.animateNinja(mode: .Fly)
        }
    }
    
    private func animateRun() {
        if lastMode == .FlyImmortal || lastMode == .RunImmortal {
            ninja.animateNinja(mode: .RunImmortal)
        } else if lastMode == .FlyMagnet || lastMode == .RunMagnet {
            ninja.animateNinja(mode: .RunMagnet)
        } else {
            ninja.animateNinja(mode: .Run)
        }
    }
    
    //MARK: - Did begin contact
    func didBegin(_ contact: SKPhysicsContact) {
        //toggle run / fly mode
        if (contact.bodyA.categoryBitMask & .groundCategory) == .groundCategory && (contact.bodyB.categoryBitMask & .ninjaCategory) == .ninjaCategory ||
            (contact.bodyB.categoryBitMask & .groundCategory) == .groundCategory && (contact.bodyA.categoryBitMask & .ninjaCategory) == .ninjaCategory {
            guard !isGameOver else {return}
            if contact.contactPoint.y < 50 && !ninja.isJetpackOn && isGameStarted {
                print(contact.contactPoint.y)
                animateRun()
            }
        }
        
        //Collect coins
        if (contact.bodyA.categoryBitMask & .coinCategory) == .coinCategory && (contact.bodyB.categoryBitMask & .ninjaCategory) == .ninjaCategory {
            contact.bodyA.node?.physicsBody?.categoryBitMask = .none
            coin.remove(contact.bodyA.node)
            coin.incrementCoinCount()
        } else if (contact.bodyB.categoryBitMask & .coinCategory) == .coinCategory && (contact.bodyA.categoryBitMask & .ninjaCategory) == .ninjaCategory {
            contact.bodyB.node?.physicsBody?.categoryBitMask = .none
            coin.remove(contact.bodyB.node)
            coin.incrementCoinCount()
        }
        
        guard !isGameOver else { return }
        
        //Pickup powerup
        if (contact.bodyA.categoryBitMask & .powerupCategory) == .powerupCategory && (contact.bodyB.categoryBitMask & .ninjaCategory) == .ninjaCategory {
            powerup.collect(contact.bodyA.node)
        } else if (contact.bodyB.categoryBitMask & .powerupCategory) == .powerupCategory && (contact.bodyA.categoryBitMask & .ninjaCategory) == .ninjaCategory {
            powerup.collect(contact.bodyB.node)
        }

        //Hit by bullet, die
        if (contact.bodyA.categoryBitMask & .bulletCategory) == .bulletCategory {
            if !isImmortal && !isLightspeed && !temporaryImmortality {
                run(SKAction.sequence([
                                        SKAction.run { self.animateDead(contact: contact, isBullet: true) },
                                        SKAction.wait(forDuration: 1),
                                        SKAction.run(setSpeedToZero),
                                        SKAction.run { self.gameOverHandler?() }
                ]))
            }
            contact.bodyA.node?.removeFromParent()
        } else if (contact.bodyB.categoryBitMask & .bulletCategory) == .bulletCategory {
            if !isImmortal && !isLightspeed && !temporaryImmortality {
                run(SKAction.sequence([
                                        SKAction.run { self.animateDead(contact: contact, isBullet: true) },
                                        SKAction.wait(forDuration: 1),
                                        SKAction.run(setSpeedToZero),
                                        SKAction.run { self.gameOverHandler?() }
                ]))
            }
            contact.bodyB.node?.removeFromParent()
        }
        
        //Contact with laser - die
        if (contact.bodyA.categoryBitMask & .obstacleCategory) == .obstacleCategory &&
            !isImmortal && !isLightspeed && !temporaryImmortality {
            run(SKAction.sequence([
                                    SKAction.run { self.animateDead(contact: contact) },
                                    SKAction.wait(forDuration: 1),
                                    SKAction.run(setSpeedToZero),
                                    SKAction.run { self.gameOverHandler?() }
            ]))
        } else if (contact.bodyB.categoryBitMask & .obstacleCategory) == .obstacleCategory &&
                    !isImmortal && !isLightspeed && !temporaryImmortality {
            run(SKAction.sequence([
                                    SKAction.run { self.animateDead(contact: contact) },
                                    SKAction.wait(forDuration: 1),
                                    SKAction.run(setSpeedToZero),
                                    SKAction.run { self.gameOverHandler?() }
            ]))
        }
    }
}
