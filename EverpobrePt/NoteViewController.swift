//
//  NoteViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 21/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class NoteViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate
, UITextFieldDelegate, UITextViewDelegate, MapDelegate{
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var ExpirationDate: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var topLine: UIView!
    
    var bottomImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    //@IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topImgConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftImgConstraint: NSLayoutConstraint!
    
    let dateFormatter = { () -> DateFormatter in
        let dateF = DateFormatter()
        dateF.dateStyle = .short
        dateF.timeStyle = .none
        return dateF
    }()
    
    var relativePoint: CGPoint!
    var note: Note?
    var pictures: [PhotoNote] = []
    var imageViews: [UIImageView] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        noteTextView.delegate = self
        
        titleTextField.text = note?.title
        noteTextView.text = note?.content
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: (note?.createdAtTI)!))
        if (note?.dateLimit)! > Double(0.0) {
            ExpirationDate.text = dateFormatter.string(from: Date(timeIntervalSince1970: (note?.dateLimit)!))
        } else {
            ExpirationDate.placeholder = NSLocalizedString("Expiration date", comment: "")
        }
        locationLabel.text = note?.nameNb
        pictures = note?.photonote?.sortedArray(using: [NSSortDescriptor(key: "tag", ascending: true)]) as! [PhotoNote]
        
        for picture  in pictures {
            pictures.append(picture)
            addNewImage(UIImage(data: picture.photo!)!, tag: Int(picture.tag), relativeX: picture.x, relativeY: picture.y)
            
        }
        
        // MARK: DatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        ExpirationDate.inputView = datePicker
        
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
    }

    @objc func closeKeyboard()
    {
        
        
        if noteTextView.isFirstResponder
        {
            noteTextView.resignFirstResponder()
        }
        else if titleTextField.isFirstResponder
        {
            titleTextField.resignFirstResponder()
        }
    }
    
    // MARK: Date Picker
    @objc func dateChanged(_ datePicker:UIDatePicker)
    {
        ExpirationDate.text = dateFormatter.string(from: datePicker.date)
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let privateNote = privateMOC.object(with: self.note!.objectID) as! Note
            privateNote.dateLimit = datePicker.date.timeIntervalSince1970
            try! privateMOC.save()
        }
    }
    
    // MARK: Toolbar Buttons actions
    
    @objc func catchPhoto()
    {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add photo", comment: "Add photo"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation(_ barButton:UIBarButtonItem)
    {
        let selectAddress = MapViewController()
        selectAddress.delegate = self
        let navController = UINavigationController(rootViewController: selectAddress)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverCont = navController.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(navController, animated: true, completion: nil)
        
    }
    
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let currentImages = note?.photonote?.count ?? 0
        let tag = currentImages + 1
        
        let xRelative = Double(tag*10) / Double(UIScreen.main.bounds.width)
        let yRelative = Double(tag*10) / Double(UIScreen.main.bounds.height)
        
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
            let picture = NSEntityDescription.insertNewObject(forEntityName: "PhotoNote", into: backMOC) as! PhotoNote
            
            picture.x = xRelative
            picture.y = yRelative
            picture.rotation = 0
            picture.scale = 1
            picture.tag = Int64(tag)
            picture.photo = image.pngData()
            
            picture.notesp = (backMOC.object(with: (self.note?.objectID)!) as! Note)
            
            try! backMOC.save()
            
            DispatchQueue.main.async {
                self.pictures.append(DataManager.sharedManager.persistentContainer.viewContext.object(with: picture.objectID) as! PhotoNote)
                self.addNewImage(image, tag: tag, relativeX: xRelative, relativeY: yRelative)
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    // MARK: TextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        note?.title = textField.text
        try! note?.managedObjectContext?.save()
    }
    
    // MARK: TextView Delegate
    func textViewDidChange(_ textView: UITextView) {
        note?.content = noteTextView.text
        try! note?.managedObjectContext?.save()
    }
    
    // MARK: Select In Map Delegate
    func address(_ address: String, lat: Double, lon: Double) {
        locationLabel.text = address
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
            let backNote = (backMOC.object(with: (self.note?.objectID)!) as! Note)
            backNote.nameNb = address
            backNote.latitude = "\(lat)"
            backNote.longitude = "\(lon)"
            
            try! backMOC.save()
        }
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
