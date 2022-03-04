//
//  VideoView.swift
//  AVPlayerDemo
//
//  Created by oneko on 2022/3/1.
//

import AVFoundation
import UIKit

class VideoView: UIView {
    weak var player: VideoPlayer?
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    func setup(player: VideoPlayer?) {
        self.backgroundColor = UIColor.black
        self.player = player
        if let v = player?.player?.view {
            v.frame = bounds
            addSubview(v)
        }
    }
}
