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
    var isImportant: Bool
    
    //Initialize ToDoItem and set default values
    init(textDescription: String, isCompleted: Bool = false, isImportant: Bool = false) {
        self.textDescription = textDescription
        self.isCompleted = isCompleted
        self.isImportant = isImportant
        
    }

}
