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
    
    var coreDataStack: CoreDataStack!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    let navbarFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? UIFont.systemFontOfSize(17)
    let barFont = UIFont(name: "Avenir", size: 17.0) ?? UIFont.systemFontOfSize(17)
    
    var barShadow: NSShadow = NSShadow()
    
    weak var AddAlertSaveAction: UIAlertAction?
    
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
        
        let moc = coreDataStack.context
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "persistAList")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
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
        
        let alertController = UIAlertController(title: "Add List", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Enter list name"
            textField.returnKeyType = .Done
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainListTableViewController.handleTextFieldTextDidChangeNotification), name: UITextFieldTextDidChangeNotification, object: textField)
        }
        
        func removeTextFieldObserver() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertController.textFields![0])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            print("Cancel Button Pressed")
            removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { action in
            print("Saved")
            
            let nameTextField = alertController.textFields!.first
            
            
            
            let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.coreDataStack.context) as! List
            
            list.name = nameTextField!.text!
           
            self.coreDataStack.saveContext()
            
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
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let moc = coreDataStack.context
        
        if editingStyle == .Delete {
            let managedObject: NSManagedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            moc.deleteObject(managedObject)
            
            coreDataStack.saveContext()
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
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Fetch List
            let list = self.fetchedResultsController.objectAtIndexPath(indexPath) as! List
            
            // Fetch Destination View Controller
            let listViewController = segue.destinationViewController as! ListViewController
            
            // Configure View Controller
            listViewController.coreDataStack = coreDataStack
            listViewController.list = list
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
