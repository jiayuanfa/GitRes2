//
//  ViewController.swift
//  DouBanFM
//
//  Created by JiaYuanFa on 16/8/5.
//  Copyright © 2016年 Jafar MacPro. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,HttpProtocol,ChannerDelegate {

    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var songProgressView: UIProgressView!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var channelButton: UIButton!
    
    var httpRequest:HttpRequsetHelper = HttpRequsetHelper()
    let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=1&from=mainsite"

    let channelUrl:String = "http://www.douban.com/j/app/radio/channels"
    
    var songData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    var imageCache = NSMutableDictionary()
    
    var audioPlayer = MPMoviePlayerController()
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 请求数据
        httpRequest.delegate = self
        httpRequest.onResearch(url)
        
        // 清除多余的FooterCell
        self.songListTableView.tableFooterView = UIView()
        
        // 获取频道数据 传递给下个界面
        httpRequest.onResearch(channelUrl)
    }
    
    // 跳转的时候设置代理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let channelVC = segue.destinationViewController as! ChannerlController
        channelVC.delegate = self
        channelVC.channelData = self.channelData
    }
    
    //MARK:选择频道之后Delegate
    func onChangeChannel(channelId: String) {
        let refreshUrl = "http://douban.fm/j/mine/playlist?type=n&\(channelId)&from=mainsite"
        httpRequest.onResearch(refreshUrl)
    }
    
    //MARK:数据结果回调
    func didReceiveResults(results: NSDictionary) {
            if results["song"] != nil{
                self.songData = results["song"] as! NSArray
                self.songListTableView.reloadData()
                
                let firstDict:NSDictionary = self.songData[0] as! NSDictionary
                let songUrl:String = firstDict["url"] as! String
                print("音乐地址为：\(songUrl)")
                self.onSetAudio(songUrl)
                let imageUlr:String = firstDict["picture"] as! String
                print("图片地址为：\(imageUlr)")
                self.onSetImage(imageUlr)
            }else if results["channels"] != nil{
                self.channelData = results["channels"] as! NSArray
            }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:"douban")
        let dataDictionary = songData[indexPath.row] as! NSDictionary
        cell.textLabel?.text = dataDictionary["title"] as? String
        cell.detailTextLabel?.text = dataDictionary["artist"] as? String
        // 从缓存中获取图片
        let pictureUrl = dataDictionary["picture"] as? String
        let image = self.imageCache[pictureUrl!] as! UIImage?
        if image == nil{
            let imageUrl:NSURL = NSURL(string: pictureUrl!)!
            let imageRequest = NSURLRequest(URL: imageUrl)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(imageRequest) { (data, urlResponse, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    let image = UIImage(data: data!)
                    // 将图片加入缓存
                    self.imageCache[pictureUrl!] = image
                    cell.imageView?.image = image
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            }
            task.resume()
        }else{
            cell.imageView?.image = image
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("选择了第：\(indexPath.row)行")
        let dataDic = self.songData[indexPath.row] as! NSDictionary
        let imageUrl = dataDic["picture"] as! String
        let songUrl = dataDic["url"] as! String
        onSetImage(imageUrl)
        onSetAudio(songUrl)
    }
    
    //MARK:Cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25) { 
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    //MARK:播放歌曲
    func onSetAudio(url:String){
        self.audioPlayer.pause()
        let URL = NSURL(string: url)
        self.audioPlayer.contentURL = URL
        self.audioPlayer.play()
        
        //MARK:计时器
//        timer?.invalidate()
            self.playTime?.text = "00:00"
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(self.updateSongDuration), userInfo: nil, repeats: true)
            self.timer!.fire()
    }
    
    deinit{
//        timer?.invalidate()
    }
    
    //MARK:刷新歌曲进度Label
    func updateSongDuration(){
        let currentTime = self.audioPlayer.currentPlaybackTime
        print("当前播放时间为:\(currentTime)")
        if currentTime > 0.0{
        }
    }
    
    //MARK:设置封面图
    func onSetImage(url:String){
        let cacheImage = self.imageCache[url] as? UIImage
        if cacheImage == nil{
            let imageURL:NSURL = NSURL(string: url)!
            let request:NSURLRequest = NSURLRequest(URL: imageURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request){(data,urlResponse,err)in
                dispatch_async(dispatch_get_main_queue(), {
                    let image = UIImage(data: data!)
                    // 加入缓存
                    self.imageCache[url] = image
                    self.songImageView.image = image
                })
            }
            task.resume()
        }else{
            self.songImageView.image = cacheImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

