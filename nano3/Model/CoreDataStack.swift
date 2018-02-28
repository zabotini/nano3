//
//  CoreDataStack.swift
//  nano3
//
//  Created by Rafael Zabotini on 12/02/18.
//  Copyright © 2018 Rafael Zabotini. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "TasksDataModel")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
