//
//  ViewController.swift
//  AvDemo
//
//  Created by CSS on 21/09/18.
//  Copyright © 2018 css. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import CoreData
import Photos

class ViewController: UIViewController {

    @IBOutlet var audioTableView: UITableView!
    
    @IBOutlet var progressBar: UIProgressView!
    
    
    var entity : NSEntityDescription!
    var newData : NSManagedObject!
    //var context : NSManagedObjectContext!
    
    var videocalss = [Videos]()
    
    var videoObj : Videos?
    
    var context:NSManagedObjectContext = {
        return AppDelegate.shared.persistentContainer.viewContext
    }()
 //   let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // context = appdelegate.persistentContainer.viewContext
        self.progressBar.progress = 0.0
        
        downloadVideoLinkAndCreateAsset("https://www.ebookfrenzy.com/ios_book/movie/movie.mov")
       //createEntity()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func createEntity(){
        entity = NSEntityDescription.entity(forEntityName: "Videos", in: context)
        newData = NSManagedObject(entity: entity, insertInto: context)
    }
    
    func fetchvalue(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Videos")
        request.returnsObjectsAsFaults = false
        do {
            let resultdata = try context.fetch(request)
            print("coredata response : \(resultdata)")
        }catch {
            
        }
    }
    
    
    
    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        do {
//           try FileManager.default.removeItem(at: documentsDirectoryURL)
//        }catch {
//
//        }
        
        
        // check if the file already exist at the destination folder if you don't want to download it twice
      //  if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                    } else {
                                        print(error)
                                      
                                      
                                        
                                    }
                            }
                        }
                    })
                    
                } catch {
                    print(error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        let player = AVPlayer(url: location)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        self.present(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }
                    })
                }
                
                }.resume()
            
//        } else {
//            print("File already exists at destination url")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                let videoURL = URL(string: videoLink) //https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
//                let player = AVPlayer(url: videoURL!)
//                let playerViewController = AVPlayerViewController()
//                playerViewController.player = player
//                self.present(playerViewController, animated: true) {
//                    playerViewController.player!.play()
//                }
//            }
//
//        }
        
    }
    
    
    
    
    
    
    
    func downloadImage() {
    
        Alamofire.request("https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4").downloadProgress(closure: { (progress) in
            print(progress.fractionCompleted)
            
            
            self.progressBar.progress = Float(progress.fractionCompleted)
            
        }).responseData { (response) in
            print(response.result)
            print(response.result.value)
            
            if let data = response.result.value {
                
                if self.videoObj == nil {
                    
                    self.videoObj = NSEntityDescription.insertNewObject(forEntityName: "Videos", into: self.context) as? Videos
                    self.videoObj?.url = data as NSData
                }
               self.save()
                
                self.getValue()
               // self.imgView.image = UIImage(data: data)
            }
            
            
            
        }
        
        
        
    }
    
    func save(){
        do {
            try self.context.save()
        }catch{
            print("failed")
        }
    }
    
    func getValue(){
        let fetchVideoValue = Videos.fetch()
        fetchVideoValue.returnsObjectsAsFaults = false
        
        do {
            self.videocalss = try context.fetch(fetchVideoValue)
            
            print("final value: \(videocalss.first?.url)")
        }catch{
            
        }
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

        downloadImage()
    }
    
    
    
}



class AudioCell: UITableViewCell {
    
    @IBOutlet var progressBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
