//
//  ModalTableViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 22/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import CoreData

// TODO: - Quedará pendiente implementar el poder cambiar notas de Notebook y controlar duplicados

class ModalTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate{
    var fetchedResultController : NSFetchedResultsController<Notebook>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(backMain))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebook))
        
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        // Indicamos orden.
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDefault, sortByName]
        
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
        let a1 = fetchedResultController.object(at: indexPath).notes!.count
     
        let totNotes: String = ("Total notes: \(String(describing: a1))")
        if fetchedResultController.object(at: indexPath).isDefault == 1 {
            cell?.textLabel?.textColor = .green
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            cell?.imageView?.image = #imageLiteral(resourceName: "isMain.jpeg")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "notas.png")
        }
                cell?.textLabel?.text = fetchedResultController.object(at: indexPath).name
                cell?.detailTextLabel?.text = totNotes
                return cell!
           }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            isMainNote(noteBook: fetchedResultController.object(at: indexPath))
        }
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
            deleteNotebooks(notebooks: fetchedResultController.object(at: indexPath))
            }
        }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    func deleteNotebooks(notebooks: Notebook){
        
        if (notebooks.notes?.count)! > 0 {
            let actionSheetAlert = UIAlertController(title: NSLocalizedString("Existen notas asociadas al Notebook", comment: "Notebook"), message: nil, preferredStyle: .alert)

           let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
            actionSheetAlert.addAction(cancel)

             present(actionSheetAlert, animated: true, completion: nil)
            //alertNotebook()
            
        }else{
            try! DataManager.sharedManager.persistentContainer.viewContext.delete(notebooks)
            try! DataManager.sharedManager.persistentContainer.viewContext.save()
            
        }
    }
    func isMainNote(noteBook: Notebook){
        let obj = fetchedResultController.fetchedObjects
        obj?.forEach({ (Notebok) in
            Notebok.isDefault = 0
        })
        
        noteBook.isDefault = 1
        try! noteBook.managedObjectContext?.save()
        tableView.reloadData()
    }
    
    
    @objc func addNotebook(){
        addNewNoteBook()
    }
    
    @objc func backMain(){
        self.dismiss(animated: true) {
            return
        }
    }
    
    //MARK: - Configuramos la ventana modal para insertar un nuevo notebook
    
    var tField: UITextField!
    
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Nuevo Notebook"
        tField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        //print("Cancelled !!")
    }
    
    func addNewNoteBook(){
        let alert = UIAlertController(title: "Nuevo NoteBook", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
    // Insert a new Notebook
            if (self.tField.text?.isEmpty)!{
                
            }else{
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into:
                DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
            notebook.name = self.tField.text
            notebook.isDefault = 0
                try! DataManager.sharedManager.persistentContainer.viewContext.save()
            }
    }))
        self.present(alert, animated: true, completion: {
            //print("completion block")
    })
        
    }
    
}
