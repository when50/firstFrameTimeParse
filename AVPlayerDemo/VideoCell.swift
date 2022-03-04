//
//  VideoCell.swift
//  AVPlayerDemo
//
//  Created by carry on 2022/2/28.
//

import UIKit
import Kingfisher
import AVFoundation

class VideoCell: UITableViewCell {
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var iconLoadingImageView: UIImageView!
    @IBOutlet weak var iconPlayImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    var firstFrameRenderedObserver: NTYNotificationObserver?
    var player: VideoPlayer?
    var item: VideoItem? {
        didSet {
            reset()
            selectionStyle = .none
            if let item = item {
                coverImageView.kf.setImage(with: ImageResource(downloadURL: URL(string: item.imageUrl)!))
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override var isSelected: Bool {
        didSet {
            self.selectedBackgroundView?.isHidden = true
        }
    }
    
    func play() {
        guard let videoUrl = item?.videoUrl else {
            print("video url is nil")
            return
        }
        player = VideoPlayer(videoUrl: videoUrl)
        player?.play()
        playing()
        
        addObservers()
    }
    
    private func addObservers() {
        firstFrameRenderedObserver = NTYNotificationObserver.observe(.IJKMPMoviePlayerFirstVideoFrameRendered, from: nil) { notif in
            if let _ = self.player {
                self.hideLoading()
            }
        }
        if let layer = videoView.layer as? AVPlayerLayer {
            layer.addObserver(self, forKeyPath: "readyForDisplay", options: .initial.union(.new), context: nil)
        }
    }
    
    private func removeObservers() {
        if let layer = videoView.layer as? AVPlayerLayer {
            layer.removeObserver(self, forKeyPath: "readyForDisplay")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let layer = object as? AVPlayerLayer else { return }
        
        if (keyPath == "readyForDisplay") {
            if layer.isReadyForDisplay {
                self.hideLoading()
            }
        }
    }
    
    func stop() {
        
        removeObservers()
        player?.stop()
        player = nil
        
        videoView.setup(player: nil)
        
        reset()
    }
    
    private func playing() {
        self.iconPlayImageView.isHidden = true
        self.iconLoadingImageView.isHidden = true
        self.videoView.isHidden = false
        self.videoView.setup(player: player)
    }
    
    private func reset() {
        self.iconLoadingImageView.isHidden = true
        self.videoView.isHidden = true
        self.iconPlayImageView.isHidden = false
        self.coverImageView.isHidden = false
    }
    
    private func showLoading() {
        self.iconLoadingImageView.isHidden = false
    }
    
    private func hideLoading() {
        self.iconLoadingImageView.isHidden = true
        self.coverImageView.isHidden = true
    }
}
