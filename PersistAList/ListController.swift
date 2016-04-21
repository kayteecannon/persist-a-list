//
//  ListController.swift
//  PersistAList
//
//  Created by Kaytee on 4/21/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import Foundation
//
//  ListController.swift
//  MainFeaturePersistAList
//
//  Created by Kaytee on 4/14/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import Foundation
import CoreData

class ListController {
    
    static let sharedController = ListController()
    
    let dataController = DataController()
    
    let managedObjectContext: NSManagedObjectContext
    
    func saveToPersistentStorage() {
        let moc = dataController.managedObjectContext
        do {
            try moc.save()
        } catch {
            print("Error saving Managed Object Context. Items not saved.")
        }
    }
    
    func addList(list: List) {
        
        let _ = 
    }
    
    
    
    
}