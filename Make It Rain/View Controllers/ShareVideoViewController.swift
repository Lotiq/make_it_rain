
//
//  ShareVideoViewController.swift
//  Make It Rain
//
//  Created by Timothy on 6/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//
import Foundation
import UIKit
import AVKit
import Photos

class ShareVideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var IGbutton: CircularButton!
    @IBOutlet weak var saveButton: CircularButton!
    
    var videoURL: URL?
    var player: AVPlayer!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let image = UIImage(named: "download")?.tint(with: .gray)
        saveButton.setImage(image, for: .normal)
        IGbutton.isEnabled = false
        saveButton.isEnabled = false
        
    
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)

        view.backgroundColor = UIColor.theme.secondary
        videoView.backgroundColor = UIColor.theme.secondary
        navigationController?.navigationBar.barTintColor = UIColor.theme.main
        navigationController?.navigationBar.isTranslucent = false
        
        if videoURL != nil {
            IGbutton.isEnabled = true
            saveButton.isEnabled = true
            //playVideo(videoURL: videoURL)
        } else {
            print("error with video")
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if saveButton.isEnabled {
            playVideo(videoURL: videoURL!)
        }
    }
    
    func playVideo(videoURL: URL){
        self.player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        print("frame width:", self.videoView.frame.width)
        print("frame height:", self.videoView.frame.height)
        //set up player layer
        playerLayer.frame = CGRect(x: 0,y: 0,width: self.videoView.frame.width, height: self.videoView.frame.height)
        playerLayer.position = CGPoint(x: self.videoView.bounds.midX, y: self.videoView.bounds.midY)
        print("inner frame:", playerLayer.frame)
        //player styling
        playerLayer.shadowColor = UIColor.black.cgColor
        playerLayer.shadowOpacity = 0.3
        playerLayer.shadowOffset = CGSize(width: 0, height: 1)
        playerLayer.shadowRadius = -4
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player!.currentItem,
                                               queue: nil) { [weak self] note in
                                                self?.player!.seek(to: CMTime.zero)
                                                self?.player!.play()
        }
        
        self.videoView.layer.addSublayer(playerLayer)
        player!.volume = 1.0
        player!.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToBackgroundNotifications()
        player!.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToBackgroundNotifications()
    }
    
    
    @IBAction func shareToInstagram(_ sender: UIButton) {
        
        
        let videoData = try? Data(contentsOf: videoURL!)

        guard let urlScheme = URL(string: "instagram-stories://share") else{
            print("Failed")
            return
        }
        
        guard UIApplication.shared.canOpenURL(urlScheme) else {
            print("Permission Issues")
            return
        }
        
        let pasteboardItems = [["com.instagram.sharedSticker.backgroundVideo": videoData!]]
        let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)]
        
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
    }
    
    @IBAction func saveToCameraRoll(_ sender: UIButton) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL!)
        }) { (saved, error) in
            if (error == nil) {
                let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
                
                vc.bodyText = "Your amazing video was saved"
                vc.titleText = "Yay!"
                vc.buttonText = "Good"
                vc.completion = {
                    DispatchQueue.main.async {
                        self.player.play()
                    }
                }
                DispatchQueue.main.async {
                    self.player.pause()
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func resumeVideo(){
        player.play()
    }
    
    @objc func pauseVideo(){
        player.pause()
    }
    
}

extension ShareVideoViewController {
    
    // MARK: Background Notifications
    
    func subscribeToBackgroundNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(resumeVideo), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideo), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func unsubscribeToBackgroundNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}
