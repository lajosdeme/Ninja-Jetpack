//
//  ReviveView.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 05. 17..
//

import UIKit

protocol ReviveViewDelegate {
    func revivePurchased()
    func timeElapsed()
}

class ReviveView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var reviveImage: UIImageView!
    
    private var circleLayer: CAShapeLayer!
    
    var delegate: ReviveViewDelegate?
    
    var boughtRevive = false
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    //MARK: - Common init
    private func commonInit() {
        Bundle.main.loadNibNamed("ReviveView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Creating the circle that will show the time left
        if circleLayer == nil {
            let path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: reviveImage.center.y), radius: (frame.size.width)/2 + 5, startAngle: 0, endAngle: .pi * 2.0, clockwise: true)
            circleLayer = CAShapeLayer()
            circleLayer.path = path.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor.red.cgColor
            circleLayer.lineWidth = 5.0
            circleLayer.strokeEnd = 0
            
            layer.addSublayer(circleLayer)
        }
    }
    
    //MARK: - Animate circle
    func animateCircle() {
        guard circleLayer.animationKeys()?.contains("animateCircle") != true else {return}
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 5
        anim.fromValue = 0
        anim.toValue = 1
        anim.timingFunction = CAMediaTimingFunction(name: .linear)

        anim.isRemovedOnCompletion = true
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.delegate?.timeElapsed()
        }
        circleLayer.add(anim, forKey: "animateCircle")
        CATransaction.commit()
    }
    
    //Buy revive
    @IBAction func buyAction(_ sender: Any) {
        circleLayer.removeAllAnimations()
        CATransaction.setCompletionBlock(nil)
        boughtRevive = true
        delegate?.revivePurchased()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        delegate?.timeElapsed()
    }
}
