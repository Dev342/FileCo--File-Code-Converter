//
//  InfoVC.swift
//  CodeConvert
//
//  Created by Tushar Khandaker on 10/9/23.
//

import UIKit

class InfoVC: UIViewController {
    
    @IBOutlet weak var responseLimitLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        responseLimitLabel.text = "Conversion limit: \(OpenAIManager.shared.maxToken) characters. Ensure your code is below this or break it into smaller functions"
    }
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
