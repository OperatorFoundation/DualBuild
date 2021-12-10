import Foundation

import Gardener

public struct DualBuildController {
    var serverIP: String
    let command = Command()
    let git = Git()
    let homeDir = File.homeDirectory().path
    let currentDir = File.currentDirectory()
        
    func swiftBuildMacOS() {
        // exitcode: returns a number, data: stdout, error: stderr
        guard let (exitCode, data, error) = command.run("swift", "build") else {
            print("Error: Swift build failed")
            return
        }
        guard exitCode != 0 else {
            print("exit code: \(exitCode)")
            return
        }
        print(data.string)
        if error.count > 0 {
            print(error.string)
        }
    }
    
    func swiftBuildLinux(path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into linux server. 🛑")
            return
        }
    var finalPath: String
        if path != nil && path != "" {
            finalPath = "\(path!)/"
        } else {
            finalPath = ""
        }
        guard let current = trimWorkingDirectory() else {
            print("🛑 Error: could not trim working directory 🛑")
            return
        }
        ssh.remote(command: "cd \(finalPath)DualBuild/\(current); export PATH=\"/root/swift/usr/bin:$PATH\"; swift build")
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
            finalPath = "\(path!)/"
        } else {
            finalPath = ""
        }
        guard let current = trimWorkingDirectory() else {
            print("🛑 Error: could not trim working directory 🛑")
            return
        }
        ssh.remote(command: "cd \(finalPath)DualBuild/\(current); go build")
    }
    
    func linuxTransfer(path: String?, serverIP: String) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into packet capture server 🛑")
            return
        }
        //get the path
        var finalPath: String
            if path != nil {
                finalPath = "\(path!)/"
            } else {
                finalPath = ""
            }
        // take the path and append a DualBuild directory
        print("verifying DualBuild directory on remote server")
        ssh.remote(command: "cd \(finalPath); mkdir DualBuild")
        // scp the contents of current directory into the new path
        command.run("scp", "-r \(currentDir) root@\(serverIP):\(finalPath)")
    }
}
