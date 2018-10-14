//
//  MapViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 13/10/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import CoreLocation
import Contacts




protocol MapDelegate
{
    func address(_ address:String, lat:Double, lon:Double)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var MKMapView: MKMapView!
    @IBOutlet weak var label: UILabel!
   
    
    var delegate: MapDelegate?
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.rightBarButtonItem = cancelBarButton
        
        title = NSLocalizedString("Center in Map", comment: "Select in Map title")
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmAddress))
        navigationItem.leftBarButtonItem = saveButton
        
        let selectImage = UIImageView.init(image: #imageLiteral(resourceName: "mapSelect"))
        view.addSubview(selectImage)
        
        MKMapView.delegate = self
        
    }

    // MARK: - Map view
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        let centerCoordinate = mapView.centerCoordinate
        let currentMapLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(currentMapLocation) { (placeMarkArray, error) in
            
            if placeMarkArray != nil && placeMarkArray!.count > 0 {
                
                let placeMark = placeMarkArray?.first
                
                DispatchQueue.main.async
                    {
                        
                        if let postalAddres = placeMark?.postalAddress
                        {
                            self.label.text = "\(postalAddres.street) \(postalAddres.city)"
                            self.location = placeMark?.location
                        }
                }
            }
        }
    }

    
    @objc func cancel()  {
        
        dismiss(animated: false, completion: nil)
    }
    
    @objc func confirmAddress() {
        
        if let loc = location
        {
            
            if self.delegate != nil
            {
                self.delegate?.address(self.label.text!, lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
                
            }
            dismiss(animated: false, completion: nil)
        }
    }
    
    
}
