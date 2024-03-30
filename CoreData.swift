import CoreData

enum XCDataModel: String {
    case espressoLab
    
    private var extensionType: String { ".xcdatamodeld" }
    
    // xcdatamodeld file name
    var file: String {
        return switch self {
        case .espressoLab: "EspressoLab"
        }
    }
}

protocol Entity {
    var name: String { get }
}

enum CoreDataEntity: Entity {
    case store
    
    var name: String {
        return switch self {
        case .store: "Store"
        }
    }
}

protocol LocalDatabase {
    associatedtype EntityType: Entity
    func fetch(entity: EntityType, predicate: NSPredicate?) throws -> [[String: Any]]
    func save(item: [String: Any], in entity: EntityType) throws
    func delete(where predicate: NSPredicate, in entity: EntityType) throws
    func deleteAll(in entity: EntityType) throws
}

struct CoreData: LocalDatabase {
    typealias EntityType = CoreDataEntity
    private let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    init(dataModel: XCDataModel) {
        persistentContainer = NSPersistentContainer(name: dataModel.file)
        loadDatabase()
        
        // in Memory
        persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }
    
    private func loadDatabase() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private func fetch(entity: CoreDataEntity, predicate: NSPredicate? = nil) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity.name)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
    
    func fetch(entity: CoreDataEntity, predicate: NSPredicate? = nil) throws -> [[String: Any]] {
        let result: [NSManagedObject] = try fetch(entity: entity, predicate: predicate)
        
        var items: [[String: Any]] = []
        for data in result {
            items.append(convertToDictionary(data))
        }
        return items
    }
    
    func save(item: [String: Any], in entity: CoreDataEntity) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity.name, in: context) else {
            throw NSError(domain: "CoreData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entity not found in current context"])
        }
        
        let newItem = NSManagedObject(entity: entityDescription, insertInto: context)
        
        for (attribute, value) in item {
            newItem.setValue(value, forKey: attribute)
        }
        try context.save()
    }
    
    func delete(where predicate: NSPredicate, in entity: CoreDataEntity) throws {
        let managedObjects: [NSManagedObject] = try fetch(entity: entity, predicate: predicate)
        
        for object in managedObjects {
            context.delete(object)
        }
        try context.save()
    }
    
    func deleteAll(in entity: CoreDataEntity) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
    }
    
    func convertToDictionary(_ managedObject: NSManagedObject) -> [String: Any] {
        let attributes = managedObject.entity.attributesByName
        var result: [String: Any] = [:]
        for attribute in attributes.keys {
            let value = managedObject.value(forKey: attribute)
            if value is NSManagedObject {
                
            } else {
                
            }
            result[attribute] = managedObject.value(forKey: attribute)
        }
        return result
    }
}
