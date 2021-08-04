//
//  File.swift
//  
//
//  Created by David Casserly on 27/07/2021.
//

import Foundation
import UIKit
import AVFoundation

public class VideoViewController: UIViewController {
    
    var isDebugMode = false
    
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var paused: Bool = false
    private let videoURL: URL
    
    // MARK: Init
    
    public init?(coder: NSCoder, videoURL: URL) {
        self.videoURL = videoURL
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,
                                                         mode: AVAudioSession.Mode.moviePlayback,
                                                         options: AVAudioSession.CategoryOptions.mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        // Don't show video on simulator or in debug mode
        if !isDebugMode {
            #if !targetEnvironment(simulator)
                createBackgroundVideo()
            #endif
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeVideo()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        pauseVideo()
        super.viewDidDisappear(animated)
    }
    
    // MARK: Video
    
    private func resumeVideo() {
        avPlayer?.play()
        paused = false
    }
    
    private func pauseVideo() {
        avPlayer?.pause()
        paused = true
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler:  nil)
    }
        
    fileprivate func createBackgroundVideo() {
        let avPlayer = AVPlayer(url: videoURL)
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        self.avPlayer = avPlayer
        self.avPlayerLayer = avPlayerLayer
    }
    
}
