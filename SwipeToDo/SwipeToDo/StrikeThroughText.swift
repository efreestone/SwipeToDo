//
//  StrikeThroughText.swift
//  SwipeToDo
//
//  Created by Elijah Freestone on 9/12/16.
//  Copyright © 2016 Elijah Freestone. All rights reserved.
//

import UIKit
import QuartzCore

//UITextField subclass with optional strikethrough
class StrikeThroughText: UITextField {
    let strikeThroughLayer: CALayer
    
    //Hide or show strikethrough layer
    var strikeThrough : Bool {
        didSet {
            strikeThroughLayer.isHidden = !strikeThrough
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
        strikeThroughLayer.backgroundColor = UIColor.white.cgColor
        strikeThroughLayer.isHidden = true
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
        if let text = text {
            let textSize = text.size(attributes: [NSFontAttributeName:font!])
            strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2, width: textSize.width, height: kStrikeThroughThickness)
        }
    }

}
