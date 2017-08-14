//
//  MixCollectionTableViewCell.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
import UIKit

class MixCollectionTableViewCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var mixdown: MixDown? {
        didSet {
            updateUI()
        }
    }
    private func updateUI() {
            nameLabel.text = mixdown?.name

            dateLabel.text = ("\(mixdown!.date)")
            dateLabel.sizeToFit()
    }
}
