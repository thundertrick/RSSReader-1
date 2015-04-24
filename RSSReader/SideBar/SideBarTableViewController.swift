//
//  SideBarTableViewController.swift
//  SideBarControlExample
//


import UIKit

class SideBarTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

    var feedManager = SaveFeedManager()
    var tableData:[String] = []
    var dataHelper = CoreDataHelper()
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
        let lprg = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lprg.minimumPressDuration = 2.0
        lprg.delegate = self
        self.tableView.addGestureRecognizer(lprg)
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addFeed")
        navigationItem.rightBarButtonItem = plusButton
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.title = "Lightread"
       
    }
    func addFeed() {
        var nav = self.slideMenuController()?.mainViewController as! UINavigationController
        var vc = nav.viewControllers[0] as! MainTableViewController
       vc.addFeed()
        self.slideMenuController()?.closeLeft()
        
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        let p : CGPoint = recognizer.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        println("\(indexPath?.row), \(indexPath?.section)")
        if (indexPath == nil) {
            return
        } else if indexPath!.row < 4 {
            return
        } else if (recognizer.state == UIGestureRecognizerState.Began) {
            feedManager.deleteFeedAtIndexPath(indexPath!)
            tableView(self.tableView, heightForRowAtIndexPath:NSIndexPath(forRow: 1, inSection: 0))
        } else {
           println(recognizer.state)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell

        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            // Configure the cell...
            cell?.backgroundColor = UIColor.whiteColor()
            cell?.textLabel?.font = UIFont.italicSystemFontOfSize(18)
            cell?.textLabel?.textColor = UIColor(red: 0.89, green: 0.506, blue: 0.384, alpha: 1)
            let selectedCellView:UIView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
        
        }
   

        configureFeedCell(cell!, atIndexPath: indexPath)

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var nav = self.slideMenuController()?.mainViewController as! UINavigationController
        var vc = nav.viewControllers[0] as! MainTableViewController
        vc.sideBarDidSelectMenuButtonAtIndex(indexPath.row)
        self.slideMenuController()?.closeLeft()
    }
    


    
    func configureFeedCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = menuItems[indexPath.row]
        
            if indexPath.row > 2 {
            cell.textLabel?.font = UIFont.italicSystemFontOfSize(18)
            } else {
            cell.textLabel?.font = UIFont.systemFontOfSize(18)
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
    
    

