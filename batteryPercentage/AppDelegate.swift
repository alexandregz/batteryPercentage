//
//  AppDelegate.swift
//  batteryPercentage
//
//  Created by Alexandre Espinosa Menor on 25/07/15.
//  Copyright (c) 2015 Mara Xiana inc. All rights reserved.
//

// TODO: create lib IOKit/BNBMouseDevice
// TODO: galician language/others?


import Cocoa
import SwiftShell

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!

    
    let SECONDS_TO_REFRESH:UInt16 = 300
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    var timer: dispatch_source_t!
    
    
    func startTimer() {
        let queue = dispatch_queue_create("com.domain.app.timer", nil)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, SECONDS_TO_REFRESH.toUIntMax() * NSEC_PER_SEC, 1 * NSEC_PER_SEC)
        dispatch_source_set_event_handler(timer) {
            self.showPercentage()
        }
        dispatch_resume(timer)
    }
    
    
    func stopTimer() {
        dispatch_source_cancel(timer)
        timer = nil
    }
    
    
    func showPercentage() {
        
        let mouseBattPerc = getMousePercentage()
        let keyboardBattPerc = getKeyboardPercentage()
        
        var output = ""
        if mouseBattPerc.isEmpty == false {
            output = " Mouse Battery: "+mouseBattPerc+"%"
        }
        
        if keyboardBattPerc.isEmpty == false {
            output = output + " Keyboard Battery: "+keyboardBattPerc+"%"
        }
        
        if output.isEmpty {
            output = "Without Mouse Battery/Bluetooth Keyboard?"
        }
        
        statusItem.title = output
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        statusItem.title = "loading..."
        statusItem.menu = statusMenu
        
        self.startTimer()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    /*
    Returns Magic Mouse battery percentage (only checked with this one)
    
    :returns: string with percentage
    */
    func getMousePercentage() -> String {
        
        // ripped from https://github.com/dmuth/splunk-osx-magic-mouse-battery
        let ioregBatteryPerc = run("ioreg -n BNBMouseDevice | fgrep BatteryPercent |fgrep -v { | sed 's/[^[:digit:]]//g'").read().trim()
        
        return ioregBatteryPerc
    }
    
    /*
    Returns Magic Mouse battery percentage (only checked with this one)
    
    :returns: string with percentage
    */
    func getKeyboardPercentage() -> String {
        
        // ripped from https://gist.github.com/dgeske/1756022 and modified
        let ioregKeyboardPerc = run("ioreg -c AppleBluetoothHIDKeyboard | grep BatteryPercent | fgrep -v { | sed 's/[^[:digit:]]//g'").read().trim()
        
        return ioregKeyboardPerc
    }
}

