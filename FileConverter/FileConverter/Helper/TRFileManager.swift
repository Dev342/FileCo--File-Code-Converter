//
//  TRFileManager.swift
//  CodeConvert
//
//  Created by Tushar Khandaker on 11/9/23.
//

import Foundation
import UIKit
import AVFoundation

class TRFileManager {
    
    static let shared = TRFileManager()
    
    func readFileData(from fileURL: URL)-> String? {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            return fileContent
            
        } catch {
            print("Error reading file: \(error)")
        }
        return nil
    }

    
    func saveText(_ text: String, toFilename filename: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(filename).appendingPathExtension("txt")
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
            } catch {
                print("Error writing to file: \(error)")
            }
        }
        return nil
    }
    
    func isURLInDocumentDirectory(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        let documentDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let targetURL = documentDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        return fileManager.fileExists(atPath: targetURL.path)
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }


    
}
