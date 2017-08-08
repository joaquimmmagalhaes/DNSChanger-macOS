//
//  ViewController.swift
//  DNSChange
//
//  Created by Joaquim Magalhães on 05/08/17.
//  Copyright © 2017 Joaquim Magalhães. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

class ViewController: NSViewController {
    @IBOutlet weak var dns_servers_field: NSTextField!
    @IBOutlet weak var server_one: NSButtonCell!
    @IBOutlet weak var server_two: NSButtonCell!
    @IBOutlet weak var server_three: NSButtonCell!
    @IBOutlet weak var server_four: NSButtonCell!
    var server_one_ip : String = ""
    var server_two_ip : String = ""
    var server_three_ip : String = ""
    var server_four_ip : String = ""
    var config_directory : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start_setup()
        current_dns()
        read_json()
    }
    
    @IBAction func reload_button(_ sender: Any) {
        server_four.isTransparent = false
        server_three.isTransparent = false
        server_two.isTransparent = false
        server_one.isTransparent = false
        current_dns()
        read_json()
    }
    func start_setup(){
        let (username,_,_) = runCommand("whoami")
        let config_directory_result = "/Users/" + username[0] + "/Documents/DNSChanger"
        config_directory = config_directory_result
        let config_path = config_directory_result + "/Servers.json"
        var (_,_,result) = runCommand("test","-d",config_directory_result)
        if result == 1 {
            (_,_,_) = runCommand("mkdir",config_directory_result)
            (_,_,_) = runCommand("touch",config_path)
            return
        }
        (_,_,result) = runCommand("test","-d",config_path)
        if result == 1 {
            (_,_,_) = runCommand("touch",config_path)
        }
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
            server_four_ip = json[names[3]].stringValue
            server_three_ip = json[names[2]].stringValue
            server_two_ip = json[names[1]].stringValue
            server_one_ip = json[names[0]].stringValue
            setup_names(server_one_name : names[0], server_two_name : names[1], server_three_name : names[2], server_four_name : names[3])
            return;
        }
        else if (names.count == 3){
            server_three_ip = json[names[2]].stringValue
            server_two_ip = json[names[1]].stringValue
            server_one_ip = json[names[0]].stringValue
            setup_names(server_one_name : names[0], server_two_name : names[1], server_three_name : names[2], server_four_name : "")
            server_four.isTransparent = true
            return;
        }
        else if (names.count == 2){
            server_two_ip = json[names[1]].stringValue
            server_one_ip = json[names[0]].stringValue
            setup_names(server_one_name : names[0], server_two_name : names[1], server_three_name : "", server_four_name : "")
            server_four.isTransparent = true
            server_three.isTransparent = true
            return;
        }
        else if (names.count == 1){
            server_one_ip = json[names[0]].stringValue
            setup_names(server_one_name : names[0], server_two_name : "", server_three_name : "", server_four_name : "")
            server_four.isTransparent = true
            server_three.isTransparent = true
            server_two.isTransparent = true
            return;
        }
        server_four.isTransparent = true
        server_three.isTransparent = true
        server_two.isTransparent = true
        server_one.isTransparent = true
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
    
    func setup_names(server_one_name : String, server_two_name : String, server_three_name : String, server_four_name : String) -> Void {
        server_one.title = server_one_name
        server_two.title = server_two_name
        server_three.title = server_three_name
        server_four.title = server_four_name
    }
    
    @IBAction func change_to_server_one(_ sender: Any) {
        print(server_one_ip)
        (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_one_ip);
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
    }
    
    @IBAction func change_to_server_two(_ sender: Any) {
        (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_two_ip);
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
    }

    @IBAction func change_to_server_three(_ sender: Any) {
        (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_three_ip);
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
    }
    
    @IBAction func change_to_server_four(_ sender: Any) {
        (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_four_ip);
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
    }
    
    
    @IBAction func reset_dns(_ sender: Any) {
        let (output, _, _) = runCommand("route", "-n", "get" ,"default")
        let gateway : String = output[3].replacingOccurrences(of: "    gateway: ", with: "")
        (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", gateway);
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
        
    }
    
    func current_dns() -> Void {
        let (output, _, _) = runCommand("networksetup", "-getdnsservers", "Wi-Fi" )
        
        var dns_servers : String = ""
        for dns in output{
            dns_servers = dns_servers + dns + "\n";
        }
        
        dns_servers_field.stringValue = dns_servers
    }
}
