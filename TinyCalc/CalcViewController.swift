//
//  CalcViewController.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/21/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa

class CalcViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var inputField: NSTextField!
    @IBOutlet weak var answerField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.becomeFirstResponder()
        inputField.delegate = self
        
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        do{
            try answerField.stringValue = Evaluator.evaluate(input: inputField.stringValue)
            answerField.textColor = NSColor.controlTextColor
        }catch{
            answerField.textColor = NSColor.disabledControlTextColor
            // ignore until they press enter
        }
    }
    
    @IBAction func textChanged(_ sender: NSTextField) {
        do{
            try answerField.stringValue = Evaluator.evaluate(input: inputField.stringValue)
        }catch let e as String{
            answerField.stringValue = e
        }catch{
            answerField.stringValue = "Unknown Error"
        }
    }
}
