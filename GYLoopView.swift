//
//  GYLoopView.swift
//  swift_LoopView
//
//  Created by Gene_Ye on 2017/7/20.
//  Copyright © 2017年 Gene. All rights reserved.
//

import UIKit


protocol GYLoopViewDelegate: NSObjectProtocol {
    
    func tapAction(index: Int)
    
}

class GYLoopView: UIView ,UIScrollViewDelegate{
    
//    //声明闭包
//    typealias clickViewClosure = (_ index: Int?) -> Void
//    //把声明的闭包设置成属性
//    var clickClosure: clickViewClosure?
    
    private var myTimer = Timer()
    
    var autoScrollDelay = 2.0         //轮播时间
    
    var loopView = UIScrollView()
    
    var dataSource = NSMutableArray()
    
    private var index = 0
    
    private var isNetWork: Bool!
    
    private var cachePath: NSString!
    
    private var pageControl: UIPageControl!
    
    var delegate: GYLoopViewDelegate!
    
    
    /*
     不管有多少图片，都交替使用这三个imageView
     */
    var letfImageView = UIImageView()
    var centerImageView = UIImageView()
    var rightImageView = UIImageView()

    lazy var webImageCache:NSMutableDictionary = {
       let cache = NSMutableDictionary()
        return cache
    }()
    
    
    /*
     关于初始化:
     1，在 Swift 中, 类的初始化器有两种, 分别是Designated Initializer（指定初始化器）和Convenience Initializer（便利初始化器）
     2，如果子类没有定义任何的指定初始化器, 那么会默认继承所有来自父类的指定初始化器。
     3，如果子类提供了所有父类指定初始化器的实现, 那么自动继承父类的便利初始化器
     4，如果子类只实现部分父类初始化器，那么父类其他的指定初始化器和便利初始化器都不会继承。
     5，子类的指定初始化器必须要调用父类合适的指定初始化器。
     */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, imageUrlArray: NSMutableArray) {
        super.init(frame: frame)
        self.dataSource = imageUrlArray
        
        //获取沙盒路径
        cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last as NSString!
        
        getImageData()
        
        setLoopView()

        setTimer()
        
        peaprePageControl()
        
        addGesture()
        
        //如果图片只有一张，不允许滚动
        if dataSource.count < 2 {
            loopView.isScrollEnabled = false
        }
    }
    
    func setPageControl(frame: CGRect,currentIndicatorTintColor: UIColor,pageIndicatorTintColor: UIColor){
        self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        self.pageControl.currentPageIndicatorTintColor = currentIndicatorTintColor
        self.pageControl.numberOfPages = self.dataSource.count
        
    }
    
    
    private func peaprePageControl(){
        let pageControl = UIPageControl(frame: CGRect(x: self.frame.width/2-50, y: self.frame.size.height-30, width: 100, height: 20))
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = UIColor.cyan
        pageControl.numberOfPages = self.dataSource.count
        pageControl.currentPage = index
        
        self.pageControl = pageControl
        
        self.addSubview(self.pageControl)
    }

    private func setLoopView(){
        
        let CYCLEVIEW_W = self.frame.size.width
        let CYCLEVIEW_H = self.frame.size.height
        
        loopView.frame = CGRect(x: 0, y: 0, width: CYCLEVIEW_W, height: CYCLEVIEW_H)
        loopView.contentSize = CGSize(width: CYCLEVIEW_W*CGFloat(3), height: 0)
        loopView.isPagingEnabled = true
        loopView.contentOffset = CGPoint(x: CYCLEVIEW_W, y: 0)
        loopView.showsVerticalScrollIndicator = false
        loopView.showsHorizontalScrollIndicator = false
        loopView.delegate = self
        
        //左
        letfImageView.frame = CGRect(x: 0, y: 0, width: CYCLEVIEW_W, height: CYCLEVIEW_H)
        //中
        centerImageView.frame = CGRect(x: CYCLEVIEW_W, y: 0, width: CYCLEVIEW_W, height: CYCLEVIEW_H)
        //右
        rightImageView.frame = CGRect(x: CYCLEVIEW_W*CGFloat(2), y: 0, width: CYCLEVIEW_W, height: CYCLEVIEW_H)
        
        self.changeImage(leftIndex: dataSource.count-1, centerIndex: 0, rightIndex: 1)
        
        loopView.addSubview(letfImageView)
        loopView.addSubview(rightImageView)
        loopView.addSubview(centerImageView)
        
        self.addSubview(loopView)

    }
    
    private func changeImage(leftIndex: Int, centerIndex: Int, rightIndex: Int) {
       
        letfImageView.image = self.setImage(urlString: dataSource[leftIndex] as! String) as UIImage
        centerImageView.image = self.setImage(urlString: dataSource[centerIndex] as! String) as UIImage
        rightImageView.image = self.setImage(urlString: dataSource[rightIndex] as! String ) as UIImage
        
        
        self.loopView.contentOffset.x = self.frame.size.width
    }
    
    @objc private func scroll(){
       self.loopView.setContentOffset(CGPoint(x: self.frame.size.width+self.loopView.contentOffset.x, y: 0), animated: true)
    }
    
    /*
      网络请求
     */
    private func getImageData(){

        for key in self.dataSource {
            
            if self.loadDiskCacheWith(urlString: key as! NSString) {  //检查是否有缓存
                continue
            }

            let url: URL = URL(string: key as! String)!
            
            URLSession(configuration: .default).dataTask(with: url, completionHandler: {(imageData, response, error) in
            
                self.downLoadImageFinish(data: imageData!, urlString: key as! NSString, path: self.cachePath as NSString)
                
            }).resume()
        
        }
    }
    
    /*
      将data写入沙盒，进行缓存处理
     */
    private func downLoadImageFinish(data: Data, urlString: NSString, path: NSString) {
        let image = UIImage(data: data)
        
        if image == nil {
            return
        }
        NSData(data: data).write(toFile: (path.appendingPathComponent(urlString.lastPathComponent)) as String, atomically: true)
        
        self.webImageCache.setValue(data, forKey: urlString as String)
        
    }
    
    /*
     检查是否有缓存
     */
    private func loadDiskCacheWith(urlString: NSString) -> Bool{
        let data = NSData(contentsOfFile: self.cachePath.appendingPathComponent(urlString.lastPathComponent))
        
        if data != nil {
            let image = UIImage(data: data as! Data)
            
            if image != nil {
                self.webImageCache.setValue(data as! Data, forKey: urlString as String)
            }else{
                try! FileManager.default.removeItem(atPath: self.cachePath.appendingPathComponent(urlString.lastPathComponent) as String)
            }
        }
        return false
    }
    
    /*
     设置图片
     */
    private func setImage(urlString: String) -> UIImage {
        
        if self.webImageCache.object(forKey: urlString) != nil {
            
            let imageData = self.webImageCache.object(forKey: urlString) as! Data
            
            return UIImage(data: imageData)!
        }
        
        return UIImage()
    }
    
    
    // pragma mark --- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x >= self.frame.size.width*CGFloat(2) {
            
