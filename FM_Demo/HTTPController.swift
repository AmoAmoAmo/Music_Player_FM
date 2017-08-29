import UIKit
import Alamofire
import SwiftyJSON

class HTTPController: NSObject {
    var delegate: HttpProtocol?
    
    // 接收网址，回调代理的方法传回数据
    func onSearch(url: String){
        /*
          参数1：访问网络的方式
          2：访问的网址
          3：网络地址携带的参数
          4：编码
         */
        Alamofire.request(url, method: .get).responseJSON { (returnResult) in
            // responseJSON 参数：获取数据之后回调的方法
//            print("***获取数据成功***")
//            let value = returnResult.result.value
//            print(value!)
            let j = returnResult.result.value // Any
//            print(JSON(j)["song"])
            
            self.delegate?.didRecieveResults(results: j!)
        }
    }
    
    
}

protocol HttpProtocol{
    func didRecieveResults(results: Any)
}
