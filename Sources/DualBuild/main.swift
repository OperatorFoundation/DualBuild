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
    @Option(name: .short, help: "optional Github url to install on remote server")
    var install: String?
    @Option(name: .short, help: "path to the project directory on the remote server, EXCLUDING PROJECT NAME(defaults to ~)")
    var path: String?
    @Flag(help: "include if you wish to use xcodebuild in favor of swift build")
    var xcode = false
    @Flag(help: "include if you wish to build using the Go programming language")
    var go = false
    @Flag(help: "include to set the current settings as the default settings")
    var setDefault = false
    
    mutating func run() throws
    {
        // makes sure you dont set an empty default
        if setDefault && serverIP == nil {
            print("🛑 error: must at least specify --serverIP to set settings as default 🛑")
            return
        }
        
        // sets current settings as default if --setDefault is set
        if setDefault && serverIP != nil {
            print("setting current settings as default")
            setDefaultSettings(serverIP: serverIP!, path: path, xcode: xcode, go: go)
        }
        
        // if no flags are specified, loads default settings if available
        if serverIP == nil && path == nil && !xcode && !go {
            print("checking for default settings")
            (self.serverIP, self.path, self.xcode, self.go) = loadDefaultSettings()
        }

        // returns if both --xcode and --go are set
        if xcode && go {
            print("🛑 error: --xcode and --go cannot be used simultaneously 🛑")
            return
        }
        
        let dualBuildController = DualBuildController(serverIP: serverIP!)
        
        // if -i is set, installs provided url on the remote server
        if install != nil {
            print("\n\n🛠 Installing on remote server 🛠\n\n")
            dualBuildController.remoteInstall(url: install!, path: path)
        }
        
        // if neither --xcode nor --go are set, uses swift build
        if !xcode && !go {
            print("\n\n🛠 Building on MacOS using swift build 🛠\n\n")
            dualBuildController.swiftBuildMacOS()
            
            print("\n\n🛠 Building on Linux using swift build 🛠\n\n")
            dualBuildController.swiftBuildLinux(path: path)
            
            print("\n\n🎉 Finished building on both platforms 🎉\n\n")
        }
        
        // if --xcode is set, uses xcodebuild
        if xcode {
            print("\n\n🛠 Building on MacOS using xcodebuild 🛠\n\n")
            dualBuildController.xcodeBuildMacOS()
            
            print("\n\n🛠 Building on Linux using xcodebuild 🛠\n\n")
            dualBuildController.xcodeBuildLinux(path: path)
            
            print("\n\n🎉 Finished building on both platforms 🎉\n\n")
        }
        
        // if --go is set, uses go build
        if go {
            print("\n\n🛠 Building on MacOS using go build 🛠\n\n")
            dualBuildController.goBuildMacOS()
            
            print("\n\n🛠 Building on Linux using go build 🛠\n\n")
            dualBuildController.goBuildLinux(path: path)
            
            print("\n\n🎉 Finished building on both platforms 🎉\n\n")
        }
    }
}

DualBuild.main()
