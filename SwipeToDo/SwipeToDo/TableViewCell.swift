//
//  TableViewCell.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 2/11/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Add gradient layer for each cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        //Add pan gesture to cell
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Horizontal pan gesture
    func handlePan(recognizer: UIPanGestureRecognizer) {
        //1
        if recognizer.state == .Began {
            //Gesture began, record center
            originalCenter = center
        }
        
        //2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            //Check if drag length far enough to delete
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
        }
        
        //3
        if recognizer.state == .Ended {
            //Get original frame
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease {
                //Item not being deleted, snap cell back into original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            } else {
                print("Delete on release = true")
            }
        }
    }

}
