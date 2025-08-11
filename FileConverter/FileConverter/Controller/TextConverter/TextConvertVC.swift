//
//  TextConvertVC.swift
//  FileConverter
//
//  Created by Tushar Khandaker on 13/9/23.
//

import UIKit
import DocX

enum FileType: String {
    case Txt = "Txt"
    case Docx = "Docx"
    case PdF = "Pdf"
    case Image = "Image"
    case None = "None"
}

class TextConvertVC: UIViewController {

    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    
    var sourceFileType = FileType.Txt
    var showAsDocConverterView = false
    var fileTextContent = ""
    var dataSource = [FileType]()
    var convertType = FileType.None

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = fileTextContent
        dataSource = setPickerDataSource(on: sourceFileType)
        self.pickerView.selectRow(0, inComponent:0, animated:false)
        self.pickerView.setValue(UIColor.white, forKeyPath: "textColor")
        convertType = dataSource[0]
        
    }
    
    @IBAction func converFile(_ sender: UIButton) {
        
        switch convertType {
        case .Txt:
            if let txtFileURL = TRFileManager.shared.saveText(fileTextContent, toFilename: UUID().uuidString) {
                if TRFileManager.shared.isURLInDocumentDirectory(txtFileURL) {
                    navigateCommonShareVC(with: txtFileURL, fileType: .File)
                }
            } else {
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this file into Txt. Please try again.", doneButtonTitle: "OK")
            }
            
        case .Docx:
            if let docxUrl = convertToDocx(with: fileTextContent) {
                if TRFileManager.shared.isURLInDocumentDirectory(docxUrl) {
                    navigateCommonShareVC(with: docxUrl, fileType: .File)
                }
            } else {
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this file into Docx. Please try again.", doneButtonTitle: "OK")
            }
        
        case .PdF:
            if let pdfURL = convertToPDF(with: fileTextContent) {
                if TRFileManager.shared.isURLInDocumentDirectory(pdfURL) {
                    navigateCommonShareVC(with: pdfURL, fileType: .File)
                }
            } else {
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this file into PDF. Please try again.", doneButtonTitle: "OK")
            }
            
        case .Image:
            if let imageURL = convertToImage(name: fileTextContent) {
                if TRFileManager.shared.isURLInDocumentDirectory(imageURL) {
                    navigateCommonShareVC(with: imageURL, fileType: .Image)
                }
            } else {
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this file into Image. Please try again.", doneButtonTitle: "OK")
            }
        case .None:
            print("NONE")
        }
    }
    
    func navigateCommonShareVC(with url: URL, fileType: ShareSourceFileType) {
        let navigationController =  storyboard?.instantiateViewController(identifier: "CommonShareNavVC") as! UINavigationController
        navigationController.modalPresentationStyle = .fullScreen
        let shareVC = navigationController.viewControllers.first as! CommonShareVC
        shareVC.currentSourceFileType = fileType
        shareVC.fileURL = url
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setPickerDataSource(on sourceFileType: FileType) -> [FileType] {
        switch sourceFileType {
        case .Txt:
            return [.PdF, .Docx, .Image]
        default:
            return [.PdF, .Txt, .Image]
        }
    }
    
    
    func convertToPDF(with text: String)-> URL? {
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        pdf.addText(text)
        let pdfData = pdf.generatePDFdata()
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
            do {
                try pdfData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error writing to file: \(error)")
            }
        }
        return nil
    }
    
    func convertToDocx(with text: String)-> URL? {
        let finalString = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("docx")
            do {
                try finalString.writeDocX(to: fileURL)
                return fileURL
            } catch {
                print("Error writing to file: \(error)")
            }
        }
        return nil
    }
    
    func convertToImage(name: String?) -> URL? {
        let scale = 1.0
        let width = UIScreen.main.bounds.width * scale
        let height = UIScreen.main.bounds.height * scale
         let frame = CGRect(x: 0, y: 0, width: width, height: height)
         let nameLabel = UILabel(frame: frame)
         nameLabel.textAlignment = .center
         nameLabel.backgroundColor = .white
         nameLabel.textColor = .black
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.systemFont(ofSize: 12)
         nameLabel.text = name
         UIGraphicsBeginImageContext(frame.size)
          if let currentContext = UIGraphicsGetCurrentContext() {
             nameLabel.layer.render(in: currentContext)
              if let nameImage = UIGraphicsGetImageFromCurrentImageContext() {
                  return saveImageAsPNG(image: nameImage)
              }
          }
          return nil
    }
    
    func saveImageAsPNG(image: UIImage)-> URL? {
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let uniqueFileName = UUID().uuidString + ".png"
            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName)
            do {
                try image.pngData()?.write(to: fileURL)
                print("Image saved as \(fileURL.path)")
                return fileURL
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }

}

extension TextConvertVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        convertType = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row].rawValue
    }
}
