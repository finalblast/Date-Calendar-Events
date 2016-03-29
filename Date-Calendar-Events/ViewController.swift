//
//  ViewController.swift
//  Date-Calendar-Events
//
//  Created by Nam (Nick) N. HUYNH on 3/29/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UITableViewController {
    
    var calendarArray = [EKCalendar]()
    let eventStore = EKEventStore()
    
    struct TableViewValue {
    
        static let identifier = "Cell"
        
    }
    
    func displayAccessDenied() {
        
        println("Access to the event store is denied.")
        
    }
    
    func displayAccessRestricted() {
        
        println("Access to the event store is restricted.")
        
    }
    
    func extractEventEntityCalendarsOutOfStore(eventStore: EKEventStore) {
        
        let calendarTypes = [
        
            "Local",
            "CalDAV",
            "Exchange",
            "Subscription",
            "Birthday"
            
        ]
        
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent) as [EKCalendar]
        for calendar in calendars {
            
            calendarArray.append(calendar)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
            
        case EKAuthorizationStatus.Authorized:
            extractEventEntityCalendarsOutOfStore(eventStore)
        case EKAuthorizationStatus.Denied:
            displayAccessDenied()
        case EKAuthorizationStatus.NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error) -> Void in
                
                if granted {
                    
                    self.extractEventEntityCalendarsOutOfStore(self.eventStore)
                    
                } else {
                    
                    self.displayAccessDenied()
                    
                }
                
            })
        
        case EKAuthorizationStatus.Restricted:
            displayAccessRestricted()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return calendarArray.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewValue.identifier, forIndexPath: indexPath) as UITableViewCell
        let calendar = calendarArray[indexPath.row]
        cell.textLabel.text = calendar.title
        cell.detailTextLabel?.text = "Type: \(Int(calendar.type.value))"
        cell.backgroundColor = UIColor(CGColor: calendar.CGColor)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowEvents" {
            
            let selectedIndex = tableView.indexPathForCell(sender as UITableViewCell)
            let controller = segue.destinationViewController as CalendarEventsController
            controller.eventStore = eventStore
            controller.calendar = calendarArray[selectedIndex!.row]
            
        }
        
    }
    
}