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
    private var paging = PagingGenerator<Contact>(startOffset: 0, limit: 25)

    private var contacts = [Contact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paging.next(fetchNextBatch, onFinish: updateDataSource) // first page
    }
    
    private func downloadGithubUsers(offset: Int) -> [Contact]? {
        var fetched = [Contact]()
        let pageNum:Int = offset / paging.limit
        if let url = NSURL(string: "https://api.github.com/users?page=\(pageNum)&per_page=\(paging.limit)"),
            let data = NSData(contentsOfURL: url)
        {
            let parsedObject: AnyObject?
            do {
                parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            } catch _ as NSError {
                parsedObject = nil
            }
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
}

//MARK: Paging

extension ViewController {
    /// Fetch data locally or from the backend
    private func fetchNextBatch(offset: Int, limit: Int, completion: (Array<Contact>) -> Void) -> Void {
        if let remotelyFetched = downloadGithubUsers(offset) {
            completion(remotelyFetched)
        }
    }
    
    private func updateDataSource(items: Array<Contact>) {
        self.contacts += items
    }
}

//MARK: Data source

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.firstName) \(contact.lastName)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            paging.next(fetchNextBatch, onFinish: updateDataSource)
        }
    }
}

