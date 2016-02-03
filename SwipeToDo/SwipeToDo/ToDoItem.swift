//
//  ToDoItem.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 2/2/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    //Create initial vars
    var text: String
    var completed: Bool
    
    //Initialize ToDoItem and set default values
    init(text: String) {
        self.text = text
        self.completed = false
        
    }

}
