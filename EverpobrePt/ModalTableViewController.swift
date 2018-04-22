//
//  ModalTableViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 22/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import CoreData


class ModalTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    var fetchedResultController : NSFetchedResultsController<Notebook>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(backMain))
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        // Indicamos orden.
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDefault, sortByName]
        
        let mainItem = 1
        let predicate = NSPredicate(format: "isDefault == \(mainItem)")
        
        fetchRequest.predicate = predicate
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
    }



    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = fetchedResultController.sections![0].numberOfObjects
        return numRows
       
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
              if cell == nil {
                   cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
                }
        let totNotes: String = ("Total notes\(String(describing: fetchedResultController.object(at: indexPath).notes?.count))")
                cell?.textLabel?.text = fetchedResultController.object(at: indexPath).name
                cell?.detailTextLabel?.text = totNotes
        print (fetchedResultController.object(at: indexPath).isDefault)
              return cell!
           }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          // let noteViewController = NoteViewController()
    //        noteViewController.note = fetchedResultController.object(at: indexPath)
    //        addProves(notes: fetchedResultController.object(at: indexPath))
   //        navigationController?.pushViewController(noteViewController, animated: true)
            print ("Seleccionado")
        }
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
            deleteNotebooks(notebooks: fetchedResultController.object(at: indexPath))
                print ("Delete")
            } else if editingStyle == .insert {
               // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
           }
        }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    func deleteNotebooks(notebooks: Notebook){
        //let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into:
        //  DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        if (notebooks.notes?.count)! > 0 {
            let actionSheetAlert = UIAlertController(title: NSLocalizedString("Existen notas asociadas al Notebook", comment: "Notebook"), message: nil, preferredStyle: .alert)
           
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
            actionSheetAlert.addAction(cancel)
            
             present(actionSheetAlert, animated: true, completion: nil)
            
        }else{
            try! DataManager.sharedManager.persistentContainer.viewContext.delete(notebooks)
            try! DataManager.sharedManager.persistentContainer.viewContext.save()
            
        }
    }
    
    @objc func backMain(){
        self.dismiss(animated: true) {
            return
        }
    }
}
