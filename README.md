# swift_LoopView
1.利用三个imageView实现轮播图效果
2.URLSession进行网络请求，并实现缓存

#使用:
let loopView = GYLoopView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: 200), imageUrlArray: imageArray)

#遵循代理:
loopView.delegate = self

#添加到父视图
self.view.addSubview(loopView)

#实现代理:
func tapAction(index: Int) {

}
