//
//  ListViewController.swift
//  PersistAList
//
//  Created by Kaytee on 4/21/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var dataController = DataController()
    
    var list: List?


    override func viewDidLoad() {
        super.viewDidLoad()
        if let list = list {
            updateViewWithList(list)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateViewWithList(list: List){
        title = list.name
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        // Populate cell from the NSManagedObject instance
        switch (segmentedControl.selectedSegmentIndex) {
            
        case 0:   if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let sortedItems = items.sort { $0.name < $1.name }
            let item = sortedItems[indexPath.row]
            
            cell.textLabel?.text = item.name
            }
            
        case 1:   if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let neededItems = items.filter({$0.isNeeded.boolValue})
            
            if neededItems.count > 0 {
                let sortedNeededItems = neededItems.sort { $0.name < $1.name }
                let item = sortedNeededItems[indexPath.row]
                
                cell.textLabel?.text = item.name
                
            }
            
            break
            }
            
        default: break
            
        }
    

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath)
        
        // Set up the cell
            
            switch (segmentedControl.selectedSegmentIndex) {
                
            case 0:   if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let sortedItems = items.sort { $0.name < $1.name }
                let item = sortedItems[indexPath.row]
                
                cell.textLabel?.text = item.name
                }
                
            case 1:   if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let neededItems = items.filter({$0.isNeeded.boolValue})
                
                if neededItems.count > 0 {
                    let sortedNeededItems = neededItems.sort { $0.name < $1.name }
                    let item = sortedNeededItems[indexPath.row]
                    
                    cell.textLabel?.text = item.name
                }
                
                break
                }
                
            default: break
                
            }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        switch(segmentedControl.selectedSegmentIndex) {
            
        case 0: if let list = list {
            
            numberOfRows =  list.items!.count
            
            }
            
        case 1: if let list = list {
            let neededItems = list.items?.filter({$0.isNeeded.boolValue}) as! [Item]
            numberOfRows = neededItems.count
            }
            
        default: numberOfRows = 0
            
        }
        
        return numberOfRows
        
    }

    @IBAction func segmentedControlTapped(sender: AnyObject) {
        
        tableView.reloadData()
    }

    @IBAction func addItemButtonTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Enter item name"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
            print("Saved")
           
            let nameTextField = alert.textFields!.first
            
            let entityItem = NSEntityDescription.entityForName("Item", inManagedObjectContext: self.dataController.managedObjectContext)
            let newItem = NSManagedObject(entity: entityItem!, insertIntoManagedObjectContext: self.dataController.managedObjectContext) as! Item
            
            newItem.list = self.list!
            newItem.name = (nameTextField?.text)!
            
            
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        
       

    }

}