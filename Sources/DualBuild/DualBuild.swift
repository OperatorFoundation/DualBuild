import Foundation

import Gardener
import ArgumentParser

public struct DualBuildController {
    var serverIP: String
    let command = Command()
    let git = Git()
    let homeDir = File.homeDirectory().path
    let currentDir = File.currentDirectory()
        
    func swiftBuildMacOS() {
        // exitcode: returns a number, data: stdout, error: stderr
        guard let (exitCode, data, error) = command.run("swift", "build") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
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
        guard let (exitCode, data, error) = ssh.remote(command: "cd \(finalPath)DualBuild/\(current); export PATH=\"/root/swift/usr/bin:$PATH\"; swift build") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
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
    }
    
    func goBuildMacOS() {
        guard let (exitCode, data, error) = command.run("go", "build") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
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
    }
    
    func goBuildLinux(path: String?) {
        guard let ssh = SSH(username: "root", host: serverIP)
        else
        {
            print("🛑 Error: could not ssh into linux server 🛑")
            return
        }
        
        // make sure go is installed in the right place
        guard let goVersion = ssh.goVersion() else {
            print("🛑 Error: Go version not found.  Make sure Go is installed and try again 🛑")
            return
        }
        print("go version: \(goVersion)")
        
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
        guard let (exitCode, data, error) = ssh.remote(command: "cd \(finalPath)DualBuild/\(current); go build") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
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
            if path != nil && path != "" {
                finalPath = "\(path!)"
            } else {
                finalPath = ""
            }
        
        // take the path and check that the DualBuild directory exists
        print("\n\n🛠 verifying DualBuild directory on remote server 🛠\n\n")
        guard let (exitCode1, _, _) = ssh.remote(command: "cd \(finalPath)/DualBuild") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
            return
        }
        
        // if DualBuild directory doesnt exist, create it
        if exitCode1 == 1 {
            print("\n\n🛠 remote DualBuild directory not found. creating DualBuild directory at \(finalPath)/DualBuild 🛠\n\n")
            guard let (exitCode2, data2, error2) = ssh.remote(command: "mkdir \(finalPath)/DualBuild") else {
                print("🛑 Error: Gardener command failed to execute 🛑")
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
            
            // now that the dualbuild directory has been created, try to cd in again
            guard let (exitCode3, data3, error3) = ssh.remote(command: "cd \(finalPath)/DualBuild") else {
                print("🛑 Error: Gardener command failed to execute 🛑")
                return
            }
            print(data3.string)
            guard exitCode3 == 0 else {
                print("exit code: \(exitCode3)")
                if error3.count > 0 {
                    print(error3.string)
                }
                return
            }
        }
        
        // rsync the contents of current directory into the new path
        guard let (exitCode4, data4, error4) = command.run("rsync", "-a ", "\(currentDir)", "root@\(serverIP):\(finalPath)/DualBuild/") else {
            print("🛑 Error: Gardener command failed to execute 🛑")
            return
        }
        print(data4.string)
        guard exitCode4 == 0 else {
            print("exit code: \(exitCode4)")
            if error4.count > 0 {
                print(error4.string)
            }
            return
        }
    }
}
