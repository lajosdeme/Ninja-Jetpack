//
//  ScoreBoard.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 10..
//

import UIKit

class ScoreBoard: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var boardImg: UIImageView!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var coinCountLabel: UILabel!
    
    var highscore: Int = DataManager.shared.get().highScore {
        didSet {
            var text = highscore.createLabelText()
            text.append(" m")
            highScoreLabel.text  = text
        }
    }
    
    var coinCount: Int = DataManager.shared.get().coinCount {
        didSet {
            coinCountLabel.text = coinCount.createLabelText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ScoreBoard", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configLabels()
        boardImg.layer.masksToBounds = false
        boardImg.layer.shadowColor = UIColor.black.cgColor
        boardImg.layer.shadowOffset = CGSize(width: 20, height: 10)
        boardImg.layer.shadowRadius = 10
    }
    
    private func configLabels() {
        var scoreText = highscore.createLabelText()
        scoreText.append(" m")
        highScoreLabel.text  = scoreText
        
        coinCountLabel.text = coinCount.createLabelText()
    }
}
