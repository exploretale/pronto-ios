//
//  UIView+Designable.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit

@IBDesignable
extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var shadow: Bool {
        set {
            if shadow {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.1
                layer.shadowOffset = CGSize(width: 0, height: 1)
                layer.shadowRadius = 2
                layer.masksToBounds = false
            }
        }
        get {
            return layer.shadowColor != nil
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }

}
