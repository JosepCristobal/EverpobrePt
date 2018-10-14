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
, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var ExpirationDate: UITextField!
    
    var bottomImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
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
        
        // MARK: DatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        ExpirationDate.inputView = datePicker
        
        // MARK: Constraint by code
        bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: noteTextView, attribute: .bottom, multiplier: 1, constant: -20)
        rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: noteTextView, attribute: .right, multiplier: 1, constant: -20)
        let constArray:[NSLayoutConstraint] = [bottomImgConstraint, rightImgConstraint]
        view.addConstraints(constArray)
        NSLayoutConstraint.deactivate(constArray)
        
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        
        //        let fixSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)  // Ready to use.
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true
        
        //        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(moveImage))
        //
        //        doubleTapGesture.numberOfTapsRequired = 2
        //
        //        imageView.addGestureRecognizer(doubleTapGesture)
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        
    }
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer)
    {
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            
        case .changed:
            let location = longPressGesture.location(in: noteTextView)
            
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            
        case .ended, .cancelled:
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        default:
            break
        }
        
    }
    
    
    @objc func moveImage(tapGesture:UITapGestureRecognizer)
    {
        
        if topImgConstraint.isActive
        {
            if leftImgConstraint.isActive
            {
                leftImgConstraint.isActive = false
                rightImgConstraint.isActive = true
            }
            else
            {
                topImgConstraint.isActive = false
                bottomImgConstraint.isActive = true
            }
        }
        else
        {
            if leftImgConstraint.isActive
            {
                bottomImgConstraint.isActive = false
                topImgConstraint.isActive = true
            }
            else
            {
                rightImgConstraint.isActive = false
                leftImgConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
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
    
    
    override func viewDidLayoutSubviews()
    {
        var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
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
        //selectAddress.delegate = self
        let navController = UINavigationController(rootViewController: selectAddress)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverCont = navController.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(navController, animated: true, completion: nil)
        
    }
    
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
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
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
