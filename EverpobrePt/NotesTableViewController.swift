//
//  NotesTableViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 21/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import CoreData

// TODO: - Queda pendiente de limpiar todas las pruebas y poder identificar el Notebook por defecto
// para añadir todas las notas nuevas.
// Crear una nota por defecto la primera vez que utilizamos la app


class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultController : NSFetchedResultsController<Note>!
    var fetchedResultControllerNB : NSFetchedResultsController<Notebook>!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let bt1 = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addNewNotebook))
        
        let bt2 = UIBarButtonItem(title: "Ntbook", style: .plain, target: self, action: #selector(showModal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNoteNew))
        
        navigationItem.leftBarButtonItems = [bt2] //De momento no añadimos el bt1
        
        // Fetch Request Note.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
        // Indicamos orden.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        let sortByNotebook = NSSortDescriptor(key: "notebook.name", ascending: true)
        let sortByNotebookDefault = NSSortDescriptor(key: "notebook.isDefault", ascending: true)
        fetchRequest.sortDescriptors = [sortByNotebookDefault,sortByNotebook,sortByDate,sortByTitle]
        
        // Filtrado.
        //let created24H = Date().timeIntervalSince1970 - 24 * 3600
        //let predicate = NSPredicate(format: "createdAtTI >= %f", created24H)
        //fetchRequest.predicate = predicate
        
        fetchRequest.fetchBatchSize = 25
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
        
        let obj = fetchedResultController.fetchedObjects
        obj?.forEach({ (Note) in
            if Note.notebook == nil
            {
                try! DataManager.sharedManager.persistentContainer.viewContext.delete(Note)
                try! DataManager.sharedManager.persistentContainer.viewContext.save()
            }
        })
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
        
        //addProves(notes: fetchedResultController.object(at: indexPath))
        
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController.sections![section].name
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40  // or whatever
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNotes(notes: fetchedResultController.object(at: indexPath))
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
    @objc func addNewNoteNew()  {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into:
            DataManager.sharedManager.persistentContainer.viewContext) as! Note
        let dict = ["title":"Nueva nota from KVC","createdAtTI":Date().timeIntervalSince1970] as [String : Any]

        note.setValuesForKeys(dict)
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
        
        self.addProves(notes: note)
       
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    @objc func addNewNotebook() {
        
//        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into:
//        DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
//        notebook.name = "Nuevo Notebook3"
//        notebook.isDefault = 0
//
//        try! DataManager.sharedManager.persistentContainer.viewContext.save()
        
    }
    func addProves(notes: Note){
        let notebook = loadNoteBookMain()
        //let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into:
           // DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        //notebook.name = "Nuevo Notebook3"
        //notebook.isDefault = 0
        notebook.addToNotes(notes)
        
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
    
    }
    func deleteNotes(notes: Note){
        //let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into:
          //  DataManager.sharedManager.persistentContainer.viewContext) as! Notebook
        
        try! DataManager.sharedManager.persistentContainer.viewContext.delete(notes)
        try! DataManager.sharedManager.persistentContainer.viewContext.save()
    }
    
    @objc func showModal() {
        let modalTableViewController = ModalTableViewController()
        self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        // Cover Vertical is necessary for CurrentContext
        self.modalPresentationStyle = .currentContext
        // Display on top of    current UIView
        self.present(modalTableViewController.wrappedInNavigation(), animated: true, completion: nil)
        
    }
    
    func loadNoteBookMain() -> Notebook{
        // Fetch Request Notebook.
        let viewMOCNB = DataManager.sharedManager.persistentContainer.viewContext
        let fetchRequestNB = NSFetchRequest<Notebook>(entityName: "Notebook")
    
        //Orden obligatorio
        let sortByNotebookDefaultNB = NSSortDescriptor(key: "isDefault", ascending: false)
        fetchRequestNB.sortDescriptors = [sortByNotebookDefaultNB]
        
        // Filtrado.
        let isMainNB = 0
        let predicate = NSPredicate(format: "isDefault != %f", isMainNB)
        fetchRequestNB.predicate = predicate
        
        fetchedResultControllerNB = NSFetchedResultsController(fetchRequest: fetchRequestNB, managedObjectContext: viewMOCNB, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultControllerNB.performFetch()
        let obj = fetchedResultControllerNB.fetchedObjects
        fetchedResultControllerNB.delegate = self
        let nB: Notebook = obj![0]
        return nB
        
       
    }
}
