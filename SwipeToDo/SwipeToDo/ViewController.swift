//
//  ViewController.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 1/30/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems = [ToDoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Check if toDoItem exists, return if it does
        if toDoItems.count > 0 {
            return
        }
        
        //Create default list items
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
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let item = toDoItems[indexPath.row]
            cell.textLabel?.text = item.textDescription
            return cell
    }

}

