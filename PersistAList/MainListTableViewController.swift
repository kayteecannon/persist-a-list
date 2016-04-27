//
//  MainListTableViewController.swift
//  PersistAList
//
//  Created by Kaytee on 4/21/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import UIKit
import CoreData

class MainListTableViewController: UITableViewController {
    
    var dataController = DataController()

    
    var fetchedResultsController: NSFetchedResultsController!
    
    let navbarFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? UIFont.systemFontOfSize(17)
    let barFont = UIFont(name: "Avenir", size: 17.0) ?? UIFont.systemFontOfSize(17)
    
    var barShadow: NSShadow = NSShadow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.palPurpleColor()
        
        barShadow.shadowColor = UIColor.blackColor()
        barShadow.shadowOffset = CGSize(width: 0, height: 1)
        
        let navBarAttributes = [NSShadowAttributeName: barShadow, NSFontAttributeName: navbarFont, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.titleTextAttributes = navBarAttributes

        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : barFont
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        

    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "List")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        
        request.sortDescriptors = [nameSort]
        
        let moc = self.dataController.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "persistAList")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let list = fetchedResultsController.objectAtIndexPath(indexPath) as! List
        // Populate cell from the NSManagedObject instance
        cell.textLabel!.text = list.name
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mainListCell", forIndexPath: indexPath) 
        // Set up the cell
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Add List", message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Enter list name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
            print("Saved")
            
            let nameTextField = alert.textFields!.first
            
            let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.dataController.managedObjectContext) as! List
            
            list.name = nameTextField!.text!
           
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }

        }))
        
       
        
        presentViewController(alert, animated: true, completion: nil)
        
        alert.view.tintColor = UIColor.palAlertPurpleColor()
        
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let moc = dataController.managedObjectContext
        
        if editingStyle == .Delete {
            let managedObject: NSManagedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            moc.deleteObject(managedObject)
            
            do {
                try self.dataController.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toListView" {
            
            if let viewController = segue.destinationViewController as? ListViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Fetch Record
                    let list = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                    
                    // Configure View Controller
                    viewController.list = list as? List
                    viewController.dataController.managedObjectContext = dataController.managedObjectContext
                }
            }
        }
        
        
    }
}

extension MainListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    
}
