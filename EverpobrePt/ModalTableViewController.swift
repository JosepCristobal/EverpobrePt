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
    var notebooks:[Notebook] = []
    
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
        DispatchQueue.main.async {
            self.notebooks = self.fetchedResultController.fetchedObjects!
            self.tableView.reloadData()
        }
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
            cell?.accessoryType = .checkmark
            cell?.imageView?.image = #imageLiteral(resourceName: "isMain.jpeg")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "notas.png")
        }
                cell?.textLabel?.text = fetchedResultController.object(at: indexPath).name
                cell?.detailTextLabel?.text = totNotes
                return cell!
           }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            //isMainNote(noteBook: fetchedResultController.object(at: indexPath))
        }
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
            
            }
        }
    
    // Override to support conditional editing of the table view Si es la principal, no dejamos editarla.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       let notebook = fetchedResultController.object(at: indexPath)
        if notebook.isDefault == 1 {
            return false
            
        }else{
            return true
        }
    }
    //Activamos las opciones de menú para cada row en la tableview Cambio de nombre, hacer por defecto y borrar
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //let notebook = fetchedResultController.object(at: indexPath)
        let changeNameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("ChangeName", comment: "")) { (tableViewRowAction, indexPath) in
            self.changeNoteBook(noteBook: self.fetchedResultController.object(at: indexPath))
        }
        
        let makeAsDefaultAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Make default", comment: "")) { (tableViewAction, indexPath) in
            self.isMainNote(noteBook: self.fetchedResultController.object(at: indexPath))
        }

        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (tableViewAction, indexPath) in
            self.deleteNotebook(self.fetchedResultController.object(at: indexPath))
            //self.deleteNotebooks(notebooks: self.fetchedResultController.object(at: indexPath))
        }
        
        
        return [deleteAction,makeAsDefaultAction,changeNameAction,]
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    //Borrado sencillo de los notebooks
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
    
    //Borrado sofisticado de registros con posibilidad de reubicación
    func deleteNotebook(_ notebook:Notebook)  {
        
        func delete(book:Notebook)
        {
            
            //self.tableView.reloadData()
            DispatchQueue.main.async {
                self.notebooks.remove(at: self.notebooks.index(of: book)!)
                self.tableView.reloadData()
            }
            
            let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
            privateMOC.perform {
                let backNotebook = privateMOC.object(with: (notebook.objectID)) as! Notebook
                backNotebook.removeFromNotes(backNotebook.notes!)
                privateMOC.delete(backNotebook)
                try! privateMOC.save()
            }
            
        }
        let numberOfNotes = notebook.notes?.count ?? 0
        if numberOfNotes == 0 {
            delete(book: notebook)
        }
        else {
            let actionAlertController = UIAlertController(title: NSLocalizedString("Este notebook tiene notas", comment: ""), message: NSLocalizedString("Tu puedes mover todas las notas al Notebook por defecto o puedes borrarlo todo", comment: ""), preferredStyle: .alert)
            
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Mueve las notas antes de borrar", comment: ""), style: .default, handler: { (alertAction) in
                
                let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
                
                var currentDefault = self.notebooks.first
                let obj = self.notebooks
                obj.forEach({ (Notebok) in
                    if Notebok.isDefault == 1
                    { currentDefault = Notebok}
                })
                
                
                
                privateMOC.perform {
                    let backNotebook = privateMOC.object(with: notebook.objectID) as! Notebook
                    let backCurrentDefault = privateMOC.object(with: (currentDefault!.objectID)) as! Notebook
                   
                    backCurrentDefault.addToNotes(backNotebook.notes!)
                    backNotebook.removeFromNotes(backNotebook.notes!)
                    
                    
                    try! privateMOC.save()
                    
                    delete(book: notebook)
                }
                
            }))
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Delete All", comment: ""), style: .default, handler: { (alertAction) in
                delete(book: notebook)
            }))
            actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            self.present(actionAlertController, animated: true, completion: nil)
            
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
    
    func changeNoteBook(noteBook: Notebook){
        let alert = UIAlertController(title: "Cambio de nombre NoteBook", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            // Change Notebook
            if (self.tField.text?.isEmpty)!{
                
            }else{
                noteBook.name = self.tField.text
                try! noteBook.managedObjectContext?.save()
                //try! DataManager.sharedManager.persistentContainer.viewContext.save()
            }
        }))
        self.present(alert, animated: true, completion: {
            //print("completion block")
        })
        
    }
    
}
