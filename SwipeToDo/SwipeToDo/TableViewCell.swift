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
    var completeOnDragRelease = false
    
    //Create strikethrough layer to mark items complete
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    
    //Create cell delegate and todo item as optionals. Will be set in ViewController
    var delegate: TableViewCellDelegate?
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.textDescription
            label.strikeThrough = toDoItem!.isCompleted
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        //Initialize strikethrough layer
        label = StrikeThroughText(frame: CGRect.null)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Add strikethrough layer without default blue highlight
        addSubview(label)
        selectionStyle = .None
        
        //Add gradient layer for each cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        //Add green layer for completed items, and hide
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        //Add pan gesture to cell
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set layers to fill full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
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
            //Check if drag length far enough left to delete
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            //Or far enough right to complete
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
        }
        
        //Gesture has ended
        if recognizer.state == .Ended {
            //Get original frame
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            //Item being deleted
            if deleteOnDragRelease {
                //Insure delegate and toDoItem both exist
                if delegate != nil && toDoItem != nil {
                    //Notify delegate to delete item
                    delegate!.toDoItemDeleted(toDoItem!)
                }
                print("Delete on release = true")
            //Item being completed
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem!.isCompleted = true
                }
                //Set item as complete and unhide strikethrough
                label.strikeThrough = true
                itemCompleteLayer.hidden = false
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
                print("Complete on release = true")
            } else {
                //Item not being deleted/completed, snap cell back into original location
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
                print("Delete on release = false")
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
