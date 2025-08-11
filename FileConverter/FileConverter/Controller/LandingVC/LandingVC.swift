
import UIKit
import MobileCoreServices
import AVFoundation
import UniformTypeIdentifiers

enum OpenFileType {
    case ForCode
    case ForTxt
    case ForDocx
    case ForImage
    case ForVideo
}

class LandingVC: UIViewController, UINavigationControllerDelegate {
    
    var fileURl: URL? {
        didSet {
            guard let fileURl = fileURl else  { return }
            
            switch readyToOpenFileType {
                
            case .ForCode:
                performSegue(withIdentifier: "RequestVC", sender: self)
                
            case .ForTxt:
                if let fileText = TRFileManager.shared.readFileData(from: fileURl) {
                    self.fileText = fileText
                    performSegue(withIdentifier: "TextConvertVC", sender: self)
                } else {
                    TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to read data from your selected file. Please try again.", doneButtonTitle: "OK")
                }
                
            case .ForDocx:
                if let textFromDocx = SNDocx.shared.getText(fileUrl: fileURl) {
                    if !textFromDocx.isEmpty {
                        self.fileText = textFromDocx
                        performSegue(withIdentifier: "openWithDocx", sender: self)
                    } else {
                        TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to read data from your selected file. Please try again.", doneButtonTitle: "OK")
                    }
                } else {
                    TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to read data from your selected file. Please try again.", doneButtonTitle: "OK")
                }
                
            case .ForImage:
                DispatchQueue.main.async {
                    self.navigateSolutionVC(with: fileURl, fileType: self.imageToPDF ? .File : .Image)
                }
                
            case .ForVideo:
                DispatchQueue.main.async {
                    self.navigateSolutionVC(with: fileURl, fileType: .Video)
                }
            }
            readyToOpenFileType = .ForCode
        }
    }
    var selectedVideoURL: URL? {
        didSet {
            guard let videoURL = selectedVideoURL else {
                return
            }
            TRAlertController.showAlertWithThreeButton(title: "Convert Video", message: "Which type do you want to convert?", button1Title: "MP4", button2Title: "MOV") { [weak self] isMP4 in
                guard let self = self else { return }
                guard let mp4 = isMP4 else { return }
                DispatchQueue.main.async {
                    self.displayAnimatedActivityIndicatorView()
                }
                if mp4 {
                    self.convertVideoToMP4(videoURL: videoURL)
                } else {
                    self.convertVideoToMOV(videoURL: videoURL)
                }
            }
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            
            guard let image = selectedImage else { return }
            TRAlertController.showAlertWithFourButton(title: "Convert Image", message: "Which type do you want to convert?", button1Title: "JPG", button2Title: "PNG", button3Title: "PDF") { [weak self] convertType in
                guard let self = self else { return }
                var convertedURL:URL? = nil
                switch convertType {
                case .JPG:
                    convertedURL = self.saveImageAsJPG(image: image)
                case .PNG:
                    convertedURL = self.saveImageAsPNG(image: image)
                case .PDf:
                    imageToPDF = true
                    convertedURL = self.convertToPDF(with: image)
                case .Cancel:
                    return
                }
                if let url = convertedURL {
                    self.fileURl = url
                } else {
                    TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this image. Please try again.", doneButtonTitle: "OK")
                }
            }
        }
    }
    
