//
//  ImageTableViewCell.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    var imageData: NSData? {
        didSet {
            if imageData != nil {
                coverImageView.contentMode = .scaleAspectFit
                coverImageView.image = UIImage(data: imageData! as Data)
            }
        }
    }
}
