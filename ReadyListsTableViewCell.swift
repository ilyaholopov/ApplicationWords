//
//  ReadyListsTableViewCell.swift
//  WORDS
//
//  Created by Илья Холопов on 26.02.2022.
//

import UIKit

class ReadyListsTableViewCell: UITableViewCell {

    @IBOutlet weak var addListSwitch: UISwitch!
    @IBOutlet weak var nameListLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 15
            frame.size.width -= 2 * 15
            super.frame = frame
        }
    }
}
