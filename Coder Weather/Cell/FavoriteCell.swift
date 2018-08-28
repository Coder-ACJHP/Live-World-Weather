//
//  FavoriteCell.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 27.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var termperatureLabel: UILabel!
    @IBOutlet weak var iconHolder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
