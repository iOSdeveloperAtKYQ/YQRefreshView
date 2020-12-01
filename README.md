# YQRefreshView
一句代码集成下来刷新和上拉加载更多

# 效果图
![](https://github.com/iOSdeveloperAtKYQ/YQRefreshView/blob/master/效果图/效果图.gif)
# 使用方法
下拉刷新
```swift
        self.tableView.refreshHeaderView {
            //这里进行刷新操作
        }
        //结束刷新
        self.tableView.refreshHeaderView?.endRefresh()
```
上来加载更多
```swift
        self.tableView.refreshFootView {
            //这里进行加载更多操作
        }
        //结束加载更多
        self.tableView.refreshFootView?.endRefresh()
        
        //如果服务器没有更多数据返回，可以使用这个方法
        self.tableView.refreshFootView?.noMoreData()
```
