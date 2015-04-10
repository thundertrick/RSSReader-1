//
//  MainTableViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 01/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit

var currentArticle : Article? = nil


class MainTableViewController: UITableViewController, SideBarDelegate, SaveFeedDelegate, UpdateDataManagerDelegate, NSFetchedResultsControllerDelegate {
    
    
    // iniatialize UI Helper Classes
    var sideBar = SideBar()
    
    // initialize data helper classs
    var saveFeedManager = SaveFeedManager()
    var updateDataManager = UpdateDataManager()
    var dataHelper = CoreDataHelper()
    var managedObjectContext: NSManagedObjectContext?
    var currentView = 1
    let error = NSErrorPointer()
    var shouldReloadContent = true
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
    
        // setup refresh classes delegates
        saveFeedManager.delegate = self
        updateDataManager.delegate = self
    
        updateDataManager.update()
    
        // customize ui
        var markReadButton = UIBarButtonItem(title: "Mark All Read", style: .Plain, target: self, action: "markAllRead")
        var flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
         self.toolbarItems = [flexibleSpace, markReadButton, flexibleSpace]
        self.navigationController?.toolbarHidden = false
       
        // clear backButton text
        
        let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        // register nib for FeedTableViewCell
        var nib = UINib(nibName: "FeedTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
        nib = UINib(nibName: "FeedWithoutImageTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "withoutImage")

        // setup nav bar butons
        
        var menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = menuButton
        
        var gearButton = UIBarButtonItem(image: UIImage(named: "gear"), style: UIBarButtonItemStyle.Plain, target: self, action: "openSettings")
        self.navigationItem.rightBarButtonItem = gearButton
        
        // setup pull to refresh
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("updateFromRefreshButton"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // add observer for update
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateFromRefreshButton"), name: "update", object: nil)
        
        // set title
        self.title = "All"
     

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSideBar()
    }
    
    
    func setupSideBar() {
        var itemsForMenu : [String] = ["Add Feed", "All"]
        
        sideBar = SideBar(sourceView: self.navigationController!.view, menuItems: itemsForMenu, indexToSelect: currentView)
        sideBar.delegate = self
        
        sideBarDidSelectMenuButtonAtIndex(currentView)
        
        if sideBar.sideBarTableViewController.fetchedResultsController.fetchedObjects?.count == 0 {
            self.sideBarDidSelectMenuButtonAtIndex(0)
        }

    }
    
    
    
    
    
    // Menu Button functions
    
    // side Bar pressed

    func openMenu() {
        if sideBar.isSideBarOpen == true {
            sideBar.showSideBar(false)
        } else {
            sideBar.showSideBar(true)
        }
      
     
    }
    
    // settings button pressed
    func openSettings() {
        
    }
    
    // pull to refresh
    func updateFromRefreshButton() {
        updateDataManager.update()
        
    }
    
    func markAllRead() {
        let items = fetchedResultsController.fetchedObjects as! [Article]
        for item in items {
            if item.read.boolValue == false {
            item.read = true
            }
        }
        dataHelper.saveManagedObjectContext(fetchedResultsController.managedObjectContext)
        
    }
    
    
  
    
  

    // MARK: - SideBar Delegate
    
    func sideBarWillOpen() {
        // do this func
  
    }
    
    func sideBarWillClose() {
        // do this func
    }
    
    // sideBar button selected
    func sideBarDidSelectMenuButtonAtIndex(index: Int) {
        
        
     
        println(index)
        
            if self.navigationController?.visibleViewController != self {
                println("not table view controller")
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        
        if index == 0 { // Add Feed
            let alert = UIAlertController(title: "Add new feed", message: "Enter feed name and url", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "URL"
                textField.clearButtonMode = UITextFieldViewMode.Always
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Name (optional)"
                textField.clearButtonMode = UITextFieldViewMode.Always
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { action -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    let textFields = alert.textFields
                    let feedNameTextField = textFields!.last as! UITextField
                    feedNameTextField.endEditing(true)
                    let feedURLTextField = textFields!.first as! UITextField
                    feedURLTextField.endEditing(true)
                    if  let feedURL = feedURLTextField.text {
                        self.saveFeedManager.saveFeedWithURL(feedURL, withName: feedNameTextField.text)
                    }
                })
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
              self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            self.currentView = 1
           
        } else  if index == 1 {
            self.title = "All"
            self.fetchedResultsController.fetchRequest.predicate = nil
            self.fetchedResultsController.performFetch(self.error)
            
                self.tableView.reloadData()
       
          self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
         
            self.currentView = 1
          
        } else if index == 2 {
            self.title = "Unread"
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "read == %@", false)
            self.fetchedResultsController.performFetch(self.error)
      
            self.tableView.reloadData()
               self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
            self.currentView = 2

        } else if index == 3 {
            self.title = "Starred"
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "starred == %@", true)
            self.fetchedResultsController.performFetch(self.error)
            
            self.tableView.reloadData()
              self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
              self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
                      self.currentView = 3
        
        
        } else {
            let indexPath = NSIndexPath(forRow: index - 4, inSection: 0)
            var feed = self.sideBar.sideBarTableViewController.fetchedResultsController.objectAtIndexPath(indexPath) as! Feed
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "source == %@", feed.link)
            self.fetchedResultsController.performFetch(self.error)
           
            self.tableView.reloadData()
            self.title = feed.name
              self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
            self.currentView = index
            
            
        }
        
        if sideBar.isSideBarOpen {
            self.sideBar.showSideBar(false)
            
        }
        

        
    
    }
    
    
    // MARK: - updateData  Delegate

