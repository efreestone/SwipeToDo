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
    var textDescription: String
    var isCompleted: Bool
    
    //Initialize ToDoItem and set default values
    init(textDescription: String) {
        self.textDescription = textDescription
        self.isCompleted = false
        
    }

}