    var imageToPDF = false
    var fileText = ""
    var readyToOpenFileType = OpenFileType.ForCode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RequestVC" {
            let requestVC = segue.destination as! RequestVC
            requestVC.fileURl = fileURl
        }
        
        if segue.identifier == "TextConvertVC" {
            let textVC = segue.destination as! TextConvertVC
            textVC.sourceFileType = .Txt
            textVC.fileTextContent = self.fileText
            
        }
        
        if segue.identifier == "openWithDocx" {
            let textVC = segue.destination as! TextConvertVC
            textVC.sourceFileType = .Docx
            textVC.fileTextContent = self.fileText
        }
    }
    
    @IBAction func convertCodeFile(_ sender: UIButton) {
        readyToOpenFileType = .ForCode
        pickTextFile()
    }
    
    @IBAction func convertTextFile(_ sender: UIButton) {
        readyToOpenFileType = .ForTxt
        pickTextFile()
    }
    
    @IBAction func convertDocxFile(_ sender: UIButton) {
        readyToOpenFileType = .ForDocx
        pickDocxFile()
    }
    
    @IBAction func convertImage(_ sender: UIButton) {
        readyToOpenFileType = .ForImage
        imageToPDF = false
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func convertVideo(_ sender: UIButton) {
        readyToOpenFileType = .ForVideo
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func pickTextFile() {
        let supportedTypes: [UTType] = [UTType.text]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    func pickDocxFile() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.docx","org.openxmlformats.wordprocessingml.document", kUTTypePDF as String], in: UIDocumentPickerMode.import)
        importMenu.delegate = self
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func navigateSolutionVC(with url: URL, fileType: ShareSourceFileType) {
        let navigationController =  storyboard?.instantiateViewController(identifier: "CommonShareNavVC") as! UINavigationController
        navigationController.modalPresentationStyle = .fullScreen
        let solutionVC = navigationController.viewControllers.first as! CommonShareVC
        solutionVC.fileURL = url
        solutionVC.currentSourceFileType = fileType
        self.present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - UIDocumentPickerDelegate
extension LandingVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.fileURl = urls[0]
    }
}

//MARK: - UIImagePickerControllerDelegate
extension LandingVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if readyToOpenFileType == .ForVideo {
            
            guard let videoURL = info[.mediaURL] as? URL else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            self.selectedVideoURL = videoURL
        }
        
        if readyToOpenFileType == .ForImage {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.selectedImage = pickedImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Image Convert
extension LandingVC {
    
    func convertToPDF(with image: UIImage)-> URL? {
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        pdf.addImage(image)
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
    
    func saveImageAsJPG(image: UIImage)-> URL? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let uniqueFileName = UUID().uuidString + ".jpg"
            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName)

            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    print("Image saved as \(fileURL.path)")
                    return fileURL
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        return nil
    }
}

//MARK: - Video Convert
extension LandingVC {
    
    func convertVideoToMP4(videoURL: URL) {
        
        let asset = AVURLAsset(url: videoURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            DispatchQueue.main.async {
                self.hideAnimatedActivityIndicatorView()
            }
            print("Could not create export session")
            return
        }
        
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(UUID().uuidString ).mp4")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                print("Video conversion to MP4 completed")
                DispatchQueue.main.async {
                    self.hideAnimatedActivityIndicatorView()
                }
                self.fileURl = outputURL
            } else if exportSession.status == .failed {
                DispatchQueue.main.async {
                    self.hideAnimatedActivityIndicatorView()
                }
                print("Video conversion to MP4 failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this video. Please Try again", doneButtonTitle: "OK")
            }
        }
    }

    func convertVideoToMOV(videoURL: URL) {
        
        let asset = AVURLAsset(url: videoURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            DispatchQueue.main.async {
                self.hideAnimatedActivityIndicatorView()
            }
            print("Could not create export session")
            return
        }
        
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(UUID().uuidString ).mov")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                print("Video conversion to MOV completed")
                // Handle the converted video at outputURL
                DispatchQueue.main.async {
                    self.hideAnimatedActivityIndicatorView()
                }
                self.fileURl = outputURL
                
            } else if exportSession.status == .failed {
                DispatchQueue.main.async {
                    self.hideAnimatedActivityIndicatorView()
                }
                print("Video conversion to MOV failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                TRAlertController.showSimpleAlert(title: "Error !", message: "Failed to convert this video. Please Try again", doneButtonTitle: "OK")
            }
        }
    }
}
