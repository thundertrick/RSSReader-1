//
//  AddFeedViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 23/04/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {
    
    let saveFeedManager = SaveFeedManager()
    let updateDataManager = UpdateDataManager()
    @IBOutlet var urlLabel: UILabel!
    
    @IBOutlet var urlField: UITextField!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Feed"
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        saveFeedManager.delegate = appDel.mainViewController
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancel
        
        
        let save = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        save.setTitleTextAttributes([NSFontAttributeName : UIFont.boldFontWithSize(17)], forState: .Normal)
        self.navigationItem.rightBarButtonItem = save
        
        
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldFontWithSize(17)]

        urlLabel.font = UIFont.fontWithSize(17)
        urlField.font = UIFont.fontWithSize(14)
        
        nameLabel.font = UIFont.fontWithSize(17)
        nameField.font = UIFont.fontWithSize(14)
        
        urlField.text = UIPasteboard.generalPasteboard().string
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.urlField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func cancel() {
           self.view.endEditing(true)
    
          self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        self.view.endEditing(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: {
            self.saveFeedManager.saveFeedWithURL(self.urlField.text!, withName: self.nameField.text!)
        })
        
    }
    
  
    @IBAction func addSuggestedFeed(sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController!.dismissViewControllerAnimated(true, completion: {
            self.saveFeedManager.saveFeedWithURL("http://www.theverge.com/rss/index.xml", withName: "The Verge")
             self.saveFeedManager.saveFeedWithURL("http://www.vox.com/rss/index.xml", withName: "Vox")
             self.saveFeedManager.saveFeedWithURL("http://feeds.wired.com/wired/index", withName: "WIRED")
             self.saveFeedManager.saveFeedWithURL("http://feeds.feedburner.com/TechCrunch/", withName: "Techcrunch")
             self.saveFeedManager.saveFeedWithURL("http://daringfireball.net/feeds/main", withName: "Daring Fireball")
        })

        
    }

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDel.mainViewController.slideMenuController()?.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        
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