    func updateDataFailedWithError() {

        refreshControl?.endRefreshing()
        let alert = UIAlertController(title: "Refresh Failed", message: "Refresh of feed items failed. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        println("update Data failed")
        self.sideBarDidSelectMenuButtonAtIndex(currentView)
        self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentView, inSection: 0), animated: true, scrollPosition: .None)
        
        // write func

    }
   
    
    func updatedData() {
        println("updated data")
        refreshControl?.endRefreshing()
        self.sideBarDidSelectMenuButtonAtIndex(currentView)
        self.sideBar.sideBarTableViewController.tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentView, inSection: 0), animated: true, scrollPosition: .None)
       

    }
    
    
    // MARK: - saveFeed Delegate
    
     func savedFeedFailedWithError() {
        println("savedFeedFailedWithError")
        let alert = UIAlertController(title: "Feed could not be saved", message: "Please verify the validity of the RSS feed link and check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

        // write func
    }

     func feedSaved(feedItem: Feed) {
        println("feed saved")
        updateDataManager.update()
      
    }
    
    
   


    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let info = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       var cell: FeedTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! FeedTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        
        if sideBar.isSideBarOpen {
            sideBar.showSideBar(false)
        }
        
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! Article
        currentArticle = item
        item.read = true
        shouldReloadContent = false
        dataHelper.saveManagedObjectContext(fetchedResultsController.managedObjectContext)
  
        self.performSegueWithIdentifier("showArticle", sender: self)
        
      
    }

    
    func configureCell(cell: FeedTableViewCell, atIndexPath indexPath: NSIndexPath) {
     
        if self.fetchedResultsController.fetchedObjects?.count > indexPath.row {
          
            let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Article
            var imageSource = ""
            if item.content != nil {
                
                let htmlContent = item.content as NSString
                
                let rangeOfString = NSMakeRange(0, htmlContent.length)
                let regex = NSRegularExpression(pattern: "(<img.*?src=\")(.*?)(\".*?>)", options: nil, error: nil)
                
                if htmlContent.length > 0 {
                    var match = regex?.matchesInString(htmlContent as String, options: nil, range: rangeOfString)
                    
                    if (match != nil) && (match?.count > 0) {
                        for (index, value) in enumerate(match!) {
                           
                            let imageURL = htmlContent.substringWithRange(value.rangeAtIndex(2)) as NSString
                            
                            if (NSString(string: imageURL.lowercaseString).rangeOfString("feedburner").location == NSNotFound) && (NSString(string: imageURL.lowercaseString).rangeOfString("feedsportal").location == NSNotFound) && (imageURL.substringToIndex(4) == "http") {
                                
                                
                                imageSource = imageURL as String
                                break
                            }
                            
                        }
                    }
                }
                
            }
            
            
            if imageSource != "" {
                if cell.viewWithTag(123) == nil {
                    cell.addImage()
                }
            
                println(imageSource)
                cell.thumbnailImage.setImageWithURL(NSURL(string: imageSource), placeholderImage: UIImage(named: "placeholder"))
                
            }else{
                if cell.viewWithTag(123) != nil {
                cell.removeImage()
                }
            }
            cell.accessoryType = .DisclosureIndicator
        
            cell.summaryText.text = item.summary.stringByConvertingHTMLToPlainText()!
   

            let date = NSDateFormatter.localizedStringFromDate(item.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
            cell.sourceAndDateText.text = "\(item.sourceTitle) | \(date)"
            cell.titleText.text = item.title!
            if item.read.boolValue {
                cell.titleText.textColor = UIColor(red:0.788, green:0.783, blue:0.783, alpha:1)
                cell.summaryText.textColor = UIColor(red:0.788, green:0.783, blue:0.783, alpha:1)
                cell.sourceAndDateText.textColor = UIColor(red:0.788, green:0.783, blue:0.783, alpha:1)
            } else {
                cell.titleText.textColor = UIColor.blackColor()
                cell.summaryText.textColor = UIColor.blackColor()
                cell.sourceAndDateText.textColor = UIColor.darkGrayColor()
            }
            
    
            
        }
    }
    
  
    
 
    

    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }

        let managedObjectContext : NSManagedObjectContext = dataHelper.managedObjectContext()
        
   
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sort]
        
        /* NSFetchedResultsController initialization
        a `nil` `sectionNameKeyPath` generates a single section */
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        // perform initial model fetch
        var e: NSError?
        if !self._fetchedResultsController!.performFetch(&e) {
            println("fetch error: \(e!.localizedDescription)")
        }
        
        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController?
    
    
func controllerWillChangeContent(controller: NSFetchedResultsController) {
      self.tableView.beginUpdates()
   }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
        case .Insert:
            if let newIndex = newIndexPath{
                self.tableView.insertRowsAtIndexPaths([newIndex], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Delete:
            if let index = indexPath{
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Update:
            if let index = indexPath{
                self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Move:
            if let index  = indexPath, newIndex = newIndexPath{
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.insertRowsAtIndexPaths([newIndex], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        sideBar.removeSideBar()
    }
    
}
