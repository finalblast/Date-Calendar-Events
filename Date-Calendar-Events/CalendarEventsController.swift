//
//  CalendarEventsController.swift
//  Date-Calendar-Events
//
//  Created by Nam (Nick) N. HUYNH on 3/29/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventsController: UITableViewController {
    
    var calendar: EKCalendar!
    var eventStore: EKEventStore!
    var eventsArray = [EKEvent]()
    
    struct TableViewValue {
    
        static let identifier = "Cell"
        
    }
    
    func readEvent() {
        
        let startDate = NSDate()
        let endDate = startDate.dateByAddingTimeInterval(24 * 60 * 60)
        let searchPredicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [calendar])
        let events = eventStore.eventsMatchingPredicate(searchPredicate) as? [EKEvent]
        if let theEvent = events {
            
            if theEvent.count == 0 {
                
                println("No event could be found.")
                
            } else {
                
                for event in theEvent {
                    
                    eventsArray.append(event)
                    
                }
                
                tableView.reloadData()
                
            }

        }
        
    }
    
    func createEventWithTitle(title: String, startDate: NSDate, endDate: NSDate, inCalendar: EKCalendar, inEventStore: EKEventStore, notes: String) -> EKEvent? {
        
        if inCalendar.allowsContentModifications == false {
            
            println("The selected calendar does not allow modifications.")
            return nil
            
        }
        
        var event = EKEvent(eventStore: inEventStore)
        event.calendar = inCalendar
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        
        var error: NSError?
        let result = inEventStore.saveEvent(event, span: EKSpanThisEvent, error: &error)
        if result == false {
            
            if let theError = error {
                
                println("An error occurred \(theError)")
                
            }
            
        }
        
        return event
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        readEvent()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventsArray.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewValue.identifier, forIndexPath: indexPath) as UITableViewCell
        let event = eventsArray[indexPath.row]
        cell.textLabel.text = event.title
        cell.detailTextLabel?.text = event.description
        
        return cell
        
    }
    
    @IBAction func addNewEvent(sender: AnyObject) {
        
        let startDate = NSDate()
        let endDate = startDate.dateByAddingTimeInterval(24 * 60 * 60)
        let event = createEventWithTitle("Nick's Test", startDate: startDate, endDate: endDate, inCalendar: calendar, inEventStore: eventStore, notes: "Test")
        
        if let theEvent = event {
            
            println("Successfully created the event.")
            eventsArray.append(theEvent)
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            
        } else {
            
            println("Failed to create the event.")
            
        }
        
    }
    
}
