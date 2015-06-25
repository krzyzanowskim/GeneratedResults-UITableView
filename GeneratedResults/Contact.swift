//
//  Contact.swift
//  GeneratedResults
//
//  Created by Marcin Krzyzanowski on 22/06/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

struct Contact: Hashable {
    let firstName: String
    let lastName: String
    
    var hashValue: Int {
        return firstName.hashValue ^ lastName.hashValue
    }
    
    static func load() -> [Contact]? {
        if let path = NSBundle.mainBundle().pathForResource("Contacts", ofType: "csv"),
           let data = NSData(contentsOfFile: path),
           let text = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        {
            var contacts = [Contact]()
            let lines = split(text.characters) {$0 == "\n"}.map { String($0) }
            for line in lines {
                let name = split(line.characters) { $0 == "|" }.map { String($0) }
                contacts.append(Contact(firstName: name[0], lastName: name[1]))
            }
            return contacts.count > 0 ? contacts : nil
        }
        return nil
    }
}

func ==(lhs: Contact, rhs: Contact) -> Bool {
    return lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
}
