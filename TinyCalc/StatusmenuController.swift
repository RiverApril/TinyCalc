//
//  StatusmenuController.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/21/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa

class StatusmenuController: NSObject {
    
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let popover = NSPopover()
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    func togglePopover(sender: AnyObject){
        if(popover.isShown){
            popover.performClose(sender)
        }else{
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    override func awakeFromNib() {
        
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        //statusItem.image = icon
        //statusItem.menu = statusMenu
        
        if let button = statusItem.button {
            button.appearsDisabled = false
            button.image = icon
            button.action = #selector(togglePopover(sender:))
            button.target = self
        }
        
        popover.contentViewController = CalcViewController(nibName: "CalcViewController", bundle: nil)
        
    }

}
