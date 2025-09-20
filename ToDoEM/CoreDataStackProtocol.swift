//
//  CoreDataStackProtocol.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 20.09.2025.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func saveViewContext()
}
