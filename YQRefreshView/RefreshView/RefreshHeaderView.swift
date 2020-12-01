//
//  RefreshHeaderView.swift
//  Eat
//
//  Created by YI on 2020/11/27.
//

import UIKit

class RefreshHeaderView: RefreshView {

    override var refreshState: RefreshState? {
        willSet {
            tipsLabel?.isHidden = false
            loadingView?.isHidden = true
            if newValue == .Ready  {
                tipsLabel?.text = "下拉刷新"
            }else if newValue == .WillRefresh  {
                tipsLabel?.text = "松开立即刷新"
            }else if newValue == .Refreshing {
                tipsLabel?.isHidden = true
                loadingView?.isHidden = false
            }else {
                tipsLabel?.text = "刷新完成"
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tipsLabel?.frame = self.bounds
        self.loadingView?.center = .init(x: self.center.x, y: self.frame.size.height / 2.0)
    }
    
    /// 初始化headerView
    /// - Parameters:
    ///   - refresh: 刷新回调
    ///   - scrollView: scrollView
    /// - Returns: headerView
    class func headerView(refresh: @escaping () -> Void, scrollView: UIScrollView) -> RefreshHeaderView {
        let headerH: CGFloat = 50
        
        let headerView = RefreshHeaderView.init(frame: .init(x: 0, y: -headerH, width: scrollView.frame.size.width, height: headerH))
        headerView.scrollView = scrollView
        headerView.refresh = refresh
        
        headerView.setSubviews()
        
        return headerView
    }
    
    /// 设置子view
    func setSubviews() {
        self.tipsLabel = UILabel.init()
        self.tipsLabel?.text = "下拉刷新"
        self.tipsLabel?.textColor = .lightGray
        self.tipsLabel?.textAlignment = .center
        self.tipsLabel?.backgroundColor = .clear
        self.addSubview(self.tipsLabel!)
                
        
        let w: CGFloat = 40
        self.loadingView = ActivityIndicatorView.init(type: .BallClipRotatePulse, contentColor: .blue, contentSize: .init(width: w, height: w))
        self.loadingView?.isHidden = true
        self.loadingView!.startAnimation()
        self.loadingView?.frame.size.width = w
        self.loadingView?.frame.size.height = w
        self.loadingView?.center = .init(x: self.center.x, y: self.frame.size.height / 2.0)
        self.addSubview(self.loadingView!)
    }
    
    /// KVO监听contentOffset的变化
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == RefreshView.contentOffsetKeyPath {
            if canRefresh == true && self.scrollView!.isDragging == false {
                if self.refreshState == .WillRefresh {
                    //松手进入刷新状态
                    self.refreshState = .Refreshing
                    if self.refresh != nil {
                        self.refresh!()
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.scrollView?.contentInset.top = self.frame.size.height
                    }
                }
            }
            
            if self.scrollView!.isDragging == true {
                if self.refreshState != .Refreshing && self.refreshState != .Refreshed {
                    //非刷新状态下拖拽scrollView
                    if self.scrollView!.contentOffset.y <= -(self.frame.size.height  + 5) {
                        self.refreshState = .WillRefresh
                        self.canRefresh = true
                    }else {
                        self.refreshState = .Ready
                        self.canRefresh = false
                    }
                }
                
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
    
    
    func endRefresh() {
        self.refreshState = .Refreshed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5) {
                self.scrollView?.contentInset = .zero
            } completion: { [self] (finished) in
                self.refreshState = .Ready
                if self.scrollView?.refreshFootView?.refreshState == .NoMoreData {
                    //充值没有更多数据状态
                    self.scrollView?.refreshFootView?.resetNoMoreData()
                }

            }
        }
    }
    
    deinit {
        if self.scrollView != nil {
            self.scrollView!.removeObserver(self, forKeyPath: RefreshView.contentOffsetKeyPath, context: nil)
            self.scrollView!.removeObserver(self, forKeyPath: RefreshView.boundsKeyPath, context: nil)
        }
    }
}
