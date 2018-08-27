//
//  ImageCell.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 4.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var isShowing = false
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var shadowLayer: UIView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                setSelected()
                focusIsGain()
            } else {
                setUnSelected()
                focusIsLost()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Give some radius to corners
        shadowLayer.alpha = 0
        imageContainer.layer.masksToBounds = true
        imageContainer.layer.cornerRadius = 5.0
    }
    
    // Make it bigger with animation
    func focusIsGain() {
        UIView.animate(withDuration: 0.6) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    // Return it to normal size with animation
    func focusIsLost() {
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func setSelected() {
        UIView.animate(withDuration: 0.4) {
            self.shadowLayer.alpha = 1.0
        }
    }
    
    func setUnSelected() {
        UIView.animate(withDuration: 0.4) {
            self.shadowLayer.alpha = 0
        }
    }
}
