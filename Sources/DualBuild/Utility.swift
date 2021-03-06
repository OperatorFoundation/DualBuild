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
        print("\n\nš  path not specified.  Setting default to home directory š \n\n")
    }
    let jsonPath = "file://\(File.homeDirectory().path)/Documents/DualBuild/default.json"
    guard let jsonURL = URL(string: jsonPath) else {
        print("š Error: could not convert DualBuild path to string š")
        return
    }
    let jsonString = "{\n\"serverip\": \"\(serverIP)\",\n\"path\": \"\(finalPath)\",\n\"linux\": \(linux),\n\"go\": \(go)\n}"
    if !File.exists("file://\(jsonPath)") {
        print("\n\nš  creating default.json in ~/Documents/DualBuild/ š \n\n")
        guard let (exitCode, data, error) = command.run("mkdir", "\(File.homeDirectory().path)/Documents/DualBuild") else {
            print("š Error: Gardener command failed to execute š")
            return
        }
        print(data.string)
        guard exitCode == 0 else {
            print("exit code: \(exitCode)")
            if error.count > 0 {
                print(error.string)
            }
            return
        }
        
        guard let (exitCode2, data2, error2) = command.run("touch", "file://\(jsonPath)") else {
            print("š Error: Gardener command failed to execute š")
            return
        }
        print(data2.string)
        guard exitCode2 != 0 else {
            print("exit code: \(exitCode2)")
            if error2.count > 0 {
                print(error2.string)
            }
            return
        }
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
        print("š Error: default.json does not exist. Make sure to run DualBuild with the flag -s š")
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
        print("š Error: couldn't load serverIP from defaults š")
    }
    
    var decodedPath: String
    if decodedJsonData?.path != nil {
        decodedPath = decodedJsonData!.path
    } else {
        print("\n\nš  path default not set.  setting value to home directory š \n\n")
        decodedPath = ""
    }
    
    var decodedLinux: Bool
    if decodedJsonData?.linux != nil {
        decodedLinux = decodedJsonData!.linux
    } else {
        decodedLinux = false
        print("\n\nš  linux default not set.  setting value to false š \n\n")
    }
    
    var decodedGo: Bool
    if decodedJsonData?.go != nil {
        decodedGo = decodedJsonData!.go
    } else {
        decodedGo = false
        print("\n\nš  go default not set.  setting value to false š \n\n")
    }

    return (decodedServerIP, decodedPath, decodedLinux, decodedGo)
}

func trimWorkingDirectory() -> String? {
    let currentDir = File.currentDirectory()
    let directoryArray = currentDir.components(separatedBy: "/")
    guard let directoryNoSlashes = directoryArray.last else {
        print("š Error: Could not parse current directory š")
        return nil
    }
    return directoryNoSlashes
}
