//
//  ChannerlController.swift
//  DouBanFM
//
//  Created by JiaYuanFa on 16/8/5.
//  Copyright © 2016年 Jafar MacPro. All rights reserved.
//

import UIKit

protocol ChannerDelegate {
    func onChangeChannel(channelId:String)
}

class ChannerlController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var channelTableView: UITableView!
    var delegate:ChannerDelegate?
    var channelData:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: "channelCell")
        let rowData = self.channelData[indexPath.row] as! NSDictionary
        cell.textLabel?.text = rowData["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("点击了:\(indexPath.row)")
        let rowData = self.channelData[indexPath.row] as! NSDictionary
        let channelId = rowData["channel_id"]!
        let channelIdStr = "channel=\(channelId)"
        self.delegate?.onChangeChannel(channelIdStr)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
