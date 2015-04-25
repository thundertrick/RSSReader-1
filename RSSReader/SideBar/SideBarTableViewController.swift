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
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.boldFontWithSize(17)]
        
         self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
        self.navigationController?.toolbar.tintColor = UIColor.whiteColor()
        
        var gearButton = UIBarButtonItem(image: UIImage(named: "gear"), style: UIBarButtonItemStyle.Plain, target: self, action: "openSettings")
        
        var flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [flexibleSpace, gearButton]
        
        var nav = self.slideMenuController()?.mainViewController as! UINavigationController
        vc = nav.viewControllers[0] as! MainTableViewController
        
        self.title = "Lightread"
     
       
    }
    
    // settings button pressed
    func openSettings() {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settings = storyboard.instantiateViewControllerWithIdentifier("SettingsController") as! UINavigationController
        self.navigationController!.presentViewController(settings, animated: true, completion: nil)
        
    }
    
    func addFeed() {
       vc.addFeed()
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        let p : CGPoint = recognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        println("\(indexPath?.row), \(indexPath?.section)")
        if (indexPath == nil) {
            return
        } else if indexPath!.row < 3 {
            return
        } else if (recognizer.state == UIGestureRecognizerState.Began) {
            feedManager.deleteFeedAtIndexPath(indexPath!)
           
            vc.selectCorrect()
        } else {
           println(recognizer.state)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell

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
        let sort = NSSortDescriptor(key: "dateAdded", ascending: true)
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

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
    }
    
    
    
   
    }
    
    

