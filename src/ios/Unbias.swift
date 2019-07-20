import UIKit
import Foundation

@objc(Unbias) class Unbias : CDVPlugin {
    @objc(getArticles:)
    func getArticles(_ command: CDVInvokedUrlCommand) {
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
    func myName(_ command: CDVInvokedUrlCommand) {
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
    func rewriteJsonWithArray(_ command: CDVInvokedUrlCommand) {
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: false);
        
        let arrayString = (command.arguments[0] as! NSDictionary).value(forKey: "arrayString") as? String ?? ""
        
        // if there are no remaining articles in the array, delete JSON file
        if (arrayString.isEmpty) {
            print("Array string is empty.");
            //           deleteArticlesJSON()
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
    func delJSON(_ command: CDVInvokedUrlCommand) {
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
    func delArticle(_ command: CDVInvokedUrlCommand) {
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
    
    
    
    // get named entities
    @objc(getPersonEntities:)
    func getPersonEntities(_ command: CDVInvokedUrlCommand) {
        /*
         * Always assume that the plugin will fail.
         * Even if in this example, it can't.
         */
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: false);
        
        
        // from document.documentElement.innerText
        let articletext = (command.arguments[0] as! NSDictionary).value(forKey: "articletext") as? String ?? ""
        
        do {
            let entitiesObj = try detectEntities(articleText: articletext)
            let entitiesDict: [Dictionary] = try entitiesObj.map{ try $0.asDictionary() }
            // Set the plugin result to succeed.
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: entitiesDict);
            
            
        } catch DetectEntitiesError.emptyArticle {
            print("[detectEntities] Article text is empty");
        } catch {
            print("[detectEntities] Error with detecting entities: \(error)");
        }
        print("after do/catch")
        
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    
}

//  BELOW THIS POINT ARE FUNCTION FOR THE CLASS TO USE, NOT FUNCTION MADE AVAILABLE TO ANGULAR / TYPESCRIPT

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
            print("File does not exist")
            return false
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


enum DetectEntitiesError: Error {
    case emptyArticle
}

func detectEntities(articleText: String) throws -> [PersonEntity] {
    print("[] In  detectEntities function")
    if (articleText.isEmpty) {
        throw DetectEntitiesError.emptyArticle
    }
    
    // create Named Entity Recognition tagger
    let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0);
    tagger.string = articleText;
    
    // identify range to be searched (entire article)
    let range = NSRange(location: 0, length: articleText.utf16.count)
    //Setting various options, such as ignoring white spaces and punctuations
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    // restrict tags to those identified as people
    let tags: [NSLinguisticTag] = [.personalName]
    
    // create list to hold entities
    var entities: [String] = [];
    
    tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
        if let tag = tag, tags.contains(tag) {
            let name = (articleText as NSString).substring(with: tokenRange)
            // TODO: consider searching for any unidentified honorifics here by looking
            // at the preceding word in the string that could improve the
            // accuracy of identifying gender
            entities.append(name);
            print("Detected ", name);
        }
    }
    
    print(entities)
    
    
    // convert entities to NSArray so we can process gender of actors concurrently
    let entitiesNS:NSArray = entities as NSArray
    
    // create empty dictionary to hold entities and their metadata
    var entitiesDict: [PersonEntity] = [];
    
    // create empty dictionary to hold entities with partial names (usually reference to complete entity i.e. Mr. Trump for Donald Trump)
    var partialEntities: [PersonEntity] = [];
    
    // Serial queue for writing to arrays
    let serialQueue = DispatchQueue(label: "serial_queue", attributes: .concurrent)
    
    entitiesNS.enumerateObjects(options: NSEnumerationOptions.concurrent) {
        (entityName:Any!, index:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
        let name = entityName as! String;
        var splitName = name.components(separatedBy: " ")
        
        var gender: String;
        //        var person: Dictionary<String, Any> = [:]
        var person = PersonEntity(fullName: name)
        
        
        for (index, string) in splitName.enumerated() {
            // remove any strings that don't contain alphabetic letters
            if (string.rangeOfCharacter(from: NSCharacterSet.letters) == nil) {
                splitName.remove(at: index)
            }
            
            // remove political affiliations that are commonly detected
            let polWords: [String] = ["Labour", "Tory", "Conservative", "DUP", "SNP", "Sinn", "Fein", "Liberal", "Democrat", "Lib", "Dem", "Democrats", "DUP", "Brexit", "Independence", "Plaid", "Cymru"]
            if (polWords.contains(string)) {
                splitName.remove(at: index)
            }
        }
        
        // Honorific detection
        // find and remove male honorifics and note gender
        for maleHonorific in ["Mr.", "Mr", "Sir", "Lord", "Prince", "Pope", "Fr."] {
            if (splitName.firstIndex(of: maleHonorific) == 0) {
                print("'" + maleHonorific + "' male honorific matched")
                
                // remove honorific at front of string
                splitName.removeFirst(1)
                
                // assign male gender to PersonEntity struct
                gender = "Male";
                person.gender = gender;
                
                // add honorific to array inside struct
                if (person.honorifics as? [String] != nil) {
                    var honorifics: [String] = person.honorifics as! [String]
                    honorifics.append(maleHonorific);
                    person.honorifics = honorifics;
                } else {
                    person.honorifics = [maleHonorific]
                }
                break;
                
            }
        }
        
        // find and remove female honorifics and note gender
        for femaleHonorific in ["Ms.", "Ms", "Mrs.", "Mrs", "Dame", "Lady"] {
            if (splitName.firstIndex(of: femaleHonorific) == 0) {
                print("'" + femaleHonorific + "' female honorific matched")
                
                // remove honorific at front of string
                splitName.removeFirst(1)
                
                // assign male gender to PersonEntity struct
                gender = "Female";
                person.gender = gender;
                
                // add honorific to array inside struct
                if (person.honorifics as? [String] != nil) {
                    var honorifics: [String] = person.honorifics as! [String]
                    honorifics.append(femaleHonorific);
                    person.honorifics = honorifics;
                } else {
                    person.honorifics = [femaleHonorific]
                }
                break;
                
            }
        }
        
        // find and remove neutral honorifics
        for honorific in ["Dr", "Dr.", "Prof.", "Professor", "Mx", "Mx.", "Judge", "Attorney"] {
            if (splitName.firstIndex(of: honorific) == 0) {
                print("'" + honorific + "' neutral honorific matched")
                splitName.removeFirst(1)
                
                if (person.honorifics as? [String] != nil) {
                    var honorifics: [String] = person.honorifics as! [String]
                    honorifics.append(honorific);
                    person.honorifics = honorifics;
                } else {
                    person.honorifics = [honorific]
                }
                break;
            }
        }
        
        // Middle initial removal
        
        
        
        // TODO: get titles (President, Prime Minister, Congresswoman/man, MP)
        // if they match an important political category, a small dataset can be used to find their gender
        ////
        
        // now that honorifics are removed, count distinct words to get
        // an idea of whether we have given name + surname or only one
        if (splitName.count > 1) {
            // multiple names present
            person.fullName = splitName.joined(separator: " ");
            person.firstName = splitName[0];
            person.lastName = splitName.dropFirst().joined(separator: " ");
            
            // put write to array in queue because function processes names concurrently
            serialQueue.async(flags: .barrier) {
                entitiesDict.append(person);
                print("Appended full name person \(person.fullName)")
            }
        } else if (splitName.count == 1) {
            // one name present
            
            // put write to array in queue because function processes names concurrently
            serialQueue.async(flags: .barrier) {
                person.fullName = splitName[0]
                partialEntities.append(person)
            }
            
        } else {
            print("[ERROR] Split name is empty")
        }
    }
    
    // create empty dictionary to hold name key: gender value
    var entitiesGender: [String: ClassificationResult] = [:];
    
    // add remaining code to queue so it has to wait for asynchronous processing of names
    serialQueue.async(flags: .barrier) {
        entitiesDict = combineIdentifiedPersons(personArray: entitiesDict)
        entitiesDict = addMetadataFromPartialEntities(personArray: entitiesDict, partialEntities: partialEntities)
    }
    
    // add remaining code to queue so it has to wait for asynchronous processing of names
    serialQueue.async(flags: .barrier) {
        print("\nSaved Dictionaries: ")
        print("\nFull Name Entities Dictionary: \(entitiesDict as AnyObject)")
        print("\nPartial Name Entities Dictionary: \(partialEntities as AnyObject)")
        
        // now match any partial names to full entities
        //    partialEntities.
        
        print("initializing classification service.")
        let classificationService = ClassificationService()
        print("service initialized.")
        
        var personsNS = entitiesDict.compactMap { $0 } as NSArray
        
        personsNS.enumerateObjects(options: NSEnumerationOptions.reverse) {
            (personStruct:Any!, index:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            var person = personStruct as! PersonEntity;
            if let name = person.firstName {
                print("Identified entity name: ", name)
                print("Gender: ", person.gender as? String ?? "nil")
                
                if(person.gender != nil) {
                    print("\(name)'s gender is already believed to be \(person.gender).")
                    return;
                }
                
                var gender: ClassificationResult;
                
                do {
                    gender = try classificationService.predictGender(from: name);
                    print("Predicted gender: ", gender)
                    print(gender.gender.string, " ", type(of: gender.gender.rawValue))
                    print(entitiesDict[index].fullName, " == ", person.fullName, "?: ", entitiesDict[index].fullName == person.fullName)
                    
                    entitiesDict[index].gender = gender.gender.string
                    entitiesGender.updateValue(gender, forKey: name)
                } catch {
                    print("Error assigning predicted genders to variable: \(error)");
                }
            }
        }
        print("Finished enumerating persons");
        
        
    }
    
    serialQueue.sync() {
        print("Last Sync Block")
    }
    print("Returning entitiesDict.")
    dump(entitiesDict)
    // return entitiesGender;
    return entitiesDict;
    
    
}


// create struct resembling PersonEntity typescript interface
// create struct resembling PersonEntity typescript interface
struct PersonEntity: Equatable, Codable {
    var fullName: String
    var gender: String?
    var firstName: String?
    var lastName: String?
    var honorifics: [String]?
    var title: String?
    var variations: [String]?
    
    // constructor
    init(fullName: String) {
        self.fullName = fullName
    }
    
    // convert values to dictionary
    //    var asDictionary : [String:Any] {
    //        let mirror = Mirror(reflecting: self)
    //        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?,value:Any) -> (String,Any)? in
    //            guard label != nil else { return nil }
    //            return (label!,value)
    //        }).compactMap{ $0 })
    //        return dict
    //    }
    
    // defines function used to test equivalence between PersonEntities
    static func == (my: PersonEntity, your: PersonEntity) -> Bool {
        if(my.fullName == your.fullName) {
            return(true);
        } else if (my.firstName == your.firstName) {
            if(my.lastName == your.lastName) {
                return(true);
            }
        }
        return(false);
    }
    
    // add any missing values like gender or title from another PersonEntity
    mutating func addValues(other: PersonEntity) {
        // if this PersonEntity has missing value,
        // replace with equivalent value of arg PersonEntity
        if(gender == nil && other.gender != nil) {
            gender = other.gender;
        }
        
        if(firstName == nil && other.firstName != nil) {
            firstName = other.firstName;
        }
        
        if(lastName == nil && other.lastName != nil) {
            lastName = other.lastName;
        }
        
        // if other PersonEntity has some honorifics data
        if(other.honorifics != nil) {
            // if primary PersonEntity has no existing honorifics data, just assign it new hons
            if (honorifics == nil) {
                honorifics = other.honorifics;
                // else if it already has existing honorifics data, append it values it does not yet possess
            } else {
                // get honorifics values from other PE that primary PE does not already possess
                let newHons = other.honorifics!.filter{ !honorifics!.contains($0) };
                honorifics! += newHons;
            }
        }
        
        if(title == nil && other.title != nil) {
            title = other.title;
        }
        
        // Here we need to assign any variations data the other PersonEntity holds
        // but also add a new variation if the other PersonEntity name varies from existing PersonEntity
        if(other.variations != nil) {
            // if primary PersonEntity has no existing honorifics data, just assign it new hons
            if (variations == nil) {
                variations = other.variations;
                // else if it already has existing honorifics data, append it values it does not yet possess
            } else {
                // get variations values from other PE that primary PE does not already possess
                let newVars = other.variations!.filter{ !variations!.contains($0) };
                variations! += newVars;
            }
            
            if (fullName != other.fullName) {
                if (variations == nil) {
                    variations = [other.fullName]
                } else {
                    variations!.append(other.fullName)
                }
            }
        }
    }
}

// add easy conversion to dictionary
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}


// This will take an array of PersonEntities
// create groups of similar PersonEntities that are believed to represent one real person
// combine their features into one entity struct to be included in the final array
func combineIdentifiedPersons(personArray: [PersonEntity]) -> [PersonEntity] {
    
    // make empty array to be populated and returned
    var newPersonArray: [PersonEntity] = []
    
    // break down existing array by last name
    let byLastName = Dictionary(grouping: personArray, by: { $0.lastName! })
    
    print("\(byLastName as AnyObject)")
    
    // TODO: this groups entities by last name at the moment, but later groups for
    // partial first name use may have to be implemented
    // Worth considering automated clustering?
    for group in byLastName {
        var entities: [PersonEntity] = group.value;
        // if there's only one entity in the group, add it to array and continue
        if(entities.count == 1) {
            print("No duplicates detected of \(entities[0].fullName)")
            newPersonArray.append(entities[0])
            continue;
        }
        
        // if there's more than one entity in group, iterate
        for var entity in entities {
            if (newPersonArray.contains(entity)) {
                continue;
            }
            
            // derive new array from entities that can be modified in loop
            var new: [PersonEntity] = entities;
            
            // remove PersonEntity
            if(new.firstIndex(of: entity) != nil) {
                new.remove(at: new.firstIndex(of: entity)!)
            }
            
            // match using loose equivalence function defined inside PersonEntity struct
            new = new.filter { $0 == entity }
            
            if (new.count > 0) {
                for matchEntity in new {
                    // add any values from matched entity that original lacks (gender, title)
                    entity.addValues(other: matchEntity)
                }
                // once all other values are added, add entity to array
                newPersonArray.append(entity)
            }
        }
    }
    return newPersonArray;
}

func addMetadataFromPartialEntities(personArray: [PersonEntity], partialEntities: [PersonEntity]) -> [PersonEntity] {
    var personCopy: [PersonEntity] = personArray;
    
    for partial in partialEntities {
        var matches: [Int] = [];
        
        // for each full person that has been identified
        for (index, person) in personCopy.enumerated() {
            // check if partial entity name matches their first name or last name
            if (person.firstName == partial.fullName || person.lastName == partial.fullName) {
                // and add to matches, so we can check there is only one, unambiguous match
                matches.append(index)
            }
        }
        
        if (matches.count == 1) {
            personCopy[matches[0]].addValues(other: partial)
        }
    }
    return(personCopy)
}
