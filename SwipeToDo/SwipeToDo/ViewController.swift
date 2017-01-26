//
//  ViewController.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 1/30/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems = [ToDoItem]()
    let pinchRecognizer = UIPinchGestureRecognizer()
    let longPressRecognizer = UILongPressGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set gesture recognizers and add to tableview
        pinchRecognizer.addTarget(self, action: #selector(ViewController.handlePinch(_:)))
        tableView.addGestureRecognizer(pinchRecognizer)
//        longPressRecognizer.addTarget(self, action: #selector(ViewController.handleLongPress(_:)))
//        longPressRecognizer.minimumPressDuration = 1.0
//        longPressRecognizer.delegate = self
//        tableView.addGestureRecognizer(longPressRecognizer)
        
        //Set tableview data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Set tableview style
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.black
        tableView.rowHeight = 50.0
        
        //Check if toDoItem exists, return if it does
        if toDoItems.count > 0 {
            return
        }
        
        //Create default list items for testing
        toDoItems.append(ToDoItem(textDescription: "↓ Pull down to add new todo item"))
        toDoItems.append(ToDoItem(textDescription: "Tap to edit me"))
        toDoItems.append(ToDoItem(textDescription: "← Swipe left to delete me"))
        toDoItems.append(ToDoItem(textDescription: "→ Swipe right to mark me complete"))
        toDoItems.append(ToDoItem(textDescription: "↑ Pinch me from my neighbor to add"))
        toDoItems.append(ToDoItem(textDescription: "↓ Pinch me from my neighbor to add"))
        toDoItems.append(ToDoItem(textDescription: "Long press and drag to move me"))
    }
    
    // MARK: - Tableview data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    //Cell for row at index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            cell.selectionStyle = .none
            //Set background to clear
            //cell.textLabel?.backgroundColor = UIColor.clearColor()
            let item = toDoItems[(indexPath as NSIndexPath).row]
            //Cell text is set in didSet on TableViewCell
            //cell.textLabel?.text = item.textDescription
        
            cell.delegate = self
            cell.toDoItem = item
            return cell
    }
    
    // MARK: - TableViewCellDelegate (add, edit and delete items)
    
    //Add item, triggered from scrollViewDidEndDragging
//    func toDoItemAdded() {
//        toDoItemAddedAtIndex(0)
//    }
    
    func toDoItemAddedAtIndex(_ index: Int) {
        print("todo item added at index \(index)")
        //Create and add blank item
        let newToDoItem = ToDoItem(textDescription: "", isCompleted: false, isImportant: false)
        toDoItems.insert(newToDoItem, at: index)
        tableView.reloadData()
        //Enter edit mode to fill in item
        editInProgress = true
        var newEditCell: TableViewCell
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            if (cell.toDoItem === newToDoItem) {
                newEditCell = cell
                newEditCell.label.becomeFirstResponder()
                print("First Responder")
                break
            }
        }
    }
    
    //Edit started, animate cell to top with animation and lower alpha of all other cells
    func cellDidBeginEditing(_ editingCell: TableViewCell) {
        print("cellDidBeginEditing")
        editInProgress = true
        let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: {() in
                cell.transform = CGAffineTransform(translationX: 0, y: editingOffset)
                //Change alpha for all cells that are not the actual cell being edited using Identity Operator.
                //Multiple instances of editingCell could potentially exist
                if cell !== editingCell {
                    //Lower alpha of other cells to highlight editing cell
                    cell.alpha = 0.3
                }
            })
        }
    }
    
    //Edit ended, animate cells back into place and return alpha of other cells to normal
    func cellDidEndEditing(_ editingCell: TableViewCell) {
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell: TableViewCell in visibleCells {
            UIView.animate(withDuration: 0.5, animations: {() in
                cell.transform = CGAffineTransform.identity
                if cell !== editingCell {
                    //Return non-edited cell alphas back to 1
                    cell.alpha = 1.0
                }
            })
        }
        //Check if textField is blank
        if editingCell.toDoItem!.textDescription == "" {
            toDoItemDeleted(editingCell.toDoItem!)
        }
        editInProgress = false
        tableView.reloadData()
    }
    
    //Delete item
    func toDoItemDeleted(_ toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).index(of: toDoItem)
        
        if index == NSNotFound {
            return
        }
        
        //Remove item
        toDoItems.remove(at: index)
        
        //Loop through visible cells to animate delete
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        var delay = 0.0
        var startAnimating = false
        var cellNum = 0
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if startAnimating {
                UIView.animate(withDuration: 0.3, delay: delay, options: UIViewAnimationOptions(),
                    animations: {() in
                        //Slide individual cell up
                        cell.frame = cell.frame.offsetBy(dx: 0.0, dy: -cell.frame.size.height)
                    },
                    completion: {(finished: Bool) in
                        if (cell == lastView) {
                            //Reload data after animation, insures tableview has accurate info on cell locations
                            self.tableView.reloadData()
                        }
                    }
                )
                //Adjust delay so animation cascades, otherwise only first cell animates before the rest catch up
                delay += 0.035
                
                cellNum += 1
//                print("Delay = \(delay) on cell \(cellNum)")
            }
            //Insure cell is todo item. Moved to be hit after first iteration to avoid jerky animation start
            if cell.toDoItem == toDoItem {
                startAnimating = true
                //Hide cell to avoid ghosting over animated cells
                cell.isHidden = true
            }
//            print("Delay = \(delay) on cell \(cellNum) after startAnimation")
        }
        
        //Use tableview animation to remove item
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
    }
    
    // MARK: - pinch-to-add methods
    
    struct TouchPoints {
        var upper: CGPoint
        var lower: CGPoint
    }
    
    var upperCellIndex = -100
    var lowerCellIndex = -100
    //Create instance of TouchPoints struct
    var initialTouchPoints: TouchPoints!
    //Create bools for pinch
    var pinchExceededRequiredDistance = false
    var pinchInProgress = false
    
    //Handle pinch based on state
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            pinchStarted(recognizer)
        }
        
        if recognizer.state == .changed && pinchInProgress && recognizer.numberOfTouches == 2 {
            pinchChanged(recognizer)
        }
        
        if recognizer.state == .ended {
            pinchEnded(recognizer)
        }
    }
    
    //Pinch started
    func pinchStarted(_ recognizer: UIPinchGestureRecognizer) {
//        print("Pinch started")
        //Get initial touch points, with top and bottom properly IDed
        initialTouchPoints = getNormalizedTouchPoints(recognizer)
        
        upperCellIndex = -100
        lowerCellIndex = -100
        //Locate touched cells
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if viewContainsPoints(cell, point: initialTouchPoints.upper) {
                upperCellIndex = i
                //Highlight cell - FOR DEBUGGING
//                cell.backgroundColor = UIColor.purpleColor()
            }
            if viewContainsPoints(cell, point: initialTouchPoints.lower) {
                lowerCellIndex = i
                //Highlight cell - FOR DEBUGGING
//                cell.backgroundColor = UIColor.purpleColor()
            }
        }
        
        //Make sure cells are neighboring, start pinch if they are
        if abs(upperCellIndex - lowerCellIndex) == 1 {
            //Initiate pinch and add placeholder cell
            pinchInProgress = true
            let precedingCell = visibleCells[upperCellIndex]
            placeHolderCell.frame = precedingCell.frame.offsetBy(dx: 0.00, dy: tableView.rowHeight / 2.0)
            placeHolderCell.backgroundColor = UIColor.red
            tableView.insertSubview(placeHolderCell, at: 0)
            //Set placeholder cell color
            placeHolderCell.backgroundColor = precedingCell.backgroundColor
        }
    }
    
    func pinchChanged(_ recognizer: UIPinchGestureRecognizer) {
        print("Pinch changed")
        //Find current touch points
        let currentTouchPoints = getNormalizedTouchPoints(recognizer)
        
        //Check how much touch points have changed
        let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
        let lowerDelta = initialTouchPoints.lower.y - currentTouchPoints.lower.y
        let delta = -min(0, min(upperDelta, lowerDelta))
        
        //Change offset for cells to part. Negative for cells above, positive for below
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if i <= upperCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: -delta)
            }
            if i >= lowerCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: delta)
            }
        }
        //Scale placeholder to provide a "spring out" effect
        let gapSize = delta * 2
        let cappedGapSize = min(gapSize, tableView.rowHeight)
        placeHolderCell.transform = CGAffineTransform(scaleX: 1.0, y: cappedGapSize / tableView.rowHeight)
        placeHolderCell.label.text = gapSize > tableView.rowHeight ? "Release to add item" : "Pull apart to add item"
        placeHolderCell.alpha = min(1.0, gapSize / tableView.rowHeight)
        
        //Check pinch distance and set bool accordingly
        pinchExceededRequiredDistance = gapSize > tableView.rowHeight
    }
    
    func pinchEnded(_ recognizer: UIPinchGestureRecognizer) {
        pinchInProgress = false
        print("Pinch ended")
        //Remove placeholder cell
        placeHolderCell.transform = CGAffineTransform.identity
        placeHolderCell.removeFromSuperview()
        
        //Check pinch distance
        if pinchExceededRequiredDistance {
            pinchExceededRequiredDistance = false
            print("Pinch far enough")
            
            //Set all cells back to transform identity, removing space from pinch
            let visibleCells = self.tableView.visibleCells as! [TableViewCell]
            for cell in visibleCells {
                cell.transform = CGAffineTransform.identity
                print("CGAffineTransform")
            }
            
            //Add new todo item at index
            let indexOffset = Int(floor(tableView.contentOffset.y / tableView.rowHeight))
            toDoItemAddedAtIndex(lowerCellIndex + indexOffset)
        } else {
            print("Pinch NOT far enough")
            //Pinch not far enough, animate back
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {() in
                let visibleCells = self.tableView.visibleCells as! [TableViewCell]
                for cell in visibleCells {
                    cell.transform = CGAffineTransform.identity
                }
            }, completion: nil)
        }
    }
    
    //Get both touch points and insure top and bottom are properly identified, return TouchPoints
    func getNormalizedTouchPoints(_ recognizer: UIPinchGestureRecognizer) -> TouchPoints {
        print("Normalized touch points")
        var pointOne = recognizer.location(ofTouch: 0, in: tableView)
        var pointTwo = recognizer.location(ofTouch: 1, in: tableView)
        //Check that pointOne is top-most touch, swap if not
        if pointOne.y > pointTwo.y {
            let tempPoint = pointOne
            pointOne = pointTwo
            pointTwo = tempPoint
        }
        //Return touches and TouchPoints
        return TouchPoints(upper: pointOne, lower: pointTwo)
    }
    
    //Make sure point actually exists in the view. Cells are full width, so only checking y axis
    func viewContainsPoints(_ view: UIView, point: CGPoint) -> Bool {
        let frame = view.frame
        return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
    }
    
    // MARK: - Long Press Gesture 
    
