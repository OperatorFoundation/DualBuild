# DualBuild

DualBuild is a command line tool for building projects on MacOS and a remote Linux server.

##Setup

1. Install the repository
```
git clone https://github.com/OperatorFoundation/DualBuild.git
```

2. Install mint 
```
brew install mint
```

3. Add mint to your $PATH

a) nano into paths
```
sudo nano /etc/paths
```
b) add this line
```
/Users/<username>/.mint/bin
``` 

4. Run this command from the directory you wish to build with the IP of the remote Linux server
```
mint run dualbuild <serverIP>
```

##Additional flags

--help: list out the other flags and their functions

-i <URL>: installs given github repo on remote server

-p <path>: set path to the project directory on the remote server, EXCLUDING PROJECT NAME(defaults to ~)

-x: include if you wish to use xcodebuild in favor of swift build

-g: include if you wish to build using the Go programming language

-s: include to set the current settings as the default settings. ⚠️ Important notice: this will create /DualBuild in ~/Documents and add the file default.json ⚠️

##Defaults
If you run DualBuild with -s, your current flags are saved to a json file and can be used afterwards by using 
```
mint run dualbuild
```
without any additional command line flags. 


