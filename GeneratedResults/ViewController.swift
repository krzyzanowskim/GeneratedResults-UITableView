//
//  ViewController.swift
//  GeneratedResults
//
//  Created by Marcin Krzyzanowski on 22/06/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

import UIKit

let allContacts = Contact.load()!

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private var paging = Paging<Contact>(offset: 0, limit: 1).generate()

    private var contacts = [Contact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paging.next(fetchNextBatch) // first page
    }
    
    private func downloadGithubUsers(pageNum: Int) -> [Contact]? {
        var fetched = [Contact]()
        if let url = NSURL(string: "https://api.github.com/users?page=\(pageNum)&per_page=20"),
            let data = NSData(contentsOfURL: url)
        {
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&parseError)
            if let users = parsedObject as? NSArray {
                for user in users {
                    if let dict = user as? NSDictionary, let login = dict["login"] as? String {
                        fetched.append(Contact(firstName:login, lastName:""))
                    }
                }
            }
        }
        return fetched.count > 0 ? fetched : nil
    }
    
    /// Fetch data locally or from the backend
    private func fetchNextBatch(offset: Int, limit: Int, completion: (Array<Contact>) -> Void) -> Void {
        // Remote
        if let remotelyFetched = self.downloadGithubUsers(offset) {
            self.contacts += remotelyFetched
            completion(remotelyFetched)
        } else {
            // Local
            let locallyFetched = Array(allContacts[offset..<min(offset+limit, allContacts.count)])
            self.contacts += locallyFetched
            completion(locallyFetched)
        }
    }
}

//MARK: Data source

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.firstName) \(contact.lastName)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            paging.next(fetchNextBatch)
        }
    }
}

