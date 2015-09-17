//
//  SwiftCoreDataHelper.swift
//


import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    func managedObjectContext()->NSManagedObjectContext{
      
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext : NSManagedObjectContext = appDel.managedObjectContext!
        
        return managedObjectContext

    }
    
    func insertManagedObject(className:NSString, managedObjectContext:NSManagedObjectContext)->AnyObject{
    
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className as String, inManagedObjectContext: managedObjectContext) 
        
        return managedObject
        
    }
    
    func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext)->Bool{
        do {
            try managedObjectContext.save()
            return true
        } catch _ {
            return false
        }
    }

    
    func fetchEntities(className:NSString, withPredicate predicate:NSPredicate?, managedObjectContext:NSManagedObjectContext)->NSArray{
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        let entetyDescription:NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entetyDescription
        if predicate != nil{
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        let items:NSArray = try! managedObjectContext.executeFetchRequest(fetchRequest)
        
       return items
    }
    
    
}
