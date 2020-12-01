//
//  ViewController.swift
//  YQRefreshView
//
//  Created by Mac123 on 2020/12/1.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var count = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.refreshHeaderView { [weak self] in
            if self != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self!.count -= 3
                    if self!.count < 1 {
                        self!.count = 1
                    }
                    self!.tableView.reloadData()
                    self!.tableView.refreshHeaderView?.endRefresh()
                }
            }
        }
       
        
        self.tableView.refreshFootView { [weak  self] in
            if self != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self!.count += 5
                    self!.tableView!.reloadData()
                    self!.count >= 20 ? self!.tableView.refreshFootView?.noMoreData() : self!.tableView.refreshFootView?.endRefresh()
                }
            }
        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String.init(format: "%ld", indexPath.row)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        return cell
    }

}

