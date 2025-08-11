//
//  SolutionVC.swift
//  CodeConvert
//
//  Created by Tushar Khandaker on 9/9/23.
//

import UIKit
import MobileCoreServices

protocol SolutionVCDelegate: AnyObject {
    func resetTextView()
}
class SolutionVC: UIViewController {

    @IBOutlet weak var solutionPageControl: UIPageControl!
    @IBOutlet weak var solutionCollectionView: UICollectionView!

    var solutionList = [String]()
    
    weak var delegate: SolutionVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        solutionPageControl.currentPage = 0
        solutionPageControl.numberOfPages = solutionList.count
    }
    
    @IBAction func copySolution(_ sender: UIButton) {
        UIPasteboard.general.string = solutionList[solutionPageControl.currentPage]
        self.view.showToast(message: "Copied", duration: 3)
    }
    
    @IBAction func saveAsTextFile(_ sender: UIButton) {
        if let url = TRFileManager.shared.saveText(solutionList[solutionPageControl.currentPage], toFilename: UUID().uuidString) {
            shareTextFile(withURL: url, from: self)
        }
    }
    
    @IBAction func changePage(_ sender: UIPageControl) {
        solutionCollectionView.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func dismissSolutionVC(_ sender: UIBarButtonItem) {
        delegate?.resetTextView()
        self.dismiss(animated: true)
    }
        
    func shareTextFile(withURL fileURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    //    func saveAndShare(string: String, filename: String = UUID().uuidString) {
    //        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename) else { return }
    //        do {
    //            try string.write(to: fileURL, atomically: true, encoding: .utf8)
    //            documentInteractionController.url = fileURL
    //            documentInteractionController.uti = "public.plain-text"
    //            documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
    //        } catch {
    //            print("Error saving file:", error.localizedDescription)
    //        }
    //    }
}

extension SolutionVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return solutionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SolutionCollectionViewCell", for: indexPath) as! SolutionCollectionViewCell
        cell.textView.text = solutionList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        solutionPageControl.currentPage = indexPath.row

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
