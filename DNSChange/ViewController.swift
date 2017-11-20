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
    @IBOutlet weak var adapter_menu: NSPopUpButton!
    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    var adapter : String = "Wi-Fi"
    var server_one_ip : String = ""
    var server_two_ip : String = ""
    var server_three_ip : String = ""
    var server_four_ip : String = ""
    var config_directory : String = ""
    
    @IBAction func adapter_choosen(_ sender: Any) {
        adapter = adapter_menu.titleOfSelectedItem ?? "Wi-Fi"
    }
    @IBOutlet weak var aaa: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start_setup()
        current_dns()
        read_json()
        get_adapter()
    }
    
    @IBAction func reload_button(_ sender: Any) {
        server_four.isTransparent = false
        server_three.isTransparent = false
        server_two.isTransparent = false
        server_one.isTransparent = false
        current_dns()
        read_json()
    }
    
    func get_adapter(){
        let (adapters_list , _, _) = runCommand("networksetup", "listallnetworkservices")
        var count : Int = 0
        
        if (adapters_list.contains("Wi-Fi")){
            adapter_menu.addItem(withTitle: "Wi-Fi")
            count += 1
        }
        if (adapters_list.contains("Ethernet")){
            adapter_menu.addItem(withTitle: "Ethernet")
            count += 1
        }
        if (count == 2){
            adapter_menu.addItem(withTitle: "Both")
        }
        
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
        change_dns(server_ip: server_one_ip)
    }
    
    @IBAction func change_to_server_two(_ sender: Any) {
        change_dns(server_ip: server_two_ip)
    }

    @IBAction func change_to_server_three(_ sender: Any) {
        change_dns(server_ip: server_three_ip)
    }
    
    @IBAction func change_to_server_four(_ sender: Any) {
        change_dns(server_ip: server_four_ip)
    }
    
    @IBAction func reset_dns(_ sender: Any) {
        if (adapter == "Wi-Fi"){
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", "Empty")
        }else if (adapter == "Ethernet"){
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Ethernet", "Empty")
        }else{
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", "Empty")
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Ethernet", "Empty")
        }
        current_dns()
    }
    
    
    func change_dns(server_ip : String){
        if (adapter == "Wi-Fi"){
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_ip)
        }else if (adapter == "Ethernet"){
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Ethernet", server_ip)
        }else{
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Wi-Fi", server_ip)
            (_, _, _) = runCommand("networksetup", "-setdnsservers", "Ethernet", server_ip)
        }
        (_, _, _) = runCommand("killall", "-HUP", "mDNSResponder");
        current_dns()
    }
    
    func current_dns() -> Void {
        var (output, _, _) = runCommand("networksetup", "-getdnsservers", "Wi-Fi" )
        
        var dns_servers : String = "Wi-Fi\n"
        for dns in output{
            dns_servers = dns_servers + dns + "\n";
        }
        
        (output, _, _) = runCommand("networksetup", "-getdnsservers", "Ethernet")
        
        if (output[0] != "Ethernet is not a recognized network service."){
            
            dns_servers = dns_servers + "Ethernet\n"
            for dns in output{
                dns_servers = dns_servers + dns + "\n";
            }
        }
        
        dns_servers_field.stringValue = dns_servers
    }
}

