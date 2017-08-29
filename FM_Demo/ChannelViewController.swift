//
//  ChannelViewController.swift
//  FM_Demo
//
//  Created by Josie on 17/5/10.
//  Copyright © 2017年 Josie. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol {
    // 1).回调方法，将频道ID传回到代理中
    func onChangeChannel(channel_id: String)
}

class ChannelViewController: UIViewController, UITableViewDelegate{
    // table
    @IBOutlet weak var channelTable: UITableView!

    // 2).声明代理
    var delegate: ChannelProtocol?
    
    // 频道列表数据
    var channelData_Arr: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0.8
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData_Arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = channelTable.dequeueReusableCell(withIdentifier: "channel")
        //
        let rowData:JSON = self.channelData_Arr[indexPath.row] as JSON
        
        
        // 设置cell的标题
        cell?.textLabel?.text = rowData["name"].string
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取行数据
        let rowData: JSON = self.channelData_Arr[indexPath.row] as JSON
        // 获取选中行的频道id
        let channel_id: String = rowData["channel_id"].stringValue
        
        // 将频道id反向传给主界面
        delegate?.onChangeChannel(channel_id: channel_id)
        //
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 设置cell的显示动画
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        
        UIView.animate(withDuration: 0.25) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
