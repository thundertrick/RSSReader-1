//
//  MainTableViewController.swift
//  RSSReader
//
//  Created by The Hexagon on 01/03/15.
//  Copyright (c) 2015 The Hexagon. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet



var currentArticle : Article? = nil

var shouldScrollToTop = true


class MainTableViewController: UITableViewController, SaveFeedDelegate, UpdateDataManagerDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    

    
    // initialize data helper classs

    var updateDataManager = UpdateDataManager()
    var dataHelper = CoreDataHelper()
    var managedObjectContext: NSManagedObjectContext?
    var currentView = 1
    let error = NSErrorPointer()
    var markReadButton : UIBarButtonItem!
  
  
    var sideVC : SideBarTableViewController!

    
    
    override func viewDidLoad() {
        
       
    
        self.clearsSelectionOnViewWillAppear = true
        let nav = self.slideMenuController()?.leftViewController as! UINavigationController
          sideVC = nav.viewControllers[0] as! SideBarTableViewController
        // register nib for FeedTableViewCell
        var nib = UINib(nibName: "FeedTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FeedCell")

        // customize ui
        markReadButton = UIBarButtonItem(image: UIImage(named: "checkmark"), style: UIBarButtonItemStyle.Plain, target: self, action: "markAllRead")
        self.navigationItem.rightBarButtonItem = markReadButton

        // empty data set
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
    
        self.navigationController?.toolbarHidden = true
    
        
       selectCorrect()
    
    
        // setup refresh classes delegates
        updateDataManager.delegate = self
        
        updateDataManager.update()
        super.viewDidLoad()
       
       
        // clear backButton text
        
        let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        

        // setup nav bar butons
        
        var menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = menuButton
        
      
        
        // setup pull to refresh
        let options = PullToRefreshOption()
        options.backgroundColor = UIColor(red:0.927, green:0.946, blue:0.943, alpha:1)
        options.indicatorColor = UIColor.orangeColor()
        
        self.tableView.addPullToRefresh(options: options, refreshCompletion: { [weak self] in
            self?.updateFromRefreshButton()
            self?.tableView.stopPullToRefresh()
            })
        
        // add double tap gesture recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        self.tableView.addGestureRecognizer(doubleTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        self.tableView.addGestureRecognizer(tapGesture)
        
     
     

    }
    
    func selectCorrect() {
        sideBarDidSelectMenuButtonAtIndex(currentView)
        if self.fetchedResultsController.fetchedObjects?.count < 1 {
            currentView = 0
            sideBarDidSelectMenuButtonAtIndex(currentView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
         self.navigationController?.setToolbarHidden(true, animated: true)
        shouldScrollToTop = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.slideMenuController()?.leftPanGesture?.enabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
   /* deinit {
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
    }

*/
    
    
    
    
    func handleTap(recognizer: UITapGestureRecognizer) {
     
        let p : CGPoint = recognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
    
        if (indexPath == nil) {
            return
       
        } else  {
            
            if recognizer.numberOfTapsRequired == 2 {
          let item = fetchedResultsController.objectAtIndexPath(indexPath!) as! Article
            if item.read == false {
                item.read = true
            } else {
                item.read = false
            }
            dataHelper.saveManagedObjectContext(fetchedResultsController.managedObjectContext)
            } else {
         
               
                
                let item = fetchedResultsController.objectAtIndexPath(indexPath!) as! Article
                currentArticle = item
                item.read = true
                
                dataHelper.saveManagedObjectContext(fetchedResultsController.managedObjectContext)
                
                self.performSegueWithIdentifier("showArticle", sender: self)
            }
        }

    }
    
    // Menu Button functions
    
    // side Bar pressed

    func openMenu() {
        self.slideMenuController()?.openLeft()
      
     
    }
    
 
    // pull to refresh
    func updateFromRefreshButton() {
        updateDataManager.update()
        
    }
    
    func markAllRead() {
        
        let objects = self.fetchedResultsController.fetchedObjects as! [Article]
        var unread = 0
        for object in objects {
            if object.read == false {
                ++unread
            }
        }
        
        if unread > 0 {
            let itemText = (unread == 1) ? "item" : "items"
        
        let alert = UIAlertController(title: "Mark All Read", message: "Do you want to mark \(unread) \(itemText) as read?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action -> Void in
            
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action -> Void in
            let items = self.fetchedResultsController.fetchedObjects as! [Article]
            for item in items {
                if item.read.boolValue == false {
                    item.read = true
                }
            }
            self.dataHelper.saveManagedObjectContext(self.fetchedResultsController.managedObjectContext)

            }))
        
           self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        

        
    }
    
    
  
    
    func addFeed() {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("navAddFeed") as! UINavigationController
        self.navigationController!.presentViewController(vc, animated: true, completion: nil)
            
        self.currentView = 1

    }

    // MARK: - SideBar Delegate
    

    
    // sideBar button selected
    func sideBarDidSelectMenuButtonAtIndex(index: Int) {
        
        NSFetchedResultsController.deleteCacheWithName(self.fetchedResultsController.cacheName)
        NSFetchedResultsController.deleteCacheWithName("Locations")
        NSFetchedResultsController.deleteCacheWithName(nil)
        
        if index == 0 {
            self.title = "All"
            self.fetchedResultsController.fetchRequest.predicate = nil
            self.fetchedResultsController.performFetch(self.error)
            self.tableView.reloadData()
            
          
        } else if index == 1 {
            self.title = "Unread"
    
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "read == %@", false)
            self.fetchedResultsController.performFetch(self.error)
      
            self.tableView.reloadData()
            self.fetchedResultsController.fetchRequest.predicate = nil
            

        } else if index == 2 {
            self.title = "Starred"
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "starred == %@", true)
            self.fetchedResultsController.performFetch(self.error)
            
            self.tableView.reloadData()

        
        
        } else {
            let indexPath = NSIndexPath(forRow: index - 3, inSection: 0)
            var feed = self.sideVC.fetchedResultsController.objectAtIndexPath(indexPath) as! Feed
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "source == %@", feed.link)
            self.fetchedResultsController.performFetch(self.error)
           
            self.tableView.reloadData()
            self.title = feed.name
         
            
            
        }
        self.currentView = index
        if shouldScrollToTop {
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
            
        } else {
            shouldScrollToTop = true
        }
        
        self.sideVC.tableView.selectRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: .None)
        self.tableView.reloadEmptyDataSet()
        
    
    }
  
    
    // MARK: - updateData  Delegate

    func updateDataFailedWithError() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  
        let alert = UIAlertController(title: "Refresh Failed", message: "Refresh of feed items failed. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        println("update Data failed")
        self.sideBarDidSelectMenuButtonAtIndex(currentView)
        
        // write func

    }
   
    
    func updatedData() {
        println("updated data")
     UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        dispatch_async(dispatch_get_main_queue(), {
            self.sideBarDidSelectMenuButtonAtIndex(self.currentView)
        })


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
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.accessoryType = .DisclosureIndicator
    }
    
    
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.slideMenuController()?.isLeftOpen() == true {
            return false
        }
        return true
    }
    
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
        var cell: FeedTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as? FeedTableViewCell
        if cell != nil {
            configureCell(cell!, atIndexPath: indexPath)
          
            return cell!
        } else {
            var nib = UINib(nibName: "FeedTableViewCell", bundle: nil)
            self.tableView.registerNib(nib, forCellReuseIdentifier: "FeedCell")
             var theCell: FeedTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FeedCell") as? FeedTableViewCell
            configureCell(theCell!, atIndexPath: indexPath)
         
            return theCell!
        }
        
   
        
    }
    
    
    func configureCell(cell: FeedTableViewCell, atIndexPath indexPath: NSIndexPath) {
     
        if self.fetchedResultsController.fetchedObjects?.count > indexPath.row {
          
            let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Article
           
            var savePath = ""
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
            
                
                cell.thumbnailImage.image = UIImage(named: "placeholder")
                cell.request?.cancel()
                
                cell.request = Alamofire.request(.GET, imageSource).responseImage() {
                    (request, _, image, error) in
                    if error == nil && image != nil {
                        if cell.viewWithTag(123) == nil {
                            cell.addImage()
                        }
                        
                        cell.thumbnailImage.image = image

                    } else {
                        if cell.viewWithTag(123) != nil {
                            cell.removeImage()
                        }
                    }
                }
                
    
            
               
        
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
        println("called")
        let objects = self.fetchedResultsController.fetchedObjects as! [Article]
        var unread = 0
        for object in objects {
            if object.read == false {
                ++unread
            }
        }
        
        if unread == 0 {
            self.markReadButton.enabled = false
        } else {
            self.markReadButton.enabled = true
        }
        
  


        
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
        self.slideMenuController()?.leftPanGesture?.enabled = false
    }
    
    // MARK: - Empty Data
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Items"
        let attributes = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName : UIFont.boldFontWithSize(18)]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = ""
        
        switch currentView {
        case 0:
            text = "Looks like you haven't added any feeds yet!"
        case 1:
            text = "You've read all articles!"
        case 2:
            text = "Looks like you haven't starred any articles yet. To do so, go to an article and tap the star."
        default:
            text = ":( Looks like we have an error. Please delete this feed and try again."
        }
        
        var paragraph : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName : UIFont.fontWithSize(14), NSParagraphStyleAttributeName : paragraph]
        return NSAttributedString(string: text, attributes: attributes)
        
        
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
         let attributes = [NSForegroundColorAttributeName : UIColor.orangeColor(), NSFontAttributeName : UIFont.boldFontWithSize(18)]
        var text = ""
        switch currentView {
        case 0:
            text = "Add New Feed"
        case 1:
            text = "Add New Feed"
        default:
            text = ""
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        switch currentView {
        case 0:
            self.addFeed()
        case 1:
            self.addFeed()
        default:
            break
        }
    }
    
    
    
}
