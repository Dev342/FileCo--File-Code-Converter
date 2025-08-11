//
//  Extension.swift
//  CodeConvert
//
//  Created by Tushar Khandaker on 9/9/23.
//

import UIKit

extension UIWindowScene {
    static var focused: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }
}

extension UIView {
    
    func showToast(message: String, duration: TimeInterval) {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let toastLabel = UILabel(frame: CGRect(x: (screenWidth / 2) - 37.5, y: (screenHeight/2) - 17.5, width: 75, height: 35))
        toastLabel.backgroundColor = UIColor.white
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
    
        self.addSubview(toastLabel)
        UIView.animate(withDuration: duration, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension String {
    func filterString()-> String? {
        if let range = self.range(of: "\n") {
            let newString = String(self[range.upperBound...])
            return newString
        }
        return nil
    }
 
}
