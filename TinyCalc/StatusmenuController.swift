//
//  StatusmenuController.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/21/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa

class StatusmenuController: NSObject {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let popover = NSPopover()
    
    override func awakeFromNib() {
        
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        
        if let button = statusItem.button {
            button.appearsDisabled = false
            button.image = icon
            button.action = #selector(togglePopover(sender:))
            button.target = self
        }
        
        let controller = CalcViewController(nibName: "CalcViewController", bundle: nil)
        
        controller?.popover = popover
        
        popover.contentViewController = controller
        
    }
    
    func togglePopover(sender: AnyObject){
        if(popover.isShown){
            popover.performClose(sender)
        }else{
            if let button = statusItem.button {
                NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
