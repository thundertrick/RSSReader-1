//
//  SideBarTableViewController.swift
//  SideBarControlExample
//


import UIKit

class SideBarTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

    var feedManager = SaveFeedManager()
    var tableData:[String] = []
    var dataHelper = CoreDataHelper()
    var vc : MainTableViewController!
    var error = NSErrorPointer()
    var userDriveModelChange = false
    var menuItems : [String] {
        get {
            var workingItems : [String] = ["All", "Unread", "Starred"]
            let feedItems = fetchedResultsController.fetchedObjects as! [Feed]
            if feedItems.count > 0 {
                for feedItem in feedItems {
                    workingItems.append(feedItem.name)
                }
            }
            return workingItems
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return menuItems.count
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        let lprg = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lprg.minimumPressDuration = 2.0
        lprg.delegate = self
        self.tableView.addGestureRecognizer(lprg)
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addFeed")
        navigationItem.rightBarButtonItem = plusButton
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.boldFontWithSize(17)]
        
         self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
        self.navigationController?.toolbar.tintColor = UIColor.whiteColor()
        
        let gearButton = UIBarButtonItem(image: UIImage(named: "gear"), style: UIBarButtonItemStyle.Plain, target: self, action: "openSettings")
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [flexibleSpace, gearButton]
        
        let nav = self.slideMenuController()?.mainViewController as! UINavigationController
        vc = nav.viewControllers[0] as! MainTableViewController
        
        self.title = "Lightread"
        self.tableView.scrollsToTop = false
     
       
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


       
    }
    // settings button pressed
    func openSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settings = storyboard.instantiateViewControllerWithIdentifier("SettingsController") as! UINavigationController
        self.navigationController!.presentViewController(settings, animated: true, completion: nil)
        
    }
    
    func addFeed() {
       vc.addFeed()
      
    }
    
    func deleteFeed(object: Feed) {
           print(" and here")
        feedManager.deleteFeed(object, moc: self.fetchedResultsController.managedObjectContext)
           print("and and here")
        vc.selectCorrect()
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        let p : CGPoint = recognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        print("\(indexPath?.row), \(indexPath?.section)")
        if (indexPath == nil) {
            return
        } else if indexPath!.row < 3 {
            return
        } else if (recognizer.state == UIGestureRecognizerState.Began) {
            self.deleteFeed(self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: indexPath!.row - 3, inSection: indexPath!.section)) as! Feed)
            print("here")
            if tableView.numberOfRowsInSection(0) < 4 {
                self.setEditing(false, animated: true)
            }
            
        } else {
           print(recognizer.state)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") 

        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            // Configure the cell...
            cell?.textLabel?.textColor = UIColor.grayColor()
            let selectedCellView:UIView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedCellView.backgroundColor = UIColor(red:1, green:0.938, blue:0.919, alpha:1)
            cell?.selectedBackgroundView = selectedCellView
            
        
        }
   

        configureFeedCell(cell!, atIndexPath: indexPath)

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        vc.sideBarDidSelectMenuButtonAtIndex(indexPath.row)
        self.slideMenuController()?.closeLeft()
    }
    


    
    func configureFeedCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = menuItems[indexPath.row]
        
            if indexPath.row > 2 {
            cell.textLabel?.font = UIFont.italicFontWithSize(18)
            } else {
            cell.textLabel?.font = UIFont.fontWithSize(18)
            }
    }
    
    // Core Data fetched results source
    
    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext : NSManagedObjectContext = dataHelper.managedObjectContext()
        
        
        let entity = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "orderValue", ascending: true)
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
        do {
            try self._fetchedResultsController!.performFetch()
        } catch let error as NSError {
            e = error
            print("fetch error: \(e!.localizedDescription)")
        }
        
        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController?


    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if userDriveModelChange {
            return
        }
        let selectedCell = self.tableView.indexPathForSelectedRow
        
        dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
        })
        
        self.tableView.selectRowAtIndexPath(selectedCell, animated: false, scrollPosition: .None)
  
    }
    
    
    
    
    
    // MARK: - Editing
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        vc.slideMenuController()?.leftPanGesture!.enabled = !editing
        if editing == false {
            vc.sideBarDidSelectMenuButtonAtIndex(vc.currentView)
        }
    }
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        if indexPath.row > 2 {
            return true
        }
        
        return false
    }

    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
 
        self.deleteFeed(self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: indexPath.row - 3, inSection: indexPath.section)) as! Feed)
        print("here")
        if tableView.numberOfRowsInSection(0) < 4 {
            self.setEditing(false, animated: true)
        }
        
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
   
    
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        userDriveModelChange = true
     let originPath = NSIndexPath(forRow: fromIndexPath.row - 3, inSection: fromIndexPath.section)
        let newPath = NSIndexPath(forRow: toIndexPath.row - 3, inSection: toIndexPath.section)
       
        var items = self.fetchedResultsController.fetchedObjects as! [Feed]
        
        let itemToMove = self.fetchedResultsController.objectAtIndexPath(originPath) as! Feed
        
        items.removeAtIndex(originPath.row)
        
        items.insert(itemToMove, atIndex: newPath.row)
        
        for (index, value) in items.enumerate() {
            value.orderValue = index
            
        }
        dataHelper.saveManagedObjectContext(self.fetchedResultsController.managedObjectContext)
        
      userDriveModelChange = false
        
    }

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     
        if indexPath.row > 2 {
            return true
        }
        
        return false

    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row < 3{
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
   
}


