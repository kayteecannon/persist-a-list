//
//  ListViewController.swift
//  PersistAList
//
//  Created by Kaytee on 4/21/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var coreDataStack: CoreDataStack!
    var list: List?
    
    weak var AddAlertSaveAction: UIAlertAction?


    override func viewDidLoad() {
        super.viewDidLoad()
        if let list = list {
            updateViewWithList(list)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.tintColor = UIColor.black
        segmentedControl.tintColor = UIColor.palPurpleColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateViewWithList(_ list: List){
        title = list.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        // Set up the cell
            
            switch (segmentedControl.selectedSegmentIndex) {
                
            case 0:   if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let sortedItems = items.sorted { $0.name < $1.name }
                let item = sortedItems[indexPath.row]
                
                cell.textLabel?.text = item.name
                
                if item.isNeeded.boolValue {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }

            }
                
            case 1:   if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let neededItems = items.filter({$0.isNeeded.boolValue})
                
                if neededItems.count > 0 {
                    let sortedNeededItems = neededItems.sorted { $0.name < $1.name }
                    let item = sortedNeededItems[indexPath.row]
                    
                    cell.textLabel?.text = item.name
                    cell.accessoryType = .none
                }
                
                break
                }
                
            default: break
                
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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


    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if let itemCell = tableView.cellForRow(at: indexPath) {
            
            switch (segmentedControl.selectedSegmentIndex) {
                
            case 0:  if let itemSet = list!.items {
                let items = Array(itemSet) as! [Item]
                let sortedItems = items.sorted { $0.name < $1.name }
                let item = sortedItems[indexPath.row]
                
                if itemCell.accessoryType == .checkmark {
                    item.isNeeded = false
                    itemCell.accessoryType = .none
                } else {
                     item.isNeeded = true
                    itemCell.accessoryType = .checkmark
                }
                }
                
                
            case 1:
                if let itemSet = list!.items {
                    let items = Array(itemSet) as! [Item]
                    let neededItems = items.filter({$0.isNeeded.boolValue})
                    
                    if neededItems.count > 0 {
                        let sortedNeededItems = neededItems.sorted { $0.name < $1.name }
                        let item = sortedNeededItems[indexPath.row]
                        item.isNeeded = false
                        itemCell.accessoryType = .none
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
                
            default: break
        
        
            }
            
            coreDataStack.saveContext()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    @IBAction func segmentedControlTapped(_ sender: AnyObject) {
        
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

    @IBAction func addItemButtonTapped(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter item name"
            textField.returnKeyType = .done
            NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        
        func removeTextFieldObserver() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields![0])
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel Button Pressed")
            removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            print("Saved")
            
            let nameTextField = alertController.textFields!.first
            
            let entityItem = NSEntityDescription.entity(forEntityName: "Item", in: self.coreDataStack.context)
            let newItem = NSManagedObject(entity: entityItem!, insertInto: self.coreDataStack.context)
                as! Item
            
            newItem.list = self.list!
            newItem.name = (nameTextField?.text)!
            newItem.isNeeded = true
            
            
            self.coreDataStack.saveContext()
            
            self.tableView.reloadData()
            removeTextFieldObserver()
        }
        
        // disable the 'save' button (otherAction) initially
        saveAction.isEnabled = false
        
        // save the other action to toggle the enabled/disabled state when the text changed.
        AddAlertSaveAction = saveAction
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        
        alertController.view.tintColor = UIColor.palAlertPurpleColor()
    }
    
    //handler
    @objc func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.isEnabled = textField.text?.count >= 1
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        switch (segmentedControl.selectedSegmentIndex) {
            
        case 0:  if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let sortedItems = items.sorted { $0.name < $1.name }
            let item = sortedItems[indexPath.row]
            
            coreDataStack.context.delete(item)
            
            coreDataStack.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        
            }
        case 1: if let itemSet = list!.items {
            let items = Array(itemSet) as! [Item]
            let neededItems = items.filter({$0.isNeeded.boolValue})
            
            if neededItems.count > 0 {
                let sortedNeededItems = neededItems.sorted { $0.name < $1.name }
                let item = sortedNeededItems[indexPath.row]
                item.isNeeded = false
                
                coreDataStack.saveContext()
                
                tableView.deleteRows(at: [indexPath], with: .fade)

            }
            }
            
        default: break
        

        }
        
        
    }


}
