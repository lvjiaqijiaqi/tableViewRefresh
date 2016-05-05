//
//  ViewController.swift
//  tableView
//
//  Created by lvjiaqi on 16/4/28.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit



class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.Q_addPullDownRefreshWithActionHandler {
            [unowned self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                  self.tableView!.reloadData()
                  self.tableView!.Q_completeLoading()
            })
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40;
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = "我是第 \(indexPath.row) 个Cell 随机数为  \(rand())"
        
        return cell
        
    }
}

