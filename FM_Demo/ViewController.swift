//
//  ViewController.swift
//  FM_Demo
//
//  Created by Josie on 16/9/10.
//  Copyright © 2016年 Josie. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer

// https://www.douban.com/j/app/radio/channels
// https://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol, ChannelProtocol {

    
    

    
    @IBOutlet weak var background: UIImageView! // 大背景
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPlay: CustomButton!
    @IBOutlet weak var btnPre: UIButton!
    @IBOutlet weak var cdImage: MyImage!        // 音乐封面
    @IBOutlet weak var musicTable: UITableView! // 歌曲列表
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    var audioPlayer: MPMoviePlayerController = MPMoviePlayerController()//媒体播放器的实例
    var channelData_Arr: [JSON] = []
    var currentIndex: Int = 0 // 记录当前在播放第几首
    var eHttp: HTTPController = HTTPController() // 网络操作类的实例
    var imageCache_Dic = Dictionary<String,UIImage>() // 定义一个图片缓存的字典
    var musicData_Arr: [JSON] = []
    var timer: Timer? // 声明一个计时器
    var isAutoFinish: Bool = true
    
    @IBOutlet weak var btnOrder: OrderButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        // 让封面旋转起来
        cdImage.onRotation()
        // 设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        background.addSubview(blurView)
        
        // table
        musicTable.dataSource = self
        musicTable.delegate = self
        musicTable.backgroundColor = UIColor.clear
        
        // 为网络操作类实例设置代理
        eHttp.delegate = self
        eHttp.onSearch(url: "https://www.douban.com/j/app/radio/channels")
        eHttp.onSearch(url: "https://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        // 监听按钮
        btnPlay.addTarget(self, action: #selector(ViewController.onPlay(btn:)), for: UIControlEvents.touchUpInside)
        btnNext.addTarget(self, action: #selector(ViewController.onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnPre.addTarget(self, action: #selector(ViewController.onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnOrder.addTarget(self, action: #selector(ViewController.onOrder(btn:)), for: UIControlEvents.touchUpInside)
        
        // 播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playFinish), name: NSNotification.Name(rawValue: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey), object: audioPlayer)
    }
    
    func playFinish() {
        if isAutoFinish {
            switch btnOrder.order {
            case 1:
                // 顺序播放
                currentIndex += 1
                if currentIndex > musicData_Arr.count - 1 {
                    currentIndex = 0
                }
                onSelectRow(index: currentIndex)
            case 2:
                // 随机
                currentIndex = Int(arc4random()) % musicData_Arr.count
                onSelectRow(index: currentIndex)
            case 3:
                // 单曲循环
                onSelectRow(index: currentIndex)
            default:
                print("**** playFinish ****")
            }
        }else{
            isAutoFinish = true
        }
        
    }
    
    func onOrder(btn: OrderButton) -> () {
        var message: String = ""
        switch btn.order {
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "error"
        }
        
        self.view.makeToast(message: message, duration: 0.6, position: "center" as AnyObject)
    }
    
    
    /// 播放和暂停
    func onPlay(btn: CustomButton) -> () {
        if btn.isPlay {
            audioPlayer.play()
        }else{
            audioPlayer.pause()
        }
    }
    
    /// 上一首和下一首
    func onClick(btn: CustomButton) -> () {
        isAutoFinish = false
        if btn == btnNext {
            currentIndex += 1

            if currentIndex > (self.musicData_Arr.count - 1) {
                currentIndex = 0
            }
        }else{
            if currentIndex < 0 {
                currentIndex = self.musicData_Arr.count - 1
            }
        }
        
        onSelectRow(index: currentIndex)
    }
    
    
    // 选中了哪一行
    func onSelectRow(index: Int) -> () {
        // 构建一个索引的indexPath
        let indexPath = NSIndexPath(row: index, section: 0)
        
        // 选中的效果
        musicTable.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        // 获取行数据
        var rowData: JSON = self.musicData_Arr[index]
        // 获取该行图片的地址
        let imgUrl = rowData["picture"].string
//        print(imgUrl!)
        // 设置封面及背景
        onSetImage(url: imgUrl!)
        
        // 获取歌曲文件地址
        let url: String = rowData["url"].string!
        // 播放音乐
        onSetAudio(url: url)
    }
    
    
    /// 设置歌曲的封面以及背景
    ///
    /// - Parameter url: 图片的地址
    func onSetImage(url: String) -> () {
        
        onGetCacheImage(url: url, imgView: self.cdImage)
        onGetCacheImage(url: url, imgView: self.background)
    }
    
    
    /// 播放音乐的方法
    func onSetAudio(url:String) -> () {
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)! as URL
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        
        // 先停掉计时器
        timer?.invalidate()
        playTime.text = "00:00"
        
        // 启动计时器
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
        
        isAutoFinish = true
    }
    
    
    func onUpdate() -> () {
        // 获取播放器当前的播放时间
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            
            // h获取歌曲的总时间
            let t = audioPlayer.duration
            // 计算百分比
            let pro: CGFloat = CGFloat( c / t)
            // 按百分比显示进度条的宽度
            progress.frame.size.width = view.frame.size.width * pro
            
            
            // 实现 00:00这种格式的播放时间
            let all: Int = Int(c)
            let m: Int = all % 60  // 秒
            let f: Int = Int( all / 60) // 分
            
            var time: String = ""
            if f < 10 {
                time = "0\(f):"
            }else{
                time = "\(f):"
            }
            
            if m < 10 {
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            
            // 更新播放时间
            playTime.text = time
        }
    }
    
    
    
    
    
    /// 图片缓存策略的方法
    ///
    /// - Parameters:
    ///   - url: 图片的地址
    ///   - imgView: 需要被设置的imageView控件
    func onGetCacheImage(url:String, imgView:UIImageView) -> () {
        
        // 通过图片地址去获取缓存中的图片
        let image = self.imageCache_Dic[url] as UIImage?
        
        if nil == image {
            // 没有缓存
            Alamofire.request(url, method: .get).responseJSON(completionHandler: { (data) in
                //
                let img = UIImage(data: data.data!)
                imgView.image = img
                
                // 做缓存
                self.imageCache_Dic[url] = img
            })
        }else{
            // 有缓存，就直接设置
            imgView.image = image!
        }
    }
    
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataArr.count
        print(musicData_Arr.count)
        return musicData_Arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = musicTable.dequeueReusableCell(withIdentifier: "myCell")
        // 设置cell的标题
        cell?.backgroundColor = UIColor.clear
        //
        let rowDataDic: JSON = musicData_Arr[indexPath.row]
        
        cell?.textLabel?.text = rowDataDic["albumtitle"].string
        cell?.detailTextLabel?.text = rowDataDic["artist"].string
        // 设置缩略图
        cell?.imageView?.image = UIImage(named: "4")
        
        // 封面的网址：
        let url = rowDataDic["picture"].string

        onGetCacheImage(url: url!, imgView: (cell?.imageView!)!)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectRow(index: indexPath.row)
        isAutoFinish = false
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 设置cell的显示动画
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        
        UIView.animate(withDuration: 0.25) { 
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        let channelC:ChannelViewController = segue.destination as! ChannelViewController
        
        // 设置代理
        channelC.delegate = self
        //
        channelC.channelData_Arr = self.channelData_Arr
    }

    
    // MARK: - ChannelProtocol
    func onChangeChannel(channel_id: String) {
        // 拼凑频道列表的歌曲数据网络地址
        // https://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite 频道id &from=mainsite
        let url: String = "https://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        
        eHttp.onSearch(url: url)
        
    }
    
    
    
    
    
    
    
    // MARK: - HttpProtocol
    
    func didRecieveResults(results: Any)
    {
//        print("666 = \(results)")
        let json = JSON(results)
//        print(JSON(results)["song"])
        if let channels = json["channels"].array {
            channelData_Arr = channels
        }else if let song = json["song"].array{
            isAutoFinish = false
            musicData_Arr = song
//            print(dataArr_2)
            // 刷表
            self.musicTable.reloadData()
            onSelectRow(index: 0)
        }
    }
    

    
    
    
    
    
    
    
    
    
    // MARK: - Other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}





































