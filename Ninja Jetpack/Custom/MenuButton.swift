//
//  MenuButton.swift
//  Hyperion
//
//  Created by Lajos Deme on 2021. 04. 24..
//

import UIKit

class MenuButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configButton()
    }
    
    private func configButton() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .yellow
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = UIFont(name: "Zorque-Regular", size: 17)
        self.setTitle(self.titleLabel?.text?.uppercased(), for: .normal)
    }
}
