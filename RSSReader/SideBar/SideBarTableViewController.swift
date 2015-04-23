//
//  SideBarTableViewController.swift
//  SideBarControlExample
//


import UIKit

protocol SideBarTableViewControllerDelegate{
    func sideBarControllerDidSelectRow(indexPath:NSIndexPath)
}

class SideBarTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

    var delegate:SideBarTableViewControllerDelegate?
    var feedManager = SaveFeedManager()
    var tableData:[String] = []
    var dataHelper = CoreDataHelper()
    var error = NSErrorPointer()
    var menuItems : [String] {
        get {
            var workingItems : [String] = ["Add Feed", "All", "Unread", "Starred"]
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
           delegate?.sideBarControllerDidSelectRow(NSIndexPath(forRow: 1, inSection: 0))
        } else {
           println(recognizer.state)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell

        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            // Configure the cell...
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.textColor = UIColor.darkTextColor()
            
            let selectedCellView:UIView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            
             selectedCellView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            cell?.selectedBackgroundView = selectedCellView
        }
   

        configureFeedCell(cell!, atIndexPath: indexPath)

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarControllerDidSelectRow(indexPath)
    }
    


    
    func configureFeedCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = menuItems[indexPath.row]
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
    
    

