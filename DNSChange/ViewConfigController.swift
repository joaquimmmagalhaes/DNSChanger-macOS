//
//  ViewConfigController.swift
//  DNSChange
//
//  Created by Joaquim Magalhães on 08/08/17.
//  Copyright © 2017 Joaquim Magalhães. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

class ViewConfigController : NSViewController {
    var config_directory : String = ""
    @IBOutlet weak var server_one_name: NSTextField!
    @IBOutlet weak var server_one_ip: NSTextField!
    @IBOutlet weak var server_one_label: NSTextField!
    @IBOutlet weak var server_two_name: NSTextField!
    @IBOutlet weak var server_two_ip: NSTextField!
    @IBOutlet weak var server_two_label: NSTextField!
    @IBOutlet weak var server_three_name: NSTextField!
    @IBOutlet weak var server_three_ip: NSTextField!
    @IBOutlet weak var server_three_label: NSTextField!
    @IBOutlet weak var server_four_name: NSTextField!
    @IBOutlet weak var server_four_ip: NSTextField!
    @IBOutlet weak var server_four_label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_path()
        read_json()
        server_one_name.isEditable = false
        server_one_ip.isEditable = false
        server_two_name.isEditable = false
        server_two_ip.isEditable = false
        server_three_name.isEditable = false
        server_three_ip.isEditable = false
        server_four_name.isEditable = false
        server_four_ip.isEditable = false
    }
    
    func get_path(){
        let (username,_,_) = runCommand("whoami")
        config_directory = "/Users/" + username[0] + "/Documents/DNSChanger"
    }
    @IBAction func exit(_ sender: Any) {
        self.view.window?.close()
    }
    
    func runCommand(_ args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        return (output, error, status)
    }
    
    func read_json() -> Void {
        let data = NSData(contentsOfFile: config_directory + "/Servers.json")
        var json: JSON = []
        if (data?.length == 0){
            json = [
                "Google" : "8.8.8.8",
                "OpenDNS" : "208.67.222.222"
            ]
        }else{
            json = JSON(data as Any)
        }
        var names : Array<String> = []
        for (key,_ ):(String, JSON) in json {
            names.append(key)
        }
        
        if (names.count>=4){
            server_four_ip.stringValue = json[names[3]].stringValue
            server_three_ip.stringValue = json[names[2]].stringValue
            server_two_ip.stringValue = json[names[1]].stringValue
            server_one_ip.stringValue = json[names[0]].stringValue
            server_one_name.stringValue = names[0]
            server_two_name.stringValue = names[1]
            server_three_name.stringValue = names[2]
            server_four_name.stringValue = names[3]
            return;
        }
        else if (names.count == 3){
            server_three_ip.stringValue = json[names[2]].stringValue
            server_two_ip.stringValue = json[names[1]].stringValue
            server_one_ip.stringValue = json[names[0]].stringValue
            server_one_name.stringValue = names[0]
            server_two_name.stringValue = names[1]
            server_three_name.stringValue = names[2]
            server_four_name.isHidden = true
            server_four_ip.isHidden = true
            server_four_label.isHidden = true
            return;
        }
        else if (names.count == 2){
            server_two_ip.stringValue = json[names[1]].stringValue
            server_one_ip.stringValue = json[names[0]].stringValue
            server_one_name.stringValue = names[0]
            server_two_name.stringValue = names[1]
            server_three_name.isHidden = true
            server_three_ip.isHidden = true
            server_three_label.isHidden = true
            server_four_name.isHidden = true
            server_four_ip.isHidden = true
            server_four_label.isHidden = true
        }
        else if (names.count == 1){
            server_one_ip.stringValue = json[names[0]].stringValue
            server_one_name.stringValue = names[0]
            server_two_name.isHidden = true
            server_two_ip.isHidden = true
            server_two_label.isHidden = true
            server_three_name.isHidden = true
            server_three_ip.isHidden = true
            server_three_label.isHidden = true
            server_four_name.isHidden = true
            server_four_ip.isHidden = true
            server_four_label.isHidden = true
            return;
        }
    }
}
