//
//  SpecializedTableViewCell.swift
//  iosPrototype
//
//  Created by Dane on 05.12.17.
//  Copyright © 2017 jerry. All rights reserved.
//

import UIKit

class SpecializedTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionContent: UILabel!
    
    @IBOutlet weak var CountValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
