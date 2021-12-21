//
//  File.swift
//  
//
//  Created by Joshua Clark on 11/22/21.
//

import Foundation
import Gardener

struct defaultSettings: Codable {
    let serverip: String
    let path: String
    let linux: Bool
    let go: Bool
}

func setDefaultSettings(serverIP: String, path: String?, linux: Bool, go: Bool) {
    let command = Command()
    var finalPath: String
    if path != nil {
        finalPath = path!
    } else {
        finalPath = ""
        print("⚠️ path not specified.  Setting default to home directory ⚠️")
    }
    let jsonPath = "file://\(File.homeDirectory().path)/Documents/DualBuild/default.json"
    guard let jsonURL = URL(string: jsonPath) else {
        print("🛑 Error: could not convert DualBuild path to string 🛑")
        return
    }
    let jsonString = "{\n\"serverip\": \"\(serverIP)\",\n\"path\": \"\(finalPath)\",\n\"linux\": \(linux),\n\"go\": \(go)\n}"
    if !File.exists("file://\(jsonPath)") {
        print("creating default.json in ~/Documents/DualBuild/")
        command.run("mkdir", "\(File.homeDirectory().path)/Documents/DualBuild")
        command.run("touch", "file://\(jsonPath)")
    }
    do {
            try jsonString.write(to: jsonURL,
                                 atomically: true,
                                 encoding: .utf8)
        } catch {
            print(error)
        }
}

func loadDefaultSettings() -> (String?, String?, Bool, Bool){
    var jsonData: Data?
    var decodedJsonData: defaultSettings?
    let jsonPath = "\(File.homeDirectory().path)/Documents/DualBuild/default.json"
    guard File.exists("\(File.homeDirectory().path)/Documents/DualBuild/default.json") else {
        print("🛑 Error: default.json does not exist. Make sure to run DualBuild with the flag -s 🛑")
        return (nil, nil, false, false)
    }

    do {
        let maybeJsonData = try String(contentsOfFile: jsonPath).data(using: .utf8)
        jsonData = maybeJsonData
        let decodedData = try JSONDecoder().decode(defaultSettings.self,
                                                   from: jsonData!)
        decodedJsonData = decodedData
        } catch {
            print(error)
        }
    
    var decodedServerIP: String?
    if decodedJsonData?.serverip != nil {
        decodedServerIP = decodedJsonData!.serverip
    } else {
        decodedServerIP = nil
        print("🛑 Error: couldn't load serverIP from defaults 🛑")
    }
    
    var decodedPath: String
    if decodedJsonData?.path != nil {
        decodedPath = decodedJsonData!.path
    } else {
        print("⚠️ path default not set.  setting value to home directory ⚠️")
        decodedPath = ""
    }
    
    var decodedLinux: Bool
    if decodedJsonData?.linux != nil {
        decodedLinux = decodedJsonData!.linux
    } else {
        decodedLinux = false
        print("⚠️ linux default not set.  setting value to false ⚠️")
    }
    
    var decodedGo: Bool
    if decodedJsonData?.go != nil {
        decodedGo = decodedJsonData!.go
    } else {
        decodedGo = false
        print("⚠️ go default not set.  setting value to false ⚠️")
    }

    return (decodedServerIP, decodedPath, decodedLinux, decodedGo)
}

func trimWorkingDirectory() -> String? {
    let currentDir = File.currentDirectory()
    let directoryArray = currentDir.components(separatedBy: "/")
    guard let directoryNoSlashes = directoryArray.last else {
        print("🛑 Error: Could not parse current directory 🛑")
        return nil
    }
    return directoryNoSlashes
}
