
import UIKit
import OpenAISwift

class RequestVC: UIViewController {
    
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var addWordButton: UIButton!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    
    var codeFile = ""
    var fileURl: URL?
    var solutionList = [String]()
    var isCustomTextAdded = false {
        didSet {
            let color = isCustomTextAdded ? UIColor.darkGray : UIColor.white
            self.languagePicker.setValue(color, forKeyPath: "textColor")
            languagePicker.isUserInteractionEnabled = !isCustomTextAdded
            addWordButton.isSelected = isCustomTextAdded
        }
    }
    var convertInstruction = ""
    let languageArray = ["C", "C++", "C#", "Dart","Java","Kotlin", "Objective-C", "PHP","Python","Ruby","Swift"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = fileURl else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let fileData = TRFileManager.shared.readFileData(from: url) {
            textView.text = fileData
            codeFile = fileData
        } else {
            TRAlertController.showAlert(title: "Error", message: "Failed to read file's data, please select a valid txt file", isCancel: false, okButtonTitle: "OK", cancelButtonTitle: "", completion: { [weak self] isOk in
                self?.navigationController?.popViewController(animated: true)
            })
        }
        self.languagePicker.selectRow(4, inComponent:0, animated:false)
        self.languagePicker.setValue(UIColor.white, forKeyPath: "textColor")
        convertInstruction = addLanguageConvertRequestMessage(with: languageArray[4])
    }
    
    @IBAction func addCustomMessage(_ sender: UIButton) {
        if isCustomTextAdded {
            isCustomTextAdded = false
            convertInstruction = ""
            textView.text = codeFile
        } else {
            TRAlertController.showAlertWithTF(title: "Add Requirement", message: "Add your desire requirement", okButtonTitle: "Add", cancelButtonTitle: "Cancel") { [weak self] text in
                guard let self = self else { return }
                if !text.isEmpty {
                    self.isCustomTextAdded = true
                    self.convertInstruction = text
                }
            }
        }
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            self.displayAnimatedActivityIndicatorView()
            let requestedQuery = prepareRequestMessage(codeFile: codeFile, convertInstruction: convertInstruction)
            
            OpenAIManager.shared.openAI.sendCompletion(with: requestedQuery, maxTokens: OpenAIManager.shared.maxToken) { [weak self] result in // Result<OpenAI, OpenAIError>
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    print("Response ",success.choices?.first?.text ?? "nil", success.choices?.count as Any)
                    if let choices = success.choices {
                        if choices.count > 0 {
                            for choice in choices {
                                if !choice.text.isEmpty  {
                                    if let filterData = choice.text.filterString(){
                                        self.solutionList.append(filterData)
                                    } else {
                                        self.solutionList.append(choice.text)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.hideAnimatedActivityIndicatorView()
                        if self.solutionList.count > 0 {
                            self.navigateSolutionVC()
                        } else {
                            TRAlertController.showAlert(title: "Error", message: "Something Went Wrong, Please Try again", isCancel: false, okButtonTitle: "Ok", cancelButtonTitle: "", completion: nil)
                        }
                    }
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    DispatchQueue.main.async {
                        self.hideAnimatedActivityIndicatorView()
                        print("error",failure.localizedDescription)
                        TRAlertController.showAlert(title: "Error", message: "The operation couldn’t be completed. Please Try Again.", isCancel: false, okButtonTitle: "Ok", cancelButtonTitle: "", completion: nil)
                    }
                }
            }
        } else {
            TRAlertController.showSimpleAlert(title: "No Internet", message: "Internet Connection not Available! Please check Wifi or Cellular Data.", doneButtonTitle: "OK")
        }
    }
    
    func navigateSolutionVC() {
        let navigationController =  storyboard?.instantiateViewController(identifier: "SolutionNavVC") as! UINavigationController
        navigationController.modalPresentationStyle = .fullScreen
        let solutionVC = navigationController.viewControllers.first as! SolutionVC
        solutionVC.delegate = self
        solutionVC.solutionList = self.solutionList
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func addLanguageConvertRequestMessage(with language: String)-> String {
        return "Please convert this code into \(language)"
    }
    
    func prepareRequestMessage(codeFile:String, convertInstruction: String)-> String {
        let message = codeFile + "\n\n" + convertInstruction
        textView.text = message
        return message
    }
   
}

extension RequestVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        convertInstruction = addLanguageConvertRequestMessage(with: languageArray[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageArray[row]
    }
}

extension RequestVC: SolutionVCDelegate {
    
    func resetTextView() {
        textView.text = codeFile
        isCustomTextAdded = false
        solutionList = [String]()
    }
}
