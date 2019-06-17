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

class ShareVideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var IGButton: CircularButton!
    @IBOutlet weak var saveButton: CircularButton!
    
    var videoURL: URL?
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IGButton.isEnabled = false
        saveButton.isEnabled = false
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)

        view.backgroundColor = UIColor.theme.secondary
        videoView.backgroundColor = UIColor.theme.secondary
        navigationController?.navigationBar.barTintColor = UIColor.theme.main
        navigationController?.navigationBar.isTranslucent = false
        
        if let videoURL = videoURL {
            IGButton.isEnabled = true
            saveButton.isEnabled = true
            playVideo(videoURL: videoURL)
        } else {
            print("error with video")
        }
        
    }
    
    func playVideo(videoURL: URL){
        self.player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        
        //set up player layer
        playerLayer.frame = CGRect(x: 0,y: 0,width: self.videoView.frame.width, height: self.videoView.frame.height)
        playerLayer.position = CGPoint(x: self.videoView.bounds.midX, y: self.videoView.bounds.midY)
        
        //player styling
        playerLayer.shadowColor = UIColor.black.cgColor
        playerLayer.shadowOpacity = 0.3
        playerLayer.shadowOffset = CGSize(width: 0, height: 1)
        playerLayer.shadowRadius = -4
        
        /*
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player!.currentItem,
                                               queue: nil) { [weak self] note in
                                                self?.player!.seek(to: CMTime.zero)
                                                self?.player!.play()
        }*/
        
        self.videoView.layer.addSublayer(playerLayer)
        player!.volume = 1.0
        player!.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
    }
    
    @IBAction func shareToInstagram(_ sender: UIButton) {
       
    }
    
    @IBAction func saveToCameraRoll(_ sender: UIButton) {
        
    }
}
