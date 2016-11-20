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
    func toDoItemDeleted(_ todoItem: ToDoItem)
    //Edit process has begun for cell
    func cellDidBeginEditing(_ editingCell: TableViewCell)
    //Edit process has ended for cell
    func cellDidEndEditing(_ editingCell: TableViewCell)
}

class TableViewCell: UITableViewCell, UITextFieldDelegate {

    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var crossLabel: UILabel
    var completeOnDragRelease = false
    var tickLabel: UILabel
    let myGreenColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
    
    //Create strikethrough layer to mark items complete
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    
    //Create cell delegate and todo item as optionals. Will be set in ViewController
    var delegate: TableViewCellDelegate?
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.textDescription
            label.strikeThrough = toDoItem!.isCompleted
            itemCompleteLayer.isHidden = !label.strikeThrough
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        //Initialize strikethrough layer
        label = StrikeThroughText(frame: CGRect.null)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = UIColor.clear
        
        //Utility method for creating contextual cues
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 32.0)
            label.backgroundColor = UIColor.clear
            return label
        }
        
        //Cross and tick labels for contextual cues, using unicode symbols
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .left
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .right
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Set label delegate. This is used to dismiss keyboard on edit.
        label.delegate = self
        label.contentVerticalAlignment = .center
        
        //Add strikethrough and cue layers without default blue highlight
        addSubview(label)
        addSubview(crossLabel)
        addSubview(tickLabel)
        selectionStyle = .none
        
        //Add gradient layer for each cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 0.9, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
    /* Removing colors 2 & 3 makes a more stock looking gradient.
    jThis will need tweaked in either case in the future */
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        //Add green layer for completed items, and hide
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = myGreenColor.cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0)
        
        //Add pan gesture to cell
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    //Define lets for margins and context cues
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0
    let kUICuesWidth: CGFloat = 50.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set layers to fill full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
        //Set cues off screen, cross to to the right and tick to the left
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
    }
    
    // MARK: - Horizontal pan gesture
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        //Gesture began
        if recognizer.state == .began {
            //Record center
            originalCenter = center
        }
        
        //Gesture continues
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            //Check if drag length far enough left to delete
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            //Or far enough right to complete
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            
            //Fade in contextual cues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            crossLabel.alpha = cueAlpha
            tickLabel.alpha = cueAlpha
            //Change cue colors to indicate cell has been pulled far enough
            crossLabel.textColor = deleteOnDragRelease ? UIColor.red : UIColor.white
            tickLabel.textColor = completeOnDragRelease ? myGreenColor : UIColor.white
        }
        
        //Gesture has ended
        if recognizer.state == .ended {
            //Get original frame
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            //Item being deleted
            if deleteOnDragRelease {
                //Insure delegate and toDoItem both exist
                if delegate != nil && toDoItem != nil {
                    //Notify delegate to delete item
                    delegate!.toDoItemDeleted(toDoItem!)
                }
//                print("Delete on release = true")
            //Item being completed
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem!.isCompleted = true
                }
                //Set item as complete and unhide strikethrough
                label.strikeThrough = true
                itemCompleteLayer.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
//                print("Complete on release = true")
            } else {
                //Item not being deleted/completed, snap cell back into original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
//                print("Delete on release = false")
            }
        }
    }
    
    
    //Cancel gesture if vertical (scrolling)
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    // MARK: - UITextFieldDelegate methods
    
    //Close keyboard on enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //Disable edit of completed items
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if toDoItem != nil {
            return !toDoItem!.isCompleted
        }
        return false
    }
    
    //Call delegate cell did begin editing method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate!.cellDidBeginEditing(self)
        }
    }
    
    //Set text once edit has ended
    func textFieldDidEndEditing(_ textField: UITextField) {
        if toDoItem != nil {
            toDoItem!.textDescription = textField.text!
        }
        //Call delegate cell did end editing method
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
    }
}
