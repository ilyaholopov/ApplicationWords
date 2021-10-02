//
//  WordTableViewCell.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var imagePin: UIImageView!
    
    var buttonAction: ((Any) -> Void)?
    
    @IBAction func voiceButton(_ sender: UIButton) {
        self.buttonAction?(sender)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    

}
