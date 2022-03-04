//
//  VideoItem.swift
//  AVPlayerDemo
//
//  Created by carry on 2022/2/28.
//

import Foundation

struct VideoItem {
    var imageUrl: String
    var videoUrl: String
    
    static func generate(videoUrl: String) -> Self {
        var imageUrl: String
        if videoUrl.contains("nintyinc.com") {
            imageUrl = imageList[0]
        } else {
            imageUrl = imageList[1]
        }
        let v = VideoItem(imageUrl: imageUrl, videoUrl: videoUrl)
        id += 1
        return v
    }
    
    static var id: Int = 0
    static let imageList = ["https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2F512%2F0PQ2123I9%2F120PQ23I9-10-1200.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648651145&t=386094106cabcc1da6d919d36bdea4da", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdesk-fd.zol-img.com.cn%2Ft_s960x600c5%2Fg5%2FM00%2F02%2F05%2FChMkJ1bKyaOIB1YfAAusnvE99Z8AALIQQPgER4AC6y2052.jpg&refer=http%3A%2F%2Fdesk-fd.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1648651145&t=6f3c9ff378e823b391461ff41705d9e3"]
    
}
