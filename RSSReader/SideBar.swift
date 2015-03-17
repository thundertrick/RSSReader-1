//
//  SideBar.swift
//  SideBarControlExample
//


import UIKit


/*
Optional protocol requirements can only be specified if your protocol is marked with the @objc attribute. Even if you are not interoperating with Objective-C, you need to mark your protocols with the @objc attribute if you want to specify optional requirements.

*/

 protocol SideBarDelegate{
    func sideBarDidSelectMenuButtonAtIndex(index:Int)
    func sideBarWillOpen()
    func sideBarWillClose()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate, UIGestureRecognizerDelegate {
   
    var tapGestureRecognizer = UITapGestureRecognizer()
    let barWidth:CGFloat =  200
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    var animator:UIDynamicAnimator!
    let orignView:UIView!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    
    override
    init() {
        super.init()
    }
    
    
    init(sourceView:UIView, menuItems:Array<String>, indexToSelect : Int?){
        super.init()
        orignView = sourceView
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: orignView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        orignView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        // TODO: MAYBE PLACE THAT WITHIN ORIGIN
        orignView.addGestureRecognizer(hideGestureRecognizer)
        
        
        if let index = indexToSelect {
            let indexPath = NSIndexPath(forRow: 0, inSection: index)
            self.sideBarTableViewController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
        
        
    }
    
    
    func tapGestureClose(recognizer: UITapGestureRecognizer) {
        if isSideBarOpen {
            showSideBar(false)
            
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isMemberOfClass(UISwipeGestureRecognizer) {
            return true
            } else {
            if touch.locationInView(sideBarTableViewController.tableView).x > barWidth {
                return true
            } else {
                return false
            }
        }

    }
    
    func setupSideBar(){
        sideBarContainerView.frame = CGRectMake(-barWidth-1, orignView.frame.origin.y, barWidth, orignView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false


        orignView.addSubview(sideBarContainerView)
        
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
        
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer){ 
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
          
        }else{
            showSideBar(true)
           
        }
    }
    
    func showSideBar(shouldOpen:Bool){
       animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        if shouldOpen {
            delegate?.sideBarWillOpen()
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGestureClose:")
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.delegate = self
            orignView.addGestureRecognizer(tapGestureRecognizer)
        } else {
            delegate?.sideBarWillClose()
            orignView.removeGestureRecognizer(tapGestureRecognizer)
        }
        
        let gravityX:CGFloat = (shouldOpen) ? 1.2 : -1.2
        let magnitude:CGFloat = (shouldOpen) ? 50 : -50
        var boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1.0
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryX, 20.0),
            toPoint: CGPointMake(boundaryX, orignView.frame.size.height))
        animator.addBehavior(collisionBehavior)

        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.235
        animator.addBehavior(sideBarBehavior)
        
        
    }
    
    func sideBarControllerDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectMenuButtonAtIndex(indexPath.row)
    }
    
}
