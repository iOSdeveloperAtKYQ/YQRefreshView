//
//  RefreshFootView.swift
//  Eat
//
//  Created by YI on 2020/11/27.
//

import UIKit

class RefreshFootView: RefreshView {
    
    override var refreshState: RefreshState? {
        willSet {
            tipsLabel?.isHidden = false
            loadingView?.isHidden = true
            if newValue == .Ready  {
                tipsLabel?.text = "上拉加载更多"
            }else if newValue == .WillRefresh  {
                tipsLabel?.text = "松开立即加载"
            }else if newValue == .Refreshing {
                tipsLabel?.isHidden = true
                loadingView?.isHidden = false
            }else {
                tipsLabel?.text = "——— 这是人家的底线 ———"
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tipsLabel?.frame = self.bounds
        self.loadingView?.center = .init(x: self.center.x, y: self.frame.size.height / 2.0)
    }
    
    
    /// 初始化footView
    /// - Parameters:
    ///   - refresh: 刷新回调
    ///   - scrollView: scrollView
    /// - Returns: footView
    class func footView(refresh: @escaping () -> Void, scrollView: UIScrollView) -> RefreshFootView {
        let footH: CGFloat = 50
        let footView = RefreshFootView.init(frame: .init(x: 0, y: scrollView.frame.size.height, width: scrollView.frame.size.width, height: footH))
        footView.scrollView = scrollView
        footView.refresh = refresh
        footView.setSubviews()
        
        scrollView.addObserver(footView, forKeyPath: RefreshView.contentSizeKeyPath, options: .new, context: nil)
        
        return footView
    }
    
    /// 设置子view
    func setSubviews() {
        self.tipsLabel = UILabel.init()
        self.tipsLabel?.text = "上拉加载更多"
        self.tipsLabel?.textColor = .lightGray
        self.tipsLabel?.textAlignment = .center
        self.tipsLabel?.backgroundColor = .clear
        self.addSubview(self.tipsLabel!)
        
        let w: CGFloat = 40
        self.loadingView = ActivityIndicatorView.init(type: .BallPulse, contentColor: .blue, contentSize: .init(width: w, height: w))
        self.loadingView?.isHidden = true
        self.loadingView!.startAnimation()
        self.loadingView?.frame.size.width = w
        self.loadingView?.frame.size.height = w
        self.loadingView?.center = .init(x: self.center.x, y: self.frame.size.height / 2.0)
        self.addSubview(self.loadingView!)
    }
    
    /// KVO监听contentOffset和contentSize的变化
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == RefreshView.contentOffsetKeyPath {
            if self.canRefresh == true && self.scrollView!.isDragging == false {
                if self.refreshState == .WillRefresh {
                    //松手进入刷新状态
                    self.refreshState = .Refreshing
                    if self.refresh != nil {
                        self.refresh!()
                    }
                    
                    var bottom: CGFloat = 0
                    if self.scrollView!.contentSize.height > self.scrollView!.frame.size.height {
                        //内容高度超出了scrollView的高度
                        bottom = self.frame.size.height
                    }else {
                        //内容高度低于scrollView的高度
                        bottom = self.scrollView!.frame.size.height + self.frame.size.height - self.scrollView!.contentSize.height
                    }
                    
                    UIView.animate(withDuration: 0.5) {
                        self.scrollView?.contentInset.bottom = bottom
                    }
                }
            }
            
            if self.scrollView!.isDragging == true {
                if self.refreshState != .Refreshing && self.refreshState != .NoMoreData {
                    //非刷新状态下拖拽scrollView
                    if self.scrollView!.contentSize.height > self.scrollView!.frame.size.height {
                        //内容高度超出了scrollView的高度
                        if (self.scrollView!.contentOffset.y + self.scrollView!.frame.size.height) >= (self.scrollView!.contentSize.height + self.frame.size.height + 5) {
                            self.refreshState = .WillRefresh
                            self.canRefresh = true
                        }else {
                            self.refreshState = .Ready
                            self.canRefresh = false
                        }
                    }else {
                        //内容高度低于scrollView的高度
                        if self.scrollView!.contentOffset.y >= self.frame.size.height + 5 {
                            self.refreshState = .WillRefresh
                            self.canRefresh = true
                        }else {
                            self.refreshState = .Ready
                            self.canRefresh = false
                        }
                    }
                }
                
            }
        }else if keyPath == RefreshView.contentSizeKeyPath {
            //内容高度发生改变，改变footView的y值
            if self.scrollView!.contentSize.height > self.scrollView!.frame.size.height {
                self.frame.origin.y = self.scrollView!.contentSize.height
            }else {
                self.frame.origin.y = self.scrollView!.frame.size.height
            }
        }else if keyPath == RefreshView.boundsKeyPath {
            //scrollView的bound发生改变
            let newValue: CGRect = change?[NSKeyValueChangeKey.newKey] as? CGRect ?? .zero
            let oleValue: CGRect = change?[NSKeyValueChangeKey.oldKey] as? CGRect ?? .zero
            if newValue.size.width != oleValue.size.width {
                self.frame.size.width = newValue.size.width
            }
        }
    }
    
    
    /// 停止刷新
    func endRefresh() {
        self.scrollView?.contentInset = .zero
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshState = .Ready
        }
    }
    
    /// 没有更多数据
    func noMoreData() {
        var bottom: CGFloat = 0
        if self.scrollView!.contentSize.height > self.scrollView!.frame.size.height {
            bottom = self.frame.size.height
        }else {
            bottom = self.scrollView!.frame.size.height + self.frame.size.height - self.scrollView!.contentSize.height
        }
        self.scrollView?.contentInset.bottom = bottom
        
        self.refreshState = .NoMoreData
    }
    
    /// 重置没有更多数据的状态
    func resetNoMoreData() {
        if self.refreshState == .NoMoreData {
            self.refreshState = .Ready
            self.scrollView?.contentInset = .zero
        }
    }
    
    deinit {
        if self.scrollView != nil {
            self.scrollView!.removeObserver(self, forKeyPath: RefreshView.contentOffsetKeyPath, context: nil)
            self.scrollView!.removeObserver(self, forKeyPath: RefreshView.contentSizeKeyPath, context: nil)
            self.scrollView!.removeObserver(self, forKeyPath: RefreshView.boundsKeyPath, context: nil)
        }
 
    }

}
