
import UIKit
import WebKit
import AVKit
import AVFoundation
import Photos

enum ShareSourceFileType {
    case File
    case Image
    case Video
}


class CommonShareVC: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var saveShareStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var fileURL: URL?
    var currentSourceFileType = ShareSourceFileType.File 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let fileURL = fileURL {
            showAndHideView(with: fileURL)
            if currentSourceFileType == .Video {
                imageView.image = TRFileManager.shared.generateThumbnail(path: fileURL)
            }
        } else {
           //ARELT
        }
    }
    
    func showAndHideView(with url: URL) {
        switch currentSourceFileType {
        case .File:
            webView.isHidden = false
            shareButton.isHidden = false
            imageView.isHidden = true
            videoPlayButton.isHidden = true
            saveShareStackView.isHidden = true
            let request = URLRequest(url: url)
                       webView.navigationDelegate = self // Set delegate if needed
                       webView.load(request)
        case .Image:
            imageView.isHidden = false
            webView.isHidden = true
            videoPlayButton.isHidden = true
            shareButton.isHidden = true
            saveShareStackView.isHidden = false
            imageView.image = UIImage(contentsOfFile: url.path)
        case .Video:
            videoPlayButton.isHidden = false
            webView.isHidden = true
            imageView.isHidden = false
            shareButton.isHidden = true
            saveShareStackView.isHidden = false
        }
    }
    
    @IBAction func closeVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveToPhotos(_ sender: UIButton) {
        
        if currentSourceFileType == .Image {
            guard let data = try? Data(contentsOf: fileURL!), let image = UIImage(data: data) else {
                print("Failed to fetch image from URL")
                return
            }
            savePhotoFromURL(fileURL, and: image)
        }
        
        if currentSourceFileType == .Video {
            savePhotoFromURL(fileURL, and: nil)
        }
    }
    
    @IBAction func shareFile(_ sender: UIButton) {
        if let fileURL = fileURL {
            shareTextFile(withURL: fileURL, from: self)
        }
    }
    
    @IBAction func shareImageAndVideo(_ sender: UIButton) {
        if let fileURL = fileURL {
            shareTextFile(withURL: fileURL, from: self)
        }
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        
        guard let videoURL = fileURL else {
            return
        }
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

    }
    
    func shareTextFile(withURL fileURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
    }

}


extension CommonShareVC {
    
    func savePhotoFromURL(_ fileURl: URL?, and image: UIImage?) {
        
        guard let url = fileURl else { return }
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            if currentSourceFileType == .Image {
                if let img = image {
                    UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
            if currentSourceFileType == .Video {
                saveVideo(with: url)
            }
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [self] (newStatus) in
                if newStatus == .authorized {
                    if let img = image {
                        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
            
        case .restricted, .denied:
            showPhotosDeinedAlert()
        case .limited:
            // Handle iOS 14's limited photo access scenario if necessary.
            // For simplicity in this example, we'll treat it the same way as .authorized.
            if currentSourceFileType == .Image {
                if let img = image {
                    UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
            if currentSourceFileType == .Video {
                saveVideo(with: url)
            }
        @unknown default:
            break
        }
    }

    func showPhotosDeinedAlert() -> Void {
        DispatchQueue.main.async {
            TRAlertController.showAlert(title: "Photos Access Denied", message: "This app requires access to your device's photos.\nPlease enable Photo Library access for this app in Settings.", isCancel: true, okButtonTitle: "Settings", cancelButtonTitle: "Cancel") { [weak self] isSetting in
                guard let self = self else { return }
                if isSetting{
                    self.goToSettings()
                }
                else{
                    return
                }
            }
        }
    }

    func goToSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            DispatchQueue.main.async {
                TRAlertController.showSimpleAlert(title: "Failed", message: "Failed to save image into Photos. Please try again.", doneButtonTitle: "OK")
            }
            print("ERROR: \(error)")
        }
        else {
            DispatchQueue.main.async {
                TRAlertController.showSimpleAlert(title: "Saved", message: "Image successfully saved to Photos", doneButtonTitle: "Done") }
            print("PHOTO SAVED")
        }
    }
    
    func saveVideo(with url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (success, error) in
            if let error = error {
                DispatchQueue.main.async {
                    TRAlertController.showSimpleAlert(title: "Failed", message: "Failed to save video into Photos. Please try again.", doneButtonTitle: "OK")

                }
            } else {
                DispatchQueue.main.async {
                    TRAlertController.showSimpleAlert(title: "Saved", message: "Video successfully saved to Photos", doneButtonTitle: "Done")
                    
                }
                print("Video saved successfully!")
            }
        }
    }

}