//            print("====lastIndex:\(index)")
            
            index = index + 1
            
            if index == dataSource.count {
                index = 0
                self.changeImage(leftIndex: dataSource.count-1, centerIndex: 0, rightIndex: 1)
                
            }else if index == dataSource.count-1 {  //3
                
                self.changeImage(leftIndex: index-1, centerIndex: index, rightIndex: 0)
                
            }else {
                self.changeImage(leftIndex: index-1, centerIndex: index, rightIndex: index+1)
                
            }
            
//            print("====currentIndex:\(index)======MaxCount:\(dataSource.count)")
        }
        
        if scrollView.contentOffset.x <= 0.1 {
//            print("====lastIndex:\(index)")
            index = index - 1
            
            if index == -1 {
                index = dataSource.count-1
                self.changeImage(leftIndex: index-1, centerIndex: index, rightIndex: 0)
            }else if index == 0 {
                self.changeImage(leftIndex: dataSource.count-1, centerIndex: index, rightIndex: index+1)
            }else{
                self.changeImage(leftIndex: index-1, centerIndex: index, rightIndex: index+1)
            }
//            print("====currentIndex:\(index)======MaxCount:\(dataSource.count)")
        }
        
        
        self.pageControl.currentPage = index
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setTimer()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        moveTimer()
    }
    
    private func setTimer() {
        if autoScrollDelay < 0.5  {
            return
        }
        myTimer = Timer.scheduledTimer(timeInterval: autoScrollDelay, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
    }
    
    private func moveTimer() {
        myTimer.invalidate()
        
    }
    
    private func addGesture() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func tapAction(){
        
        delegate.tapAction(index: index)
    }
    
    
    
    override func layoutIfNeeded() {
        print("layoutIfNeeded")
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}










