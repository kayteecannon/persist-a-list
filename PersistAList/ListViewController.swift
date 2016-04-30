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
    
    weak var AddAlertSaveAction: UIAlertAction?


    override func viewDidLoad() {
        super.viewDidLoad()
        if let list = list {
            updateViewWithList(list)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.tintColor = UIColor.blackColor()
        segmentedControl.tintColor = UIColor.palPurpleColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateViewWithList(list: List){
        title = list.name
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
                
                if item.isNeeded.boolValue {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }

            }
                
            case 1:   if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let neededItems = items.filter({$0.isNeeded.boolValue})
                
                if neededItems.count > 0 {
                    let sortedNeededItems = neededItems.sort { $0.name < $1.name }
                    let item = sortedNeededItems[indexPath.row]
                    
                    cell.textLabel?.text = item.name
                    cell.accessoryType = .None
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


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let itemCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            switch (segmentedControl.selectedSegmentIndex) {
                
            case 0:  if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let sortedItems = items.sort { $0.name < $1.name }
                let item = sortedItems[indexPath.row]
                
                if itemCell.accessoryType == .Checkmark {
                    item.isNeeded = false
                    itemCell.accessoryType = .None
                } else {
                     item.isNeeded = true
                    itemCell.accessoryType = .Checkmark
                }
                }
                
                
            case 1:
                if let itemSet = list!.items {
                    let items = Array(itemSet) as! [Item]
                    let neededItems = items.filter({$0.isNeeded.boolValue})
                    
                    if neededItems.count > 0 {
                        let sortedNeededItems = neededItems.sort { $0.name < $1.name }
                        let item = sortedNeededItems[indexPath.row]
                        item.isNeeded = false
                        itemCell.accessoryType = .None
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
                
            default: break
        
        
            }
            
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }

            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    @IBAction func segmentedControlTapped(sender: AnyObject) {
        
        switch(segmentedControl.selectedSegmentIndex) {
            
        case 0: self.navigationController?.navigationBar.barTintColor = UIColor.palPurpleColor()
                segmentedControl.tintColor = UIColor.palPurpleColor()
            
        case 1: self.navigationController?.navigationBar.barTintColor = UIColor.palOrangeColor()
                segmentedControl.tintColor = UIColor.palOrangeColor()

        default: self.navigationController?.navigationBar.barTintColor = UIColor.palPurpleColor()
                 segmentedControl.tintColor = UIColor.palPurpleColor()
            
        }
        
        tableView.reloadData()
    }

    @IBAction func addItemButtonTapped(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add Item", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Enter item name"
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ListViewController.handleTextFieldTextDidChangeNotification), name: UITextFieldTextDidChangeNotification, object: textField)
        }
        
        func removeTextFieldObserver() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertController.textFields![0])
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            print("Cancel Button Pressed")
            removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { action in
            print("Saved")
            
            let nameTextField = alertController.textFields!.first
            
            let entityItem = NSEntityDescription.entityForName("Item", inManagedObjectContext: self.dataController.managedObjectContext)
            let newItem = NSManagedObject(entity: entityItem!, insertIntoManagedObjectContext: self.dataController.managedObjectContext) as! Item
            
            newItem.list = self.list!
            newItem.name = (nameTextField?.text)!
            newItem.isNeeded = true
            
            
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            self.tableView.reloadData()
            removeTextFieldObserver()
        }
        
        // disable the 'save' button (otherAction) initially
        saveAction.enabled = false
        
        // save the other action to toggle the enabled/disabled state when the text changed.
        AddAlertSaveAction = saveAction
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        alertController.view.tintColor = UIColor.palAlertPurpleColor()
    }
    
    //handler
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.enabled = textField.text?.characters.count >= 1
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        switch (segmentedControl.selectedSegmentIndex) {
            
        case 0:  if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let sortedItems = items.sort { $0.name < $1.name }
            let item = sortedItems[indexPath.row]
            
            dataController.managedObjectContext.deleteObject(item)
            
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
            }
        case 1: if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let neededItems = items.filter({$0.isNeeded.boolValue})
            
            if neededItems.count > 0 {
                let sortedNeededItems = neededItems.sort { $0.name < $1.name }
                let item = sortedNeededItems[indexPath.row]
                item.isNeeded = false
                
                do {
                    try self.dataController.managedObjectContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            }
            }
            
        default: break
        

        }
        
        
    }


}