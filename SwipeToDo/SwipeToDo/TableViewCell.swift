//
//  TableViewCell.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 2/11/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit

//Protocol TableViewCell uses to inform delegates of state change
protocol TableViewCellDelegate {
    //Item has been deleted
    func toDoItemDeleted(todoItem: ToDoItem)
}

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
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Horizontal pan gesture
    func handlePan(recognizer: UIPanGestureRecognizer) {
        //Gesture began
        if recognizer.state == .Began {
            //Record center
            originalCenter = center
        }
        
        //Gesture continues
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            //Check if drag length far enough to delete
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
        }
        
        //Gesture has ended
        if recognizer.state == .Ended {
            //Get original frame
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease {
                //Item not being deleted, snap cell back into original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
                print("Delete on release = false")
            } else {
                print("Delete on release = true")
            }
        }
    }
    
    
    //Cancel gesture if verticle (scrolling)
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }

}
