#!/usr/bin/env xcrun swift
import Foundation
import Security

let ALTOOL = "/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"
func main(){
    let args = get_args()
    let account = val_or_usage(args["u"])
    let ipa_path = val_or_usage(args["f"])
    if !NSFileManager.defaultManager().fileExistsAtPath(ALTOOL){
        println("altool not found")
        println("  " + ALTOOL)
        exit(1)
    }
    if !NSFileManager.defaultManager().fileExistsAtPath(ipa_path){
        println("ipa not found")
        println("  " + ipa_path)
        exit(1)
    }
    let password:String = val_or_exit(get_password(account)){
        println("Password not found")
    }
    exec(account, ipa_path, password, args["v"] != nil)
}
func val_or_exit<T>(v:T?, f:() -> Void)->T{
    if(v == nil){
        f()
        exit(1)
    }else{
        return v!
    }
}
func val_or_usage<T>(v:T?) -> T{
    return val_or_exit(v){
        usage()
    }
}
func exec(account:String, ipa_path:String, password:String, is_validate:Bool){
    let task = NSTask()
    task.launchPath = ALTOOL
    if is_validate{
        println("Validating...")
        task.arguments = ["-u", account, "-p", password, "--validate-app", "-f", ipa_path]
    }else{
        println("Uploading...")
        task.arguments = ["-u", account, "-p", password, "--upload-app", "-f", ipa_path]
    }
    task.standardInput = NSFileHandle.fileHandleWithNullDevice()
    task.standardError = NSFileHandle.fileHandleWithStandardError()
    task.standardOutput = NSFileHandle.fileHandleWithStandardOutput()
    task.launch()
    task.waitUntilExit()
}
func get_password(_account:String) -> String?{
    let host:NSString = "itunesconnect.apple.com"
    let account:NSString = _account
    var buf_size:UInt32 = 0
    var buf:UnsafeMutablePointer<Void> = nil
    let res = SecKeychainFindInternetPassword(nil, 
                                    UInt32(host.length), host.UTF8String,
                                    0, nil,
                                    UInt32(account.length), account.UTF8String,
                                    0, nil,
                                    0,
                                    SecProtocolType(kSecProtocolTypeHTTPS),
                                    SecAuthenticationType(kSecAuthenticationTypeHTMLForm),
                                    &buf_size, &buf, nil)
    if res != errSecSuccess{
        return nil
    }
    let pass = NSString(bytes: buf, length: Int(buf_size), encoding: NSUTF8StringEncoding)
    SecKeychainItemFreeContent(nil , buf)
    return pass
}
func get_args() -> Dictionary<String,String>{
    return get_args(Process.arguments)
}
func get_args(_args:Array<String>) -> Dictionary<String,String>{
    var args = _args
    var res = Dictionary<String,String>()
    var last_k:String? = nil
    while !args.isEmpty{
        let v = args.removeAtIndex(0)
        if v.hasPrefix("-"){
            let k = v.substringFromIndex(advance(v.startIndex, 1))
            last_k = k
            res[k] = ""
        }else if last_k != nil{
            res[last_k!] = v
        }
    }
    return res
}
func usage(){
    println("Usage: ipa_uploader.swift -u username -f path_to_ipa_file")
    println(" -u        user name for iTunes Connect")
    println(" -f        ipa file path")
    println(" -v        validation mode")
}
main()
