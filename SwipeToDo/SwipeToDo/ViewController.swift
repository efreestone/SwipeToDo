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
        toDoItems.append(ToDoItem(textDesc: "feed the cat"))
        toDoItems.append(ToDoItem(textDesc: "buy eggs"))
        toDoItems.append(ToDoItem(textDesc: "watch WWDC videos"))
        toDoItems.append(ToDoItem(textDesc: "rule the Web"))
        toDoItems.append(ToDoItem(textDesc: "buy a new iPhone"))
        toDoItems.append(ToDoItem(textDesc: "darn holes in socks"))
        toDoItems.append(ToDoItem(textDesc: "write this tutorial"))
        toDoItems.append(ToDoItem(textDesc: "master Swift"))
        toDoItems.append(ToDoItem(textDesc: "learn to draw"))
        toDoItems.append(ToDoItem(textDesc: "get more exercise"))
        toDoItems.append(ToDoItem(textDesc: "catch up with Mom"))
        toDoItems.append(ToDoItem(textDesc: "get a hair cut"))
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
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            let item = toDoItems[indexPath.row]
            cell.textLabel?.text = item.textDescription
        
            cell.delegate = self
            cell.toDoItem = item
            return cell
    }
    
    // MARK: - Tableview delegate
    
    func toDoItemDeleted(toDoItem: ToDoItem) {
        let index = (toDoItems as NSArray).indexOfObject(toDoItem)
        if index == NSNotFound {
            return
        }
        
        //Remove item
        toDoItems.removeAtIndex(index)
        
        //Use tableview animation to remove item
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = toDoItems.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    
    

}

