//
//  File.swift
//  
//
//  Created by Joshua Clark on 11/22/21.
//

import Foundation
import Gardener

struct defaultSettings: Codable {
    let serverIP: String
    let path: String
    let xcode: Bool
    let go: Bool
}

func setDefaultSettings(serverIP: String, path: String?, xcode: Bool, go: Bool) {
    
    var finalPath: String
    if path != nil {
        finalPath = path!
    } else {
        finalPath = File.homeDirectory().path
        print("⚠️ path not specified.  Setting default to home directory ⚠️")
    }
    
//    guard let bundlePath = Bundle.main.path(forResource: nil,
//                                            ofType: nil) else {
//        print(#file)
//        print("🛑 Error: couldnt find path to default.json 🛑")
//        return
//    }
    let bundlePath = "file://\(#file.replacingOccurrences(of: "Utility.swift", with: "default.json"))"
    guard let bundleURL = URL(string: bundlePath) else {
        print("🛑 Error: could not convert DualBuild path to string 🛑")
        return
    }
    let jsonString = "{\n\"serverIP\": \"\(serverIP)\",\n\"path\": \"\(finalPath)\",\n\"xcode\": \"\(xcode)\",\n\"go\": \"\(go)\"/n}"
    do {
            try jsonString.write(to: bundleURL,
                                 atomically: true,
                                 encoding: .utf8)
        } catch {
            print(error)
        }
}

func loadDefaultSettings() -> (String?, String, Bool, Bool){
    var jsonData: Data?
    var decodedJsonData: defaultSettings?
    let bundlePath = "file://\(#file.replacingOccurrences(of: "Utility.swift", with: "default.json"))"
    do {
        let maybeJsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
        jsonData = maybeJsonData
        let decodedData = try JSONDecoder().decode(defaultSettings.self,
                                                   from: jsonData!)
        decodedJsonData = decodedData
        } catch {
            print(error)
        }
    
    var decodedServerIP: String?
    if decodedJsonData?.serverIP != nil {
        decodedServerIP = decodedJsonData!.serverIP
    } else {
        decodedServerIP = nil
        print("🛑 Error: couldn't load serverIP from defaults 🛑")
    }
    
    var decodedPath: String
    if decodedJsonData?.path != nil {
        decodedPath = decodedJsonData!.path
    } else {
        print("⚠️ path default not set.  setting value to home directory ⚠️")
        decodedPath = File.homeDirectory().path
    }
    
    var decodedXcode: Bool
    if decodedJsonData?.xcode != nil {
        decodedXcode = decodedJsonData!.xcode
    } else {
        decodedXcode = false
        print("⚠️ xcode default not set.  setting value to false ⚠️")
    }
    
    var decodedGo: Bool
    if decodedJsonData?.go != nil {
        decodedGo = decodedJsonData!.go
    } else {
        decodedGo = false
        print("⚠️ go default not set.  setting value to false ⚠️")
    }

    return (decodedServerIP, decodedPath, decodedXcode, decodedGo)
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
