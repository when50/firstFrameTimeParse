//
//  ViewController.swift
//  AVPlayerDemo
//
//  Created by carry on 2022/2/28.
//

import UIKit

class ViewController: UITableViewController {
    var videoUrlList = [
        "http://sv.nintyinc.com/rendition-normal/short_video/100020005970743057607482426777/index.m3u8?acode=20&aid=2_5733639&auid=1993a90c325b543da2095e330815a1f12aaaa2e8&city=CN_1_5_1&citycode=CN_1_5_1&code=100020005970743057607482426777&ip=106.120.244.138&k=79bd3d288653d038&ldid=5b131b27431b965d9b40c003f3b86e9e&m3v=1&peid=FDDDCA99-6E5D-4350-954D-974DF955CA16_0&pk=e48153495391b62e&platform=Le123Plat201&porder=1&reqtype=play&t=1646198942&version=2.9.5&vid=&videoId=(null)&vt=0&x=2e1484b504ee9cf4dfa2a5576f90e38ce18afb7f665a8bf8e548ac63c96a1232&y=068116f2b904f759515246ed648f2d5c",
        "http://sv.nintyinc.com/rendition-normal/short_video/100020005953146219008318554501/index.m3u8?acode=20&aid=2_5733559&auid=1993a90c325b543da2095e330815a1f12aaaa2e8&city=CN_1_5_1&citycode=CN_1_5_1&code=100020005953146219008318554501&ip=106.120.244.138&k=4e9ba55b68255f83&ldid=5b131b27431b965d9b40c003f3b86e9e&m3v=1&peid=480F2387-846A-40C7-8D74-87B321E9889D_0&pk=55c448d170536d70&platform=Le123Plat201&porder=1&reqtype=play&t=1646198932&version=2.9.5&vid=&videoId=(null)&vt=0&x=3691adb6aa1164faddc0f20462c4f0d253d20ceeccfb9dfd311837900ee57756&y=dc702b1d2c86445901fbb9387a320248",
        "http://sv.nintyinc.com/rendition-normal/short_video/100020046199194269892923390134/index.m3u8?acode=20&aid=2_5706646&auid=1993a90c325b543da2095e330815a1f12aaaa2e8&city=CN_1_5_1&citycode=CN_1_5_1&code=100020046199194269892923390134&ip=106.120.244.138&k=28b238d71c2266cd&ldid=5b131b27431b965d9b40c003f3b86e9e&m3v=1&peid=8300FC9B-3BAE-455B-81BB-894DB29AB85B_0&pk=4ad4b278f7ef08d6&platform=Le123Plat201&porder=1&reqtype=play&t=1646198952&version=2.9.5&vid=&videoId=(null)&vt=0&x=1039a13aa1441dbf18fec87a695fc7fe22741a66d7a788607d23aa0fc09de5db&y=867787aa6dabc8b57b115b6db35ee828",
        "http://sv.nintyinc.com/rendition-normal/short_video/100020005952941475282449083161/index.m3u8?acode=20&aid=2_5733522&auid=1993a90c325b543da2095e330815a1f12aaaa2e8&city=CN_1_5_1&citycode=CN_1_5_1&code=100020005952941475282449083161&ip=106.120.244.138&k=806aa3bdc2fc94fa&ldid=5b131b27431b965d9b40c003f3b86e9e&m3v=1&peid=0913DEE8-097C-4D03-B461-0822AC3CA7F8_0&pk=c0c4d6f5729776cf&platform=Le123Plat201&porder=1&reqtype=play&t=1646198960&version=2.9.5&vid=&videoId=(null)&vt=0&x=d2dd38dc140a5b2fcb2d17f234241fb744323a3c6cc58f843e4e4038bffa14f1&y=6231161f4be8f844e790f0c35633d336",
        "http://sv.nintyinc.com/rendition-normal/short_video/100020005952939726799378345805/index.m3u8?acode=20&aid=2_5733533&auid=1993a90c325b543da2095e330815a1f12aaaa2e8&city=CN_1_5_1&citycode=CN_1_5_1&code=100020005952939726799378345805&ip=106.120.244.138&k=0aad5cfac9aee91a&ldid=5b131b27431b965d9b40c003f3b86e9e&m3v=1&peid=67EB924A-2BF3-4568-AF1A-E5E652A5CB6B_0&pk=6fd27ff96712b2f7&platform=Le123Plat201&porder=1&reqtype=play&t=1646198965&version=2.9.5&vid=&videoId=(null)&vt=0&x=7ef196319392d1a1eb5311fa783e1649e6b128f92fb02627e4368978ddd5df84&y=ce51e0a406d66cf57b96e03b930925a6",
        // tou tiao
        "http://v3-chf.toutiaovod.com/7df7070553afe4c90122751381b08886/621f4c55/video/tos/cn/tos-cn-ve-4-alinc2/7fe854b825b7474b9f19a004bba68c2d/?a=13&br=654&bt=654&cd=0%7C0%7C0%7C0&ch=3431225546&cr=0&cs=0&cv=1&dr=0&ds=2&er=0&ft=FIkF_p~0071FOvWHhWH6xgGiLsCB~OVjWqrop&l=202203021749340101511740782503324C&lr=unwatermarked&mime_type=video_mp4&net=0&pl=0&qs=0&rc=amVnOWc6ZjRrOzMzNDczM0ApOTk1NjdoM2U4Nzs7OWZlPGcpaGZzcmd5d3JseHdmM2JjYnI0MGdjYC0tZC0vc3NfMzMxMzAyL2MzMzY2Y2E0OmNvaF4rYmZxK15xbDo%3D&vl=&vr=",
        "http://v3-chf.toutiaovod.com/03950143571c1789731f1c69a23cf40b/621f4c73/video/tos/cn/tos-cn-ve-4-alinc2/802bd73527d04192bb30a4a732e9c757/?a=13&br=687&bt=687&cd=0%7C0%7C0%7C0&ch=3431225546&cr=0&cs=0&cv=1&dr=0&ds=2&er=0&ft=FIkF_p~0071FOvWHhWH6xgGiLsCB~OVjWqrop&l=202203021749340101511740782503324C&lr=unwatermarked&mime_type=video_mp4&net=0&pl=0&qs=0&rc=ampwaDM6ZnNoOzMzNDczM0ApMzw3OzszNDtoN2ZpODdkN2cpaGZzcmd5d3JseHdmazNzZXI0ZzRjYC0tZC0vc3NjMTQ2Ly1jLS02Li4wMF4tOmNvaF4rYmZxK15xbDo%3D&vl=&vr=",
        "http://v3-chf.toutiaovod.com/4fc6533cd57cbe616d405e157ac81770/621f4c72/video/tos/cn/tos-cn-ve-4-alinc2/772aaec57a8d44549f71d379c5ca5f2b/?a=13&br=390&bt=390&cd=0%7C0%7C0%7C0&ch=3431225546&cr=0&cs=0&cv=1&dr=0&ds=2&er=0&ft=FIkF_p~0071FOvWHhWH6xgGiLsCB~OVjWqrop&l=202203021749340101511740782503324C&lr=unwatermarked&mime_type=video_mp4&net=0&pl=0&qs=0&rc=anR2N2Q6ZmdlOzMzNDczM0ApZ2dpOjhkPDtpNzgzNDM6ZWcpaGZzcmd5d3JseHdmLl5qZnI0MG81YC0tZC0vc3MtYjBeXl82LzEuLmJgMTMvOmNvaF4rYmZxK15xbDo%3D&vl=&vr=",
        "http://v3-chf.toutiaovod.com/7f18e3d735089a758a2e8664a77ab23e/621f4c8a/video/tos/cn/tos-cn-ve-4-alinc2/9fcbc83a35994fc6ac5ebeaa4e22a45b/?a=13&br=295&bt=295&cd=0%7C0%7C0%7C0&ch=3431225546&cr=0&cs=0&cv=1&dr=0&ds=2&er=0&ft=FIkF_p~0071FOvWHhWH6xgGiLsCB~OVjWqrop&l=202203021749340101511740782503324C&lr=unwatermarked&mime_type=video_mp4&net=0&pl=0&qs=0&rc=Mzk6amg6ZjU8OzMzNDczM0ApOWk2N2Q5PDtlNzY5NGU0M2cpaGZzcmd5d3JseHdmcGptNHI0b2dgYC0tZC0vc3NfMWEtMTY1YzViYl8zMDJjOmNvaF4rYmZxK15xbDo%3D&vl=&vr=",
        "http://v3-chf.toutiaovod.com/1979232cdad07ff54a4ae32b1b9b5f70/621f4ca3/video/tos/cn/tos-cn-ve-4-alinc2/9f884030319d4add9144fbadf2523fcf/?a=13&br=378&bt=378&cd=0%7C0%7C0%7C0&ch=3431225546&cr=0&cs=0&cv=1&dr=0&ds=1&er=0&ft=FIkF_p~0071FOvWHhWH6xgGiLsCB~OVjWqrop&l=202203021749340101511740782503324C&lr=unwatermarked&mime_type=video_mp4&net=0&pl=0&qs=0&rc=M2VrdGc6ZnByOzMzNDczM0ApaWloNzw3PDwzN2RoZTc4NWcpaGZzcmd5d3JseHdmam0xYXI0b3NhYC0tZC0vc3MxY2AtNDMwMS5gYi8wMV4uOmNvaF4rYmZxK15xbDo%3D&vl=&vr=",
    ]
    var videoList: [VideoItem] {
        get {
            return videoUrlList.map { url in
                let finalUrl = shouldUseP2P ? BZXCDEService.getAccelerateURL(url, offset: 0) : url
                return VideoItem.generate(videoUrl: finalUrl)
            }
        }
    }
    var shouldUseP2P = false {
        didSet {
            p2pButton.title = shouldUseP2P ? "stopP2P" : "startP2P"
            playingCell?.stop()
            playingCell = nil
            playingItem = -1
            if oldValue && playingItem >= 0 {
                BZXCDEService.stopPlay(videoList[playingItem].videoUrl)
            }
            self.tableView.reloadData()
        }
    }
    var playingCell: VideoCell?
    var playingItem = -1
    @IBOutlet weak var p2pButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        p2pButton.isEnabled = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell")
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell {
            cell.item = videoList[indexPath.item]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = playingCell {
            cell.stop()
            playingCell = nil
        }
        
        if indexPath.item == playingItem {
            playingItem = -1
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? VideoCell {
            LOG("start play")
            cell.play()
            playingCell = cell
            playingItem = indexPath.item
        }
    }
    
    @IBAction func addVideo(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "添加视频", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "视频地址"
        }
        
        let add = UIAlertAction(title: "确定", style: .default) { action in
            if let url = alert.textFields?.first?.text {
                self.videoUrlList.insert(url, at: 0)
                self.tableView.reloadData()
            }
        }
        alert.addAction(add)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func p2pAction(_ sender: UIBarButtonItem) {
        shouldUseP2P = !shouldUseP2P
    }
}

