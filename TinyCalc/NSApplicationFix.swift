//
//  NSApplicationFix.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/22/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa

class NSApplicationFix: NSApplication {

    override func sendEvent(_ event: NSEvent) {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.contains(NSEvent.ModifierFlags.command) ){
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if sendAction(#selector(NSText.cut(_:)), to: nil, from: self){ return }
                case "c":
                    if sendAction(#selector(NSText.copy(_:)), to: nil, from: self){ return }
                case "v":
                    if sendAction(#selector(NSText.paste(_:)), to: nil, from: self){ return }
                case "a":
                    if sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self){ return }
                case "z":
                    if sendAction(Selector(("undo:")), to: nil, from: self){ return }
                default:
                    break
                }
                    
            }else if (event.modifierFlags.contains(NSEvent.ModifierFlags.command) && event.modifierFlags.contains(NSEvent.ModifierFlags.shift)){
                switch event.charactersIgnoringModifiers! {
                case "z":
                    if sendAction(Selector(("redo:")), to: nil, from: self){ return }
                default:
                    break
                }
            }
        }
        super.sendEvent(event)
    }
    
    
}
