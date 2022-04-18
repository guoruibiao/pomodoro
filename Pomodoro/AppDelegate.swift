//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Apostolos Papadopoulos on 4/13/18.
//  MIT, 2018 Apostolos Papadopoulos.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
                                NSUserNotificationCenterDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(
        withLength:NSStatusItem.squareLength)

    var count = 1500
    var countBreak = 300
    var counterLock = false
    var breakLock = false
    var timer = Timer()
    var timerBreak = Timer()

    let menu = NSMenu()
    
    // 弹强提醒框
    let alerter = NSAlert()
    
    // 开启专注任务时，弹出提醒，尽量集中注意力，不中断
    var needShowTip = true;

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "开始专注",
                                action: #selector(AppDelegate.update(_:)),
                                keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "开始休息",
                                action: #selector(AppDelegate.updateBreak(_:)),
                                keyEquivalent: "b"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出应用",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    @objc func update(_ sender: Any?) {
        if counterLock == false {
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(runTimedCode),
                                         userInfo: nil,
                                         repeats: true)
            counterLock = true
            renameTaskItem(item_name_old: "开始专注",
                           item_name_new: "结束专注",
                           key_name: "t",
                           item_position: 0)
            
            
            // 每次只在开启任务时，弹一次提醒
            if needShowTip == true {
                alerter.messageText = "本轮专注任务已开启!";
                alerter.informativeText = "尽量在该番茄时钟内完成任务，不要中断它！！！";
                alerter.runModal();
                needShowTip = false;
            }
        } else {
            reset()
            renameTaskItem(item_name_old: "结束专注",
                           item_name_new: "开始专注",
                           key_name: "t",
                           item_position: 0)
        }
    }

    @objc func updateBreak(_ sender: Any?) {
        if breakLock == false {
            timerBreak = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(runBreakCode),
                                              userInfo: nil,
                                              repeats: true)
            breakLock = true
            renameBreakItem(item_name_old: "开始休息",
                            item_name_new: "结束休息",
                            key_name: "b",
                            item_position: 1)
        } else {
            reset()
            renameBreakItem(item_name_old: "结束休息",
                            item_name_new: "开始休息",
                            key_name: "b",
                            item_position: 1)
        }
    }

    func renameTaskItem(item_name_old: String,
                        item_name_new: String,
                        key_name: String,
                        item_position: Int) {
        menu.removeItem(menu.item(withTitle: item_name_old)!)
        menu.insertItem(withTitle: item_name_new,
                        action: #selector(AppDelegate.update(_:)),
                        keyEquivalent: key_name,
                        at: item_position)
    }

    func renameBreakItem(item_name_old: String,
                         item_name_new: String,
                         key_name: String,
                         item_position: Int) {
        menu.removeItem(menu.item(withTitle: item_name_old)!)
        menu.insertItem(withTitle: item_name_new,
                        action: #selector(AppDelegate.updateBreak(_:)),
                        keyEquivalent: key_name,
                        at: item_position)
    }

    func reset() {
        timer.invalidate()
        timerBreak.invalidate()
        counterLock = false
        breakLock = false
        needShowTip = false
        
        count = 1500
        countBreak = 300
    }

    @objc func runTimedCode() {
        if (count > 0) {
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            let countDownLabel = minutes + ":" + seconds
            count -= 1
            print(countDownLabel)
        } else {
            showNotification(content: "本轮专注已结束，休息一会吧~")
            reset()
            renameTaskItem(item_name_old: "停止专注",
                           item_name_new: "开启专注",
                           key_name: "t",
                           item_position: 0)
        }
    }

    @objc func runBreakCode() {
        if (countBreak > 0) {
            let minutes = String(countBreak / 60)
            let seconds = String(countBreak % 60)
            let countDownLabel = minutes + ":" + seconds
            countBreak -= 1
            print(countDownLabel)
        } else {
            showNotification(content: "本轮休息已结束，准备下一轮专注吧！")
            reset()
            renameBreakItem(item_name_old: "停止休息",
                            item_name_new: "开始休息",
                            key_name: "b",
                            item_position: 1)
        }
    }

    func showNotification(content: String) -> Void {
        let notification = NSUserNotification()
        let nuuid = UUID().uuidString

        notification.identifier = nuuid
        notification.title = "Pomodoro"
        notification.informativeText = content
        notification.soundName = NSUserNotificationDefaultSoundName

        _ = NSUserNotificationCenter.default.deliver(notification)
        
        // todo delete 添加弹窗提醒
        alerter.messageText = "时间到！！！";
        alerter.informativeText = "可以休息 5 分钟了";
        alerter.runModal();
    }
}

