//
//  MainListTableViewController.swift
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


class MainListTableViewController: UITableViewController {
    
    var coreDataStack: CoreDataStack!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    let navbarFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22) ?? UIFont.systemFont(ofSize: 17)
    let barFont = UIFont(name: "Avenir", size: 17.0) ?? UIFont.systemFont(ofSize: 17)
    
    var barShadow: NSShadow = NSShadow()
    
    weak var AddAlertSaveAction: UIAlertAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.palPurpleColor()
        
        barShadow.shadowColor = UIColor.black
        barShadow.shadowOffset = CGSize(width: 0, height: 1)
        
        let navBarAttributes = [NSShadowAttributeName: barShadow, NSFontAttributeName: navbarFont, NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.titleTextAttributes = navBarAttributes

        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName : barFont
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: UIControlState())
        

    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
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
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath) as! List
        // Populate cell from the NSManagedObject instance
        cell.textLabel!.text = list.name
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainListCell", for: indexPath) 
        // Set up the cell
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add List", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter list name"
            textField.returnKeyType = .done
            NotificationCenter.default.addObserver(self, selector: #selector(MainListTableViewController.handleTextFieldTextDidChangeNotification), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        }
        
        func removeTextFieldObserver() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields![0])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel Button Pressed")
            removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            print("Saved")
            
            let nameTextField = alertController.textFields!.first
            
            
            
            let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: self.coreDataStack.context) as! List
            
            list.name = nameTextField!.text!
           
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
    func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        AddAlertSaveAction!.isEnabled = textField.text?.characters.count >= 1
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let moc = coreDataStack.context
        
        if editingStyle == .delete {
            let managedObject: NSManagedObject = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            moc.delete(managedObject)
            
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toListView" {
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            // Fetch List
            let list = self.fetchedResultsController.object(at: indexPath) as! List
            
            // Fetch Destination View Controller
            let listViewController = segue.destination as! ListViewController
            
            // Configure View Controller
            listViewController.coreDataStack = coreDataStack
            listViewController.list = list
        }
    }

}

extension MainListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(self.tableView.cellForRow(at: indexPath!)!, indexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    
}
