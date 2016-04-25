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
        
        if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let sortedItems = items.sort { $0.name < $1.name }
            let item = sortedItems[indexPath.row]
            
            cell.textLabel?.text = item.name

        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath)
        
        // Set up the cell
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = list {
            return list.items!.count
        }
        else {
            return 0
        }
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