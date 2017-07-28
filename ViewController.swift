//
//  ViewController.swift
//  swift_LoopView
//
//  Created by Gene_Ye on 2017/7/20.
//  Copyright © 2017年 Gene. All rights reserved.
//

import UIKit

let SCREEN_W = UIScreen.main.bounds.size.width
let SCRREN_H = UIScreen.main.bounds.size.height

class ViewController: UIViewController, GYLoopViewDelegate{


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let dataSource = NSMutableArray()
//        
//        dataSource.add(UIColor.red)
//        dataSource.add(UIColor.blue)
//        dataSource.add(UIColor.cyan)
//        dataSource.add(UIColor.green)
        
        
        let imageArray = NSMutableArray()
        imageArray.add("http://img4.duitang.com/uploads/item/201112/20/20111220192402_mBuZj.thumb.700_0.jpg")
        imageArray.add("http://img.yanj.cn/store/goods/2093/2093_75db88665f8edbf6db1bb500c64a5dc9.jpg_max.jpg")
        imageArray.add("http://p3.wmpic.me/article/2016/01/02/1451705414_FCsmpfEP.jpg")
        imageArray.add("http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1507/01/c0/9172260_1435759945174_800x600.jpg")

        
        let loopView = GYLoopView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: 200), imageUrlArray: imageArray)
        loopView.delegate = self
        self.view.addSubview(loopView)
    }
    
    
    func tapAction(index: Int) {
        print(index)
    }

    @IBAction func clickAction(_ sender: Any) {
        
        print("!!!!!!!!!!")
    }
}

