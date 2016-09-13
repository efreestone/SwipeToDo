//
//  StrikeThroughText.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 9/12/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit
import QuartzCore

//UILabel subclass with option strikethrough
class StrikeThroughText: UILabel {
    let strikeThroughLayer: CALayer
    
    //Hide or show strikethrough layer
    var strikeThrough : Bool {
        didSet {
            strikeThroughLayer.hidden = !strikeThrough
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    //Init
    override init(frame: CGRect) {
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.whiteColor().CGColor
        strikeThroughLayer.hidden = true
        strikeThrough = false
        
        super.init(frame: frame)
        //Add striketrough layer
        layer.addSublayer(strikeThroughLayer)
    }
    
    //Add strikethrough layer
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeStrikeThrough()
    }
    
    //Set strikethrough thickness
    let kStrikeThroughThickness: CGFloat = 2.0
    
    //Resize strikethrough to fit layer
    func resizeStrikeThrough() {
        let textSize = text!.sizeWithAttributes([NSFontAttributeName:font])
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2, width: textSize.width, height: kStrikeThroughThickness)
    }

}
