//
//  SwiftCoreDataHelper.swift
//


import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    func managedObjectContext()->NSManagedObjectContext{
      
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext : NSManagedObjectContext = appDel.managedObjectContext!
        
        return managedObjectContext

    }
    
    func insertManagedObject(className:NSString, managedObjectContext:NSManagedObjectContext)->AnyObject{
    
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectContext) as NSManagedObject
        
        return managedObject
        
    }
    
    func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext)->Bool{
        if managedObjectContext.save(nil){
            return true
        }else{
            return false
        }
    }

    
    func fetchEntities(className:NSString, withPredicate predicate:NSPredicate?, managedObjectContext:NSManagedObjectContext)->NSArray{
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        let entetyDescription:NSEntityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entetyDescription
        if predicate != nil{
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        let items:NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)!
        
       return items
    }
    
    
}
