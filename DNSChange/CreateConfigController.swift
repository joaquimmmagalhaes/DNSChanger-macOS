//
//  CreateConfigController.swift
//  DNSChange
//
//  Created by Joaquim Magalhães on 07/08/17.
//  Copyright © 2017 Joaquim Magalhães. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

class CreateConfigController : NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        start_setup()
    }
    
    @IBOutlet weak var server_one_name: NSTextField!
    @IBOutlet weak var server_one_ip: NSTextField!
    @IBOutlet weak var server_two_name: NSTextField!
    @IBOutlet weak var server_two_ip: NSTextField!
    @IBOutlet weak var server_three_name: NSTextField!
    @IBOutlet weak var server_three_ip: NSTextField!
    @IBOutlet weak var server_four_name: NSTextField!
    @IBOutlet weak var server_four_ip: NSTextField!
    
    var config_directory : String = ""
    
    func start_setup(){
        let (username,_,_) = runCommand("whoami")
        config_directory = "/Users/" + username[0] + "/Documents/DNSChanger"
    }
    
    @IBAction func create_servers_file(_ sender: Any) {
        var serversArray: JSON = []
        if (server_four_name.stringValue != "" && server_four_ip.stringValue != ""){
            if (validateIpAddress(ipToValidate : server_one_ip.stringValue) && validateIpAddress(ipToValidate : server_two_ip.stringValue) && validateIpAddress(ipToValidate : server_three_ip.stringValue) && validateIpAddress(ipToValidate : server_four_ip.stringValue)){
                serversArray = [
                    server_one_name.stringValue : server_one_ip.stringValue,
                    server_two_name.stringValue : server_two_ip.stringValue,
                    server_three_name.stringValue : server_three_ip.stringValue,
                    server_four_name.stringValue : server_four_ip.stringValue
                ]
            }
        }else if (server_three_name.stringValue != "" && server_three_ip.stringValue != "" && server_four_name.stringValue == "" && server_four_ip.stringValue == ""){
            if (validateIpAddress(ipToValidate : server_one_ip.stringValue) && validateIpAddress(ipToValidate : server_two_ip.stringValue) && validateIpAddress(ipToValidate : server_three_ip.stringValue)){
                serversArray = [
                    server_one_name.stringValue : server_one_ip.stringValue,
                    server_two_name.stringValue : server_two_ip.stringValue,
                    server_three_name.stringValue : server_three_ip.stringValue
                ]
            }
        }
        else if (server_two_name.stringValue != "" && server_two_ip.stringValue != "" && server_three_name.stringValue == "" && server_three_ip.stringValue == "" && server_four_name.stringValue == "" && server_four_ip.stringValue == ""){
            if (validateIpAddress(ipToValidate : server_one_ip.stringValue) && validateIpAddress(ipToValidate : server_two_ip.stringValue)){
                serversArray = [
                    server_one_name.stringValue : server_one_ip.stringValue,
                    server_two_name.stringValue : server_two_ip.stringValue
                ]
            }
        }
        else if (server_one_name.stringValue != "" && server_one_ip.stringValue != "" && server_two_name.stringValue == "" && server_two_ip.stringValue == "" && server_three_name.stringValue == "" && server_three_ip.stringValue == "" && server_four_name.stringValue == "" && server_four_ip.stringValue == ""){
            if (validateIpAddress(ipToValidate : server_one_ip.stringValue)){
                serversArray = [
                    server_one_name.stringValue : server_one_ip.stringValue
                ]
            }
        }
        else{
            return;
        }

        (_,_,_) = runCommand("rm",config_directory + "/Servers.json")
        (_,_,_) = runCommand("touch",config_directory + "/Servers.json")
        
        let str = serversArray.description
        let data = str.data(using:String.Encoding.utf8)!
        
        if let file = FileHandle(forWritingAtPath:config_directory + "/Servers.json") {
            file.write(data)
        }
        
        self.view.window?.close()
    }
    
    @IBAction func exit(_ sender: Any) {
        self.view.window?.close()
    }
    
    //function copied from: https://stackoverflow.com/a/37071903
    
    func validateIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            return true
        }
        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        
        return false;
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

    
}
