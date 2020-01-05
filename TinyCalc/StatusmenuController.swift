//
//  StatusmenuController.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/21/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa
import Carbon


class StatusmenuController: NSObject {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let popover = NSPopover()
    
    
    let globalKeycode = UInt16(kVK_Space)
    let globalKeymask: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: NSEvent.ModifierFlags.command.rawValue)
    
    func globalHotkeyHandler(event: NSEvent!) {
        _ = localHotkeyHandler(event: event)
    }
    
    func localHotkeyHandler(event: NSEvent!) -> NSEvent? {
        if event.keyCode == self.globalKeycode && event.modifierFlags.rawValue & self.globalKeymask.rawValue == self.globalKeymask.rawValue {
            togglePopover(sender: self)
            return nil
        }
        return event
    }
    
    
    override func awakeFromNib() {
        
        // Setup Global/Local Hotkey:
        if(AXIsProcessTrusted()){
            
            let opts = NSDictionary(object: kCFBooleanTrue!, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
            
            guard AXIsProcessTrustedWithOptions(opts) == true else { return }
            
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.globalHotkeyHandler)
            NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: self.localHotkeyHandler)
            
        }
        //
        
        
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        
        if let button = statusItem.button {
            button.appearsDisabled = false
            button.image = icon
            button.action = #selector(togglePopover(sender:))
            button.target = self
        }
        
        let controller = CalcViewController(nibName: "CalcViewController", bundle: nil)
        
        controller.popover = popover
        
        popover.contentViewController = controller
        
    }
    
    @objc func togglePopover(sender: AnyObject){
        if(popover.isShown){
            popover.performClose(sender)
        }else{
            if let button = statusItem.button {
                NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
