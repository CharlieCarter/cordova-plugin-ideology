import UIKit
import Foundation

@objc(Unbias) class Unbias : CDVPlugin {
    @objc(getArticles:)
    func getArticles(_ command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */

        if let articles = getJSONContents() as? String {
            // Set the plugin result to fail.
            var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: articles);
            // Set the plugin result to succeed.
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: articles);
            // Send the function result back to Cordova.
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        } else {
            // Set the plugin result to fail.
            var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: false);
            // Set the plugin result to succeed.
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: false);
            // Send the function result back to Cordova.
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
    }

    @objc(myName:)
    func myName(_ command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */

        let name = "Charlie"
        // Set the plugin result to succeed.
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: name);
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }

    @objc(rewriteJsonWithArray:)
    func rewriteJsonWithArray(_ command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */

         // Set the plugin result to fail.
         var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: false);

         let arrayString = command.arguments[0] as? String ?? ""

         // if there are no remaining articles in the array, delete JSON file
         if (arrayString.isEmpty) {
           deleteArticlesJSON()
         }
         // else, write to JSON
         else {
           do {
             try saveStringToJSON(arrayString: arrayString)
             // Set the plugin result to succeed.
             pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: false);
           }
           catch {
             print("[Error] Error with rewriting JSON: \(error).")
           }
         }
         // Send the function result back to Cordova.
         self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }

    // delete JSON file
    @objc(delJSON:)
    func delJSON(_ command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */

            deleteArticlesJSON()

            // Set the plugin result to fail.
            var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "Delete Json attempt Failed");
            // Set the plugin result to succeed.
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Delete Json attempt succeeded");

            // Send the function result back to Cordova.
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }

    // delete individual article
    @objc(delArticle:)
    func delArticle(_ command: CDVInvokedUrlCommand) { // write the function code.
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */

        // deleteArticle()

        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "Delete Json attempt Failed");
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Delete Json attempt succeeded");

        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
}

public func doesJSONExist() -> Bool { // checks if JSON file exists
    let fileManager = FileManager.default
    if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.exeter.Unbias") {
        let newDirectory = directory.appendingPathComponent("articles")

        // check if directory exists
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: newDirectory.path, isDirectory: &isDir) {
            if (isDir.boolValue) {
                print("directory exists in app group group.com.exeter.Unbias.")
            } else {
                print("directory does not exist in app group group.com.exeter.Unbias.")
                return false
            }
        }

        // File path with json doc
        let filePath = newDirectory.appendingPathComponent("articles.json")

        var doesFileExist = false;

        doesFileExist = fileManager.fileExists(atPath: filePath.path)
        print("It is \(doesFileExist) that the file exists at \(filePath.path)")

        if(doesFileExist) {
            return true
        } else {
            return false
            print("File does not exist")
        }
    }
    return false
}

public func getJSONContents() -> NSString? { // get contents of JSON file
    let fileManager = FileManager.default
    print("In getJSONContents function.")

    if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.exeter.Unbias") {
        let newDirectory = directory.appendingPathComponent("articles")

        // File path with json doc
        let filePath = newDirectory.appendingPathComponent("articles.json")

        // check if shared file already exists
        // if it does, then fetch its contents
        if(doesJSONExist()) {
            do {
                print("Found JSON Contents. Returning.")
                let contents = try String(contentsOf: filePath) as NSString
                return(contents)
            } catch {
                print(error)
                return "File does not exist"
            }
        } else {
            print("File does not exist")
        }
    }
    return nil
}


func deleteArticlesJSON() { // deletes JSON file

    if(doesJSONExist()) {
        do {
            let fileManager = FileManager.default

            let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.exeter.Unbias")
            let folder = directory!.appendingPathComponent("articles")
            let file = folder.appendingPathComponent("articles.json")

            try fileManager.removeItem(atPath: file.path)
            print("file removed at path:" + file.path + "  ")
        } catch {
            print(error)
        }
    }
}


func saveStringToJSON(arrayString: String) { // deletes JSON file
    let content = arrayString as NSString

    if(doesJSONExist()) {

      let fileManager = FileManager.default
      let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.exeter.Unbias")
      let folder = directory!.appendingPathComponent("articles")
      let file = folder.appendingPathComponent("articles.json")

      do {
        print("writing to file")

        // encoding 4 stands for NSUTF8StringEncoding, or 8-bit unicode
        try content.write(toFile: file.path, atomically: true, encoding: 4)

      } catch {
          print(error)
      }
    }
}
