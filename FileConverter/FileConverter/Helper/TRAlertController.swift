

import Foundation
import UIKit

enum ImageType {
    case JPG
    case PNG
    case PDf
    case Cancel
}

class TRAlertController: NSObject {
    
    class func showAlert(title : String, message: String, isCancel: Bool, okButtonTitle: String, cancelButtonTitle: String, completion: ((Bool)->())?) {
        let alertController = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: okButtonTitle, style: .default) { action -> Void in
            if completion != nil {
                completion!(true)
            }
        }
        alertController.addAction(okButton)
        
        if isCancel {
            
            let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel){ action -> Void in
                if completion != nil {
                    completion!(false)
                }
            }
            alertController.addAction(cancelButton)
        }
        
        alertController.present(animated: true, completion: nil)
    }
    
    class func showSimpleAlert(title : String, message: String, doneButtonTitle: String) {
        let alertController = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        let doneButton =  UIAlertAction(title: doneButtonTitle, style: .default)
        alertController.addAction(doneButton)
        alertController.present(animated: true, completion: nil)
    }
    
    class func showAlertWithThreeButton(title : String, message: String, button1Title: String, button2Title: String, completion: ((Bool?)->())?) {
        let alertController = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        
        let button1Action = UIAlertAction(title: button1Title, style: .default) { action -> Void in
            if completion != nil {
                completion!(true)
            }
        }
        alertController.addAction(button1Action)
        
        let button2Action = UIAlertAction(title: button2Title, style: .default) { (action) -> Void in
                if completion != nil {
                    completion!(false)
                }
          }
        alertController.addAction(button2Action)


        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel){ action -> Void in
            if completion != nil {
                completion!(nil)
            }
        }
        alertController.addAction(cancelButtonAction)

        alertController.present(animated: true, completion: nil)
    }
    
    class func showAlertWithFourButton(title : String, message: String, button1Title: String, button2Title: String, button3Title: String, completion: ((ImageType)->())?) {
        let alertController = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        
        let button1Action = UIAlertAction(title: button1Title, style: .default) { action -> Void in
            if completion != nil {
                completion!(.JPG)
            }
        }
        alertController.addAction(button1Action)
        
        let button2Action = UIAlertAction(title: button2Title, style: .default) { (action) -> Void in
                if completion != nil {
                    completion!(.PNG)
                }
          }
        alertController.addAction(button2Action)
        
        let button3Action = UIAlertAction(title: button3Title, style: .default) { (action) -> Void in
                if completion != nil {
                    completion!(.PDf)
                }
          }
        alertController.addAction(button3Action)



        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel){ action -> Void in
            if completion != nil {
                completion!(.Cancel)
            }
        }
        alertController.addAction(cancelButtonAction)

        alertController.present(animated: true, completion: nil)
    }
    
   class func showAlertWithTF(title : String, message: String,okButtonTitle: String, cancelButtonTitle: String, completion: ((String)->())?) {
        let alertController = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: okButtonTitle, style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                if completion != nil {
                    completion!(text)
                }
            }
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Add requirement"
        }
        
        alertController.addAction(addAction)
        
        alertController.addAction(cancelAction)
        
        alertController.present(animated: true, completion: nil)
    }
}

private var windows: [String:UIWindow] = [:]

class CustomAlertController: UIAlertController {
    
    var wid: String?
    
    func present(animated: Bool, completion: (() -> Void)?) {
        
        guard let window = UIWindowScene.focused.map(UIWindow.init(windowScene:)) else {
            return
        }
        window.rootViewController = UIViewController()
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        window.rootViewController!.present(self, animated: animated, completion: completion)
        
        wid = UUID().uuidString
        windows[wid!] = window
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let wid = wid {
            windows[wid] = nil
        }
    }
}

