

import UIKit

class CustomButton: UIButton {

    var isPlay: Bool = true
    let imgPlay:UIImage = UIImage(named: "1_play")!
    let imgPause: UIImage = UIImage(named: "1_stop")!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(CustomButton.onClick), for: UIControlEvents.touchUpInside)
    }
    
    func onClick() -> () {
        
        isPlay = !isPlay
        
        if isPlay {
            self.setImage(imgPause, for: UIControlState.normal)
        }else{
            self.setImage(imgPlay, for: UIControlState.normal)
        }
    }
    
    func onPlay() -> () {
        isPlay = true
        self.setImage(imgPause, for: UIControlState.normal)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
