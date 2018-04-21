//
//  ManagedObject.swift
//  EverpobrePt
//
//  Created by Josep Cristobal on 21/4/18.
//  Copyright © 2018 Josep Cristobal. All rights reserved.
//

import Foundation

extension Note {
    
    override public func setValue(_ value: Any?, forUndefinedKey key: String)
    {
        let keyToIgn = ["date", "content"]
        
        if keyToIgn.contains(key){
            
        }
        else if key == "main_title"
        {
            self.setValue(value, forKey: "title")
        }
        else {
            super.setValue(value, forKey: key)
        }
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == "main_title"
        {
            return "main_title"
        }
        else {
            return super.value(forKey: key)
        }
        
    }
    
}
