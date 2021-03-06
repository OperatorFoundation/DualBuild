//
//  File.swift
//  
//
//  Created by Joshua Clark on 11/21/21.
//
import ArgumentParser
import Foundation

import Gardener

struct DualBuild: ParsableCommand
{
    @Argument(help: "IP address for the system to build on.")
    var serverIP: String?
    @Option(name: .short, help: "(Optional) path to the project directory on the remote server, EXCLUDING PROJECT NAME (defaults to ~)")
    var path: String?
    @Flag(name: .short, help: "include if you wish to build using linux only")
    var linux = false
    @Flag(name: .short, help: "include if you wish to build using the Go programming language")
    var go = false
    @Flag(name: .short, help: "include to set the current settings as the default settings. ā ļø Important notice: this will create /DualBuild in ~/Documents and add the file default.json ā ļø")
    var setdefault = false
    
    mutating func run() throws
    {
        // makes sure you dont set an empty default
        if setdefault && serverIP == nil {
            print("š error: must at least specify the remote server IP to set settings as default š")
            return
        }
        
        // sets current settings as default if --setDefault is set
        if setdefault && serverIP != nil {
            print("š  setting current settings as default š ")
            setDefaultSettings(serverIP: serverIP!, path: path, linux: linux, go: go)
        }
        
        // if no flags are specified, loads default settings if available
        if serverIP == nil && path == nil && !linux && !go {
            print("š  checking for default settings š ")
            (self.serverIP, self.path, self.linux, self.go) = loadDefaultSettings()
        }
        
        let dualBuildController = DualBuildController(serverIP: serverIP!)
        
        // ifn--go isn't set, uses swift build
        if !go {
            if !linux {
            print("\n\nš  Building on MacOS using swift build š \n\n")
            dualBuildController.swiftBuildMacOS()
            }
            
            guard let unwrappedServerIP = serverIP else {
                print("Error: Server IP not found")
                return
            }
            
            print("\n\nš  Transferring current directory to linux server š \n\n")
            dualBuildController.linuxTransfer(path: path, serverIP: unwrappedServerIP)
            
            print("\n\nš  Building on Linux using swift build š \n\n")
            dualBuildController.swiftBuildLinux(path: path)
            
            print("\n\nš Finished building on both platforms š\n\n")
        }
        
        // if --go is set, uses go build
        if go {
            if !linux {
            print("\n\nš  Building on MacOS using go build š \n\n")
            dualBuildController.goBuildMacOS()
            }
            
            guard let unwrappedServerIP = serverIP else {
                print("Error: Server IP not found")
                return
            }
            
            print("\n\nš  Transferring current directory to linux server š \n\n")
            dualBuildController.linuxTransfer(path: path, serverIP: unwrappedServerIP)
            
            print("\n\nš  Building on Linux using go build š \n\n")
            dualBuildController.goBuildLinux(path: path)
            
            print("\n\nš Finished building on both platforms š\n\n")
        }
    }
}

DualBuild.main()
