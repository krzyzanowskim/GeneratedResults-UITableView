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
    private var paging = Paging<Contact>().generate()
    private var lastPage = false // because you know if there is more data available

    private var contacts = [Contact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loadMoreTapped(sender: UIButton!) {
        paging.next(fetchNextBatch, completion: { (result) -> Void in
            if let result = result {
                self.contacts += result
            }
        })
    }
    
    /// Fetch data locally or from the backend
    private func fetchNextBatch(offset: Int, limit: Int, completion: (ArraySlice<Contact>) -> Void) -> Void {
        let fetched = allContacts[offset..<min(offset+limit, allContacts.count)]
        completion(fetched)
        lastPage = fetched.count < limit
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
        if !lastPage && indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {

            paging.next(fetchNextBatch, completion: { (result) -> Void in
                if let result = result {
                    self.contacts += result
                }
            })
            
        }
    }
}

