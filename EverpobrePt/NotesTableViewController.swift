//
//  NotesTableViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 21/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    var fetchedResultController : NSFetchedResultsController<Note>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addNewNotebook))
        
        // Fetch Request.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        
        //        // 1.- Creamos el objeto
        //        let fetchRequest =  NSFetchRequest<Note>()
        //
        //        // 2.- Que entidad es de la que queremos objeto.
        //        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        //   let fetchRequest = Note.fetchNoteRequest()
        
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
        // 3.- (Opcional) Indicamos orden.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        let sortByNotebook = NSSortDescriptor(key: "notebook.name", ascending: true)
        let sortByNotebookDefault = NSSortDescriptor(key: "notebook.isDefault", ascending: true)
        fetchRequest.sortDescriptors = [sortByNotebookDefault,sortByNotebook,sortByDate,sortByTitle]
        
        // 4.- (Opcional) Filtrado.
        let created24H = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAtTI >= %f", created24H)
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchBatchSize = 25
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self

        
    }
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultController.sections![section].numberOfObjects
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        cell?.textLabel?.text = fetchedResultController.object(at: indexPath).title
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteViewController = NoteViewController()
        noteViewController.note = fetchedResultController.object(at: indexPath)
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    @objc func addNewNote()  {
        
        // Grabamos una nota en un hilo de background
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            //Utilizamos KVC
            let dict = ["title":"Nueva nota from KVC","createdAtTI":Date().timeIntervalSince1970] as [String : Any]
            //        note.title = "Nueva nota"
            //        note.createdAtTI = Date().timeIntervalSince1970
            
            note.setValuesForKeys(dict)
        
            try! privateMOC.save()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    @objc func addNewNotebook() {
        
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into:
        DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        notebook.name = "Nuevo Notebook3"
        notebook.isDefault = 0
        
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
        
    }
    func addProves(notes: Note){
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into:
            DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        notebook.name = "Nuevo Notebook Proves"
        notebook.isDefault = 0
        notebook.addToNotes(notes)
        
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
    }
    func deleteNotes(notes: Note){
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into:
            DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
    }
}
