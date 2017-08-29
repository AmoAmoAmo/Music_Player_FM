//
//  MyImage.swift
//  FM_Demo
//
//  Created by Josie on 17/5/10.
//  Copyright © 2017年 Josie. All rights reserved.
//

import UIKit

class MyImage: UIImageView {

    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
//        print("aa\(self.frame.size.width)")  // 运行的时候先走的这里，再走的storyboard
        // 描边
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }


    // 旋转
    func onRotation(){
        let animation = CABasicAnimation(keyPath: "transform.rotation")
    
        animation.fromValue = 0.0
        
        animation.toValue = M_PI * 2.0
        
        animation.duration = 20
        
        animation.repeatCount = 10000
        
        self.layer.add(animation, forKey: nil)
        
    }
    
    
}
