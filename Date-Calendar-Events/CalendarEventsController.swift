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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            var error: NSError?
            let event = eventsArray[indexPath.row]
            eventStore.removeEvent(event, span: EKSpanThisEvent, commit: false, error: &error)
            if error == nil {
                
                var error: NSError?
                eventStore.commit(&error)
                
                if error == nil {
                    
                    println("Deleted")
                    eventsArray.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                }
                
            }
        }
        
    }
    
    @IBAction func addNewEvent(sender: AnyObject) {
        
        let controller = UIAlertController(title: "New Event", message: "Add new event", preferredStyle: UIAlertControllerStyle.Alert)
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = "Enter event's title here!"
            
        }
        controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            let startDate = NSDate(timeIntervalSinceNow: 20)
            let endDate = startDate.dateByAddingTimeInterval(60)
            let event = self.createEventWithTitle((controller.textFields?.first as UITextField).text, startDate: startDate, endDate: endDate, inCalendar: self.calendar, inEventStore: self.eventStore, notes: "Test")
            let alarm = EKAlarm(relativeOffset: -2.0)
            
            if let theEvent = event {
                
                theEvent.addAlarm(alarm)
                println("Successfully created the event.")
                self.eventsArray.append(theEvent)
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                
            } else {
                
                println("Failed to create the event.")
                
            }
            
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
}
