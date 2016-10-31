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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set tableview data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Set tableview style
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.blackColor()
        tableView.rowHeight = 50.0
        
        //Check if toDoItem exists, return if it does
        if toDoItems.count > 0 {
            return
        }
        
        //Create default list items for testing
        toDoItems.append(ToDoItem(textDescription: "feed the cat"))
        toDoItems.append(ToDoItem(textDescription: "buy eggs"))
        toDoItems.append(ToDoItem(textDescription: "watch WWDC videos"))
        toDoItems.append(ToDoItem(textDescription: "rule the Web"))
        toDoItems.append(ToDoItem(textDescription: "buy a new iPhone"))
        toDoItems.append(ToDoItem(textDescription: "darn holes in socks"))
        toDoItems.append(ToDoItem(textDescription: "write this tutorial"))
        toDoItems.append(ToDoItem(textDescription: "master Swift"))
        toDoItems.append(ToDoItem(textDescription: "learn to draw"))
        toDoItems.append(ToDoItem(textDescription: "get more exercise"))
        toDoItems.append(ToDoItem(textDescription: "catch up with Mom"))
        toDoItems.append(ToDoItem(textDescription: "get a hair cut"))
    }
    
    // MARK: - Tableview data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    //Cell for row at index path
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
            cell.selectionStyle = .None
            //Set background to clear
            //cell.textLabel?.backgroundColor = UIColor.clearColor()
            let item = toDoItems[indexPath.row]
            //Cell text is set in didSet on TableViewCell
            //cell.textLabel?.text = item.textDescription
        
            cell.delegate = self
            cell.toDoItem = item
            return cell
    }
    
    // MARK: - TableViewCellDelegate (add, edit and delete items)
    
    //Add item, triggered from scrollViewDidEndDragging
    func toDoItemAdded() {
        //Create and add blank item
        let newToDoItem = ToDoItem(textDescription: "")
        toDoItems.insert(newToDoItem, atIndex: 0)
        tableView.reloadData()
        //Enter edit mode to fill in item
        var newEditCell: TableViewCell
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            if (cell.toDoItem === newToDoItem) {
                newEditCell = cell
                newEditCell.label.becomeFirstResponder()
                break
            }
        }
    }
    
    //Edit started, animate cell to top with animation and lower alpha of all other cells
    func cellDidBeginEditing(editingCell: TableViewCell) {
        let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            UIView.animateWithDuration(0.3, animations: {() in
                cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
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
    func cellDidEndEditing(editingCell: TableViewCell) {
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell: TableViewCell in visibleCells {
            UIView.animateWithDuration(0.5, animations: {() in
                cell.transform = CGAffineTransformIdentity
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
    }
    
    //Delete item
    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        
        if index == NSNotFound {
            return
        }
        
        //Remove item
        toDoItems.removeAtIndex(index)
        
        //Loop through visible cells to animate delete
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        var delay = 0.0
        var startAnimating = false
        var cellNum = 0
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if startAnimating {
                UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut,
                    animations: {() in
                        //Slide individual cell up
                        cell.frame = CGRectOffset(cell.frame, 0.0, -cell.frame.size.height)
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
                cell.hidden = true
            }
            //print("Delay = \(delay) on cell \(cellNum) after startAnimation")
        }
        
        //Use tableview animation to remove item
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    // MARK: - UIScrollViewDelegate
    
    //Create placeholder for cell being added
    let placeHolderCell = TableViewCell(style: .Default, reuseIdentifier: "cell")
    //Create bool for pulldown in progress
    var pullDownInProgress = false
    
    //Scroll or drag beigns. Check location and start insert process if pulling from top
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //Set bool true if drag in progress is starting from top of list
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        placeHolderCell.backgroundColor = UIColor.redColor()
        if pullDownInProgress {
            //Insert placeholder cell at top
            tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
    }
    
    //Scroll took place. Add placeholder cell if from top
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        
        if pullDownInProgress && scrollViewContentOffsetY <= 0.0 {
            //Maintain placeholder cell location
            placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight, width: tableView.frame.size.width, height: tableView.rowHeight)
            //Set placeholder text with ternary based on Y offset
            placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ? "Release to add item" : "Pull to add item"
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
        } else {
            pullDownInProgress = false
        }
    }
    
    //Scroll or drag ended. Check distance and add new item if far enough
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Check if user dragged far enough to add cell
        if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
            //Add new blank cell and trigger edit mode
            toDoItemAdded()
            print("add triggered")
        }
        //Set pull bool to false and remove placeholder cell
        pullDownInProgress = false
        placeHolderCell.removeFromSuperview()
    }
    
    // MARK: - TableViewDelegate
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
}

