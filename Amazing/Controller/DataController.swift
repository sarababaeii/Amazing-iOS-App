//
//  DataController.swift
//  Amazing
//
//  Created by Sara Babaei on 3/18/20.
//  Copyright © 2020 Sara Babaei. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum Emotion: String {
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case snooze = "Snoozing"
}

class DataController {
    var entityName = "Mood"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    
    var today: Date{
        return startOfDay(for: Date())
    }
    
    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date) //eg. yyyy-mm-dd 00:00:00
    }
    
    func dateCaption(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: date)
    }
    
    @available(iOS 13.0, *)
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    private func creatMood() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    private func update(mood: NSManagedObject?, emotion: Emotion) {
        if let mood = mood {
            mood.setValue(emotion.rawValue, forKey: "emotion")
            mood.setValue(today, forKey: "createdAt")
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch{
        }
    }
    
    private func fetchMood(date: Date) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "createdAt = %@", startOfDay(for: date) as NSDate)
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request) as! [NSManagedObject]
            return result.first
        } catch{
        }
        return nil
    }
    
    func log(emotion: Emotion){
        var mood = fetchMood(date: today)
        if mood == nil {
            mood = creatMood()
        }
        update(mood: mood, emotion: emotion)
        saveContext()
    }
    
    func logs(from: Date?, to: Date?) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var predicate: NSPredicate?
        
        if let from = from, let to = to {
            predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", startOfDay(for: from) as NSDate, startOfDay(for: to) as NSDate)
        }
        else if let from = from {
            predicate = NSPredicate(format: "createdAt >= %@", startOfDay(for: from) as NSDate)
        }
        else if let to = to {
            predicate = NSPredicate(format: "createdAt <= %@", startOfDay(for: to) as NSDate)
        }
        request.predicate = predicate
        
        let sectionSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sectionSortDescriptor]
        
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request) as! [NSManagedObject]
            return result
        } catch{
        }
        return [NSManagedObject]()
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try context.execute(batchDeleteRequest)
        } catch{
        }
        saveContext()
    }
    
    func printDetails(logs: [NSManagedObject]) {
        for log in logs as! [Mood] {
            print("\(dateCaption(for: log.createdAt!)) \(log.emotion)")
        }
    }
    
    func count(logs: [NSManagedObject], emotion: Emotion) -> Int {
        return logs.filter{ (log) -> Bool in
            return (log as! Mood).emotion == emotion.rawValue
        }.count
    }
    
    func creatDummyLogsFor(days: Int) {
        deleteAll()
        for i in 0 ..< days {
            let mood = creatMood()
            let emotion = getRandomEmotion()
            
            if let mood = mood {
                var date = today
                date.addTimeInterval(-Double(i * 3600 * 24))
                mood.setValue(emotion.rawValue, forKey: "emotion")
                mood.setValue(date, forKey: "createdAt")
            }
            
            saveContext()
        }
    }
    
    func getRandomEmotion() -> Emotion {
        let key = Int.random(in: 0...3)
        let emotion: Emotion
        
        switch key {
        case 0:
            emotion = .happy
        case 1:
            emotion = .neutral
        case 2:
            emotion = .sad
        default:
            emotion = .snooze
        }
        
        return emotion
    }
}
