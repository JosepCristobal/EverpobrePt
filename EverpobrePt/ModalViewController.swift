//
//  ModalViewController.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 22/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    @IBAction func Close(_ sender: Any) {
        backMain()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(backMain))    }



    @objc func backMain(){
        self.dismiss(animated: true) {
            return
        }
    }




}
