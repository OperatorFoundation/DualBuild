import Foundation

import Gardener

public struct DualBuildController {
    var serverIP: String
    let command = Command()
    let git = Git()
    let homeDir = File.homeDirectory().path
    let currentDir = File.currentDirectory()
    
    func remoteInstall(url: String, path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into packet capture server 🛑")
            return
        }
    var finalPath: String
        if path != nil {
            finalPath = path!
        } else {
            finalPath = homeDir
        }
        ssh.remote(command: "cd \(finalPath)")
        ssh.remote(command: "git clone \(url)")
    }
    
    func swiftBuildMacOS() {
        command.run("swift", "build")
    }
    
    func swiftBuildLinux(path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into linux server. 🛑")
            return
        }
    var finalPath: String
        if path != nil {
            finalPath = path!
        } else {
            finalPath = homeDir
        }
        guard let current = trimWorkingDirectory() else {
            print("🛑 Error: could not trim working directory 🛑")
            return
        }
        ssh.remote(command: "cd \(finalPath)/\(current)")
        ssh.remote(command: "swift build")
    }
    
    func goBuildMacOS() {
        command.run("go", "build")
    }
    
    func goBuildLinux(path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into linux server 🛑")
            return
        }
    var finalPath: String
        if path != nil {
            finalPath = path!
        } else {
            finalPath = "~"
        }
        guard let current = trimWorkingDirectory() else {
            print("🛑 Error: could not trim working directory 🛑")
            return
        }
        ssh.remote(command: "cd \(finalPath)/\(current)")
        ssh.remote(command: "go build")
    }
    
    func xcodeBuildMacOS() {
        command.run("xcodebuild")
    }
    
    func xcodeBuildLinux(path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into packet capture server 🛑")
            return
        }
    var finalPath: String
        if path != nil {
            finalPath = path!
        } else {
            finalPath = "~"
        }
        guard let current = trimWorkingDirectory() else {
            print("🛑 Error: could not trim working directory 🛑")
            return
        }
        ssh.remote(command: "cd \(finalPath)/\(current)")
        ssh.remote(command: "xcodebuild")
    }
}
