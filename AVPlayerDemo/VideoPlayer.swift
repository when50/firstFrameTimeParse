//
//  VideoPlayer.swift
//  AVPlayerDemo
//
//  Created by oneko on 2022/3/1.
//

import AVFoundation
import UIKit

class VideoPlayer {
    var player: IJKFFMoviePlayerController?
    
    init(videoUrl: String) {
        let options = IJKFFOptions.byDefault()
        self.player = IJKFFMoviePlayerController(contentURLString: videoUrl, with: options)
        self.player?.prepareToPlay()
    }
    
    func play() {
        self.player?.play()
    }
    
    func stop() {
        self.player?.view.removeFromSuperview()
        
        self.player?.stop()
        
        self.player = nil
    }
}
