//
//  PlacesCollectionViewCell.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/13/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import UIKit

class PlacesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var lblOpenOrClosed: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var vicinity: UILabel!
    @IBOutlet weak var types: UILabel!
    @IBOutlet weak var firstType: UILabel!
    @IBOutlet weak var secondType: UILabel!
    @IBOutlet weak var thirdtype: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
