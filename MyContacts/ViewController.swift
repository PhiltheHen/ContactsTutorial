//
//  ViewController.swift
//  MyContacts
//
//  Created by Philip Henson on 11/18/15.
//  Copyright © 2015 Flip Tutorials. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var contactStore = CNContactStore()
    var myContacts = [CNContact]()

    @IBOutlet weak var tableView: UITableView!

    // MARK: View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // Fetch contacts from address book
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                let containerId = CNContactStore().defaultContainerIdentifier()
                let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
                do {
                    self.myContacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                } catch _ {
                    print("Error retrieving contacts")
                }
            }
        }

    }

    // MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!

        let contact = myContacts[indexPath.row]

        cell.textLabel!.text = contact.givenName + " " + contact.familyName

        var emailString = ""
        for emailAddress in contact.emailAddresses {
            emailString = emailString + (emailAddress.value as! String) + ", "
        }

        // Remove the final ", " from the concatenated string
        if emailString != "" {
            let myRange = Range<String.Index>(start: emailString.endIndex.predecessor().predecessor(), end: emailString.endIndex.predecessor())
            emailString.removeRange(myRange)
        }

        cell.detailTextLabel?.text = emailString

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myContacts.count
    }


    // MARK: CNContactStore Authorization Methods
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)

        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)

        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == .Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })

        default:
            completionHandler(accessGranted: false)
        }
    }

    func showMessage(message: String) {
        let alert = UIAlertController(title: "MyContacts", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}