//    func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
//        print("handleLongPress")
//        
//        //let longPress = recognizer
//        let state = recognizer.state
//        var longPressLocation = recognizer.location(in: tableView)
//        var indexPath = tableView.indexPathForRow(at: longPressLocation)
//        
////        let visibleCells = tableView.visibleCells as! [TableViewCell]
////        for i in 0..<visibleCells.count {
////            let cell = visibleCells[i]
////            print("cell = \(cell)")
////        }
//        
//        struct My {
//            static var cellSnapshot: UIView? = nil
//        }
//        struct Path {
//            static var initialIndexPath: NSIndexPath? = nil
//        }
//        
//        if recognizer.state == .began {
//            let touchPoint = recognizer.location(in: self.view)
//            if let index = indexPath {
//                print("Index = \(index.row)")
//                
//            }
//            //pinchStarted(recognizer)
////            if indexPath != nil {
////                print("Long Press Index Path = \(indexPath)")
////                Path.initialIndexPath = indexPath as NSIndexPath?
////                let cell = tableView.cellForRow(at: indexPath!)
////            }
//            print("Long Press BEGAN")
//        }
//        
//        if recognizer.state == .changed { //&& pinchInProgress && recognizer.numberOfTouches == 2
//            //pinchChanged(recognizer)
//            print("Long Press CHANGED")
//        }
//        
//        if recognizer.state == .ended {
//            //pinchEnded(recognizer)
//            print("Long Press ENDED")
//        }
//    }
    
    // MARK: - UIScrollViewDelegate
    
    //Create placeholder for cell being added
    let placeHolderCell = TableViewCell(style: .default, reuseIdentifier: "cell")
    //Create bools for pulldown ad edit in progress
    var pullDownInProgress = false
    var editInProgress = false
    
    //Scroll or drag beigns. Check location and start insert process if pulling from top
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //Set bool true if drag in progress is starting from top of list
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        placeHolderCell.backgroundColor = UIColor.red
        if pullDownInProgress && !editInProgress {
            //Insert placeholder cell at top
            tableView.insertSubview(placeHolderCell, at: 0)
        } else {
//            print("Edit is in progress")
        }
    }
    
    //Scroll took place. Add placeholder cell if from top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        
        if (pullDownInProgress && !editInProgress) && scrollViewContentOffsetY <= 0.0 {
            //Maintain placeholder cell location
            placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight, width: tableView.frame.size.width, height: tableView.rowHeight)
            //Set placeholder text with ternary based on Y offset
            placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ? "Release to add item" : "Pull to add item"
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
        } else {
            pullDownInProgress = false
//            print("scrollViewDidScroll ELSE, trigger reload")
            //pullDownInProgress = scrollViewContentOffsetY <= 0.0 ? true : false
        }
    }
    
    //Scroll or drag ended. Check distance and add new item if far enough
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Check if user dragged far enough to add cell
        if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
            //Add new blank cell and trigger edit mode
            toDoItemAddedAtIndex(0)
//            print("add triggered")
        }
        //Set pull bool to false and remove placeholder cell
        pullDownInProgress = false
        placeHolderCell.removeFromSuperview()
    }
    
    // MARK: - TableViewDelegate
    
    func colorForIndex(_ index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex((indexPath as NSIndexPath).row)
    }
    
}

