//
//  ViewController.swift
//  tableView
//
//  Created by lvjiaqi on 16/4/28.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

import UIKit




class ViewController: UITableViewController {

    var cellNum:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.Q_addPullDownRefreshWithActionHandler {
            [unowned self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                  self.tableView!.reloadData()
                  self.tableView!.Q_completeLoading()
            })
        }
        
        self.tableView!.Q_addPullUpLoadMoreWithActionHandler{
            [unowned self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                
                self.requreMoreData()
                //self.tableView!.Q_failLoadMore()
                self.tableView!.Q_completeLoadMore()
                
                var cells:[NSIndexPath] = [NSIndexPath]()
                for  index in 0...9 {
                    let cell:NSIndexPath = NSIndexPath(forRow: index+self.cellNum, inSection: 0)
                    cells.append(cell)
                }
                self.cellNum += 10
                self.tableView!.insertRowsAtIndexPaths(cells, withRowAnimation: UITableViewRowAnimation.Automatic)
                
            })
        }

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func  requreMoreData(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellNum;
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = "我是第 \(indexPath.row) 个Cell 随机数为  \(rand())"
        
        return cell
        
    }
    
   /*override func viewDidAppear(animated: Bool) {
        print("\(self.tableView!.frame ) --- \(self.tableView!.contentOffset) ---- \(self.tableView!.contentSize)---\(self.tableView!.contentOffset)")
    }*/
    
}

