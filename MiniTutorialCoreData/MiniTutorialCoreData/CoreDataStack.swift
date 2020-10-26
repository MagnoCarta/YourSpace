//
//  CoreDataStack.swift
//  MiniTutorialCoreData
//
//  Created by Gilberto Magno on 10/21/20.
//

import Foundation
import CoreData
class CoreDataStack {
   private let modelName: String
   init(modelName: String) {
      self.modelName = modelName
   }
   lazy var mainContext: NSManagedObjectContext = {
      return self.storeContainer.viewContext
   }()
   private lazy var storeContainer: NSPersistentContainer = {
      let container = NSPersistentCloudKitContainer(name: self.modelName)
      container.loadPersistentStores { (storeDescription, error) in
         if let error = error as NSError? {
            print("Unresolved error \(error), \(error.userInfo)")
         }
      }
      return container
   }()
}
// MARK: Internal
extension CoreDataStack {
   func saveContext () {
      guard mainContext.hasChanges else { return }
      do {
         try mainContext.save()
      } catch let nserror as NSError {
         fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
   }
}
