//
//  GameViewController.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 07..
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override var shouldAutorotate: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscape }
    override var prefersStatusBarHidden: Bool { return true }
    
    var scene: GameScene!
    
    //MARK: - UI elements
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var resumeButton: MenuButton!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var powerupAlert: UIImageView!
    
    @IBOutlet weak var progressScoreContainer: UIView!
    @IBOutlet weak var scoreBoard: ScoreBoard!
    
    @IBOutlet weak var shopButton: MenuButton!
    
    @IBOutlet weak var powerupStackView: UIStackView!
    
    @IBOutlet weak var immortalityContainer: CustomView!
    @IBOutlet weak var lightspeedContainer: UIView!
    @IBOutlet weak var magnetContainer: UIView!
    
    @IBOutlet weak var reviveView: ReviveView!
    
    @IBOutlet weak var stackViewVerticalConstraint: NSLayoutConstraint!
    private var stackViewVerticalConstraintOriginalValue: CGFloat!
    
    @IBOutlet weak var titleViewVerticalConstraint: NSLayoutConstraint!
    private var titleViewVerticalConstraintOriginalValue: CGFloat!
    
    @IBOutlet weak var scoreBoardTopConstraint: NSLayoutConstraint!
    private var scoreBoardTopConstraintOriginalValue: CGFloat!
    
    @IBOutlet weak var powerupStackViewVeritcalConstraint: NSLayoutConstraint!
    
    private var dataManager = DataManager.shared
    
    private var highScore = DataManager.shared.get().highScore {
        didSet {
            scoreBoard.highscore = highScore
        }
    }
    
    private var coins = DataManager.shared.get().coinCount {
        didSet {
            scoreBoard.coinCount = coins
        }
    }
    
    private var distance = 0 {
        didSet {
            var text = distance.createLabelText()
            text.append(" m")
            distanceLabel.text  = text
            
            if distance > highScore {
                highScore = distance
            }
        }
    }
    
    private var coinCount = 0 {
        didSet {
            coinLabel.text = coinCount.createLabelText()
        }
    }
    
    //MARK: - Is game paused
    private var isGamePaused = false {
        didSet {
            let img = isGamePaused ? UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysTemplate) : UIImage(named: "pause")?.withTintColor(.white, renderingMode: .alwaysTemplate)
            pauseButton.setImage(img, for: .normal)
            scene.realPaused = isGamePaused
            animateStackView(show: isGamePaused)
        }
    }
    
    private var (immortalityCount, lightspeedCount, magnetCount) = DataManager.shared.getPurchasesCount()
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        stackViewVerticalConstraintOriginalValue = stackViewVerticalConstraint.constant
        titleViewVerticalConstraintOriginalValue = titleViewVerticalConstraint.constant
        scoreBoardTopConstraintOriginalValue = scoreBoardTopConstraint.constant
        addGestures()
        reviveView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coinCountChanged), name: .coinCountChanged, object: nil)
    }
    
    //MARK: - Set up view
    private func setUpView() {
        let skView = view as! SKView
        
        skView.isMultipleTouchEnabled = false
        scene = GameScene(size: skView.bounds.size)
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        
        scene.distanceHandler = updateDistance(_:)
        scene.coinHandler = updateCoins(_:)
        scene.gameStartHandler = handleGameStart
        scene.gameOverHandler = handleGameOver
        scene.powerupAlertHandler = showLabel(_:)
        
        skView.presentScene(scene)
    }
    
    //MARK: - Update distance
    private func updateDistance(_ distance: Double) {
        let distInt = Int(distance.rounded(.toNearestOrAwayFromZero))
        self.distance = distInt
    }
    
    //MARK: - Update coins
    private func updateCoins(_ coinsCollected: Int) {
        let diff = coinsCollected - coinCount
        coinCount = coinsCollected
        if coinsCollected == 0 {
            coins = dataManager.get().coinCount
        } else {
            coins += diff
        }
    }
    
    //MARK: - Handle game start/over
    private func handleGameStart() {
        reviveView.isHidden = true
        pauseButton.isHidden = false
        animateTitleView(show: false)
        animateScoreBoard(show: false)
        animateBeginningPowerups()
    }
    private func handleGameOver() {
        dataManager.save(highScore, coins)
        resumeButton.isHidden = true
        
        if coins >= 500 {
            reviveView.isHidden = false
            pauseButton.isHidden = true
            reviveView.animateCircle()
        } else {
            animateStackView(show: true)
            animateScoreBoard(show: true, animated: false)
        }
        
        hidePowerupAnimation()
    }
    
    //MARK: - Show powerup label
    private func showLabel(_ type: PowerupType) {
        switch type {
        case .Immortality:
            powerupAlert.image = UIImage(named: "immortalityLabel")
        case .Magnet:
            powerupAlert.image = UIImage(named: "magnetLabel")
        case .Lightspeed:
            powerupAlert.image = UIImage(named: "lightspeedLabel")
        }
        powerupAlert.transform = .identity.translatedBy(x: 0, y: -100)
        self.powerupAlert.isHidden = false
        UIView.animate(withDuration: 0.1) {
            self.powerupAlert.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                UIView.modifyAnimations(withRepeatCount: 5, autoreverses: true) {
                    self.powerupAlert.transform = .identity.scaledBy(x: 0.9, y: 0.9)
                }
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.powerupAlert.transform = .identity.translatedBy(x: 0, y: -100)
                } completion: { _ in
                    self.powerupAlert.isHidden = true
                }
            }
        }
    }
    
    //MARK: - Animate views
    private func animateStackView(show: Bool) {
        stackViewVerticalConstraint.constant = show ? 0 : stackViewVerticalConstraintOriginalValue
        //TODO
    }
    
    private func animateTitleView(show: Bool) {
        if show {
            titleViewVerticalConstraint.constant = titleViewVerticalConstraintOriginalValue
        }
        UIView.animate(withDuration: 0.1) {
            if show {
                self.titleView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                self.shopButton.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            } else {
                self.titleView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                self.shopButton.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            }
        } completion: { _ in
            if !show {
                self.titleViewVerticalConstraint.constant = -300
            }
            self.shopButton.isHidden = !show
        }
    }
    
    private func animateScoreBoard(show: Bool, animated: Bool = true) {
        self.progressScoreContainer.isHidden = show
        self.pauseButton.isHidden = show
        
        if show {
            scoreBoardTopConstraint.constant = scoreBoardTopConstraintOriginalValue
        }
        if animated {
            UIView.animate(withDuration: 0.3) {
                if show {
                    self.scoreBoard.transform = .identity
                } else {
                    self.scoreBoard.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -300)
                }
            } completion: { _ in
                self.scoreBoard.isHidden = !show
            }
        } else {
            self.scoreBoard.transform = .identity
            self.scoreBoard.isHidden = !show
        }
    }
    
    private func animateBeginningPowerups() {
        guard immortalityCount > 0 || lightspeedCount > 0 || magnetCount > 0 else {return}
        powerupStackView.isHidden = false
        
        immortalityContainer.isHidden = immortalityCount <= 0
        lightspeedContainer.isHidden = lightspeedCount <= 0
        magnetContainer.isHidden = magnetCount <= 0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat, .autoreverse]) {
            self.immortalityContainer.transform = .identity.scaledBy(x: 0.8, y: 0.8)
            self.lightspeedContainer.transform = .identity.scaledBy(x: 0.8, y: 0.8)
            self.magnetContainer.transform = .identity.scaledBy(x: 0.8, y: 0.8)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.hidePowerupAnimation()
        }
    }
    
    private func hidePowerupAnimation(completion: (()->())? = nil) {
        UIView.setAnimationsEnabled(false)
        self.immortalityContainer.layer.removeAllAnimations()
        self.lightspeedContainer.layer.removeAllAnimations()
        self.magnetContainer.layer.removeAllAnimations()
        self.immortalityContainer.transform = .identity
        self.lightspeedContainer.transform = .identity
        self.magnetContainer.transform = .identity
        UIView.setAnimationsEnabled(true)
        self.powerupStackView.isHidden = true
        completion?()
    }
    
    private func addGestures() {
        powerupStackView.isUserInteractionEnabled = true
        let immortalityTap = UITapGestureRecognizer(target: self, action: #selector(immortalityAction))
        immortalityContainer.isUserInteractionEnabled = true
        immortalityContainer.addGestureRecognizer(immortalityTap)
        
        let lightspeedTap = UITapGestureRecognizer(target: self, action: #selector(lightspeedAction))
        lightspeedContainer.isUserInteractionEnabled = true
        lightspeedContainer.addGestureRecognizer(lightspeedTap)
        
        let magnetTap = UITapGestureRecognizer(target: self, action: #selector(magnetAction))
        magnetContainer.isUserInteractionEnabled = true
        magnetContainer.addGestureRecognizer(magnetTap)
    }
    
    
    //MARK: - Action
    @IBAction func pauseAction(_ sender: Any) {
        animateScoreBoard(show: !isGamePaused, animated: false)
        self.resumeButton.isHidden = false
        self.isGamePaused = !self.isGamePaused
        powerupStackView.isUserInteractionEnabled = !isGamePaused
    }
    
    
    @IBAction func quitAction(_ sender: Any) {
        powerupStackView.isUserInteractionEnabled = true
        hidePowerupAnimation()
        resumeButton.isHidden = false
        dataManager.save(highScore, coins)
        scene.resetGame()
        isGamePaused = false
        animateTitleView(show: true)
    }
    
    @IBAction func retryAction(_ sender: Any) {
        powerupStackView.isUserInteractionEnabled = true
        resumeButton.isHidden = false
        dataManager.save(highScore, coins)
        scene.resetGame(retry: true)
        isGamePaused = false
        animateScoreBoard(show: false)
        hidePowerupAnimation() {
            self.animateBeginningPowerups()
        }
    }
    
    @IBAction func resumeAction(_ sender: Any) {
        powerupStackView.isUserInteractionEnabled = true
        resumeButton.isHidden = false
        isGamePaused = false
        animateScoreBoard(show: false)
    }
    
    @IBAction func shopAction(_ sender: Any) {
        let shopVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ShopVC")
        shopVC.modalPresentationStyle = .overFullScreen
        present(shopVC, animated: true, completion: nil)
        
    }
    
    @objc func handleBackground() {
        dataManager.save(highScore, coins)
    }
    
    @objc func coinCountChanged() {
        coins -= 500
        (immortalityCount, lightspeedCount, magnetCount) = DataManager.shared.getPurchasesCount()
    }
    
    @objc func immortalityAction() {
        scene.isImmortal = true
        immortalityContainer.layer.removeAllAnimations()
        immortalityContainer.isHidden = true
        powerupStackView.isHidden = lightspeedContainer.isHidden && magnetContainer.isHidden
        dataManager.spend(powerup: .Immortality)
        (immortalityCount, lightspeedCount, magnetCount) = DataManager.shared.getPurchasesCount()
    }
    
    @objc func lightspeedAction() {
        scene.isLightspeed = true
        lightspeedContainer.layer.removeAllAnimations()
        lightspeedContainer.isHidden = true
        powerupStackView.isHidden = magnetContainer.isHidden && immortalityContainer.isHidden
        dataManager.spend(powerup: .Lightspeed)
        (immortalityCount, lightspeedCount, magnetCount) = DataManager.shared.getPurchasesCount()
    }
    
    @objc func magnetAction() {
        scene.isMagnet = true
        magnetContainer.layer.removeAllAnimations()
        magnetContainer.isHidden = true
        powerupStackView.isHidden = lightspeedContainer.isHidden && immortalityContainer.isHidden
        dataManager.spend(powerup: .Magnet)
        (immortalityCount, lightspeedCount, magnetCount) = DataManager.shared.getPurchasesCount()
    }
}

//MARK: - Revive view delegate
extension GameViewController: ReviveViewDelegate {
    func revivePurchased() {
        guard coins >= 500 else { return }
        dataManager.spendRevive()
        coins -= 500
        reviveView.isHidden = true
        scene.animateRevive()
    }
    
    func timeElapsed() {
        guard !reviveView.boughtRevive && !reviveView.isHidden else {
            reviveView.boughtRevive = false
            return
        }
        
        reviveView.isHidden = true
        animateStackView(show: true)
        animateScoreBoard(show: true, animated: false)
    }
}
