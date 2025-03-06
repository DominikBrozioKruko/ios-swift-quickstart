import CouchbaseLiteSwift
import Combine

class DatabaseManager {
    static let shared = DatabaseManager()
    var replicator: Replicator?
    var database: Database?
    var lastQuery: Query?
    var lastQueryToken: ListenerToken?
    private let queryUpdatesSubject = CurrentValueSubject<[Hotel], Never>([])
    
    init() {
        Database.log.console.level = .verbose
        initializeDatabase()
    }
    
    var queryUpdates: AnyPublisher<[Hotel], Never> {
        queryUpdatesSubject.eraseToAnyPublisher()
    }
    
    private func initializeDatabase() {
        do {
            try getStartedWithReplication(replication: true)
        } catch {
            fatalError("Error initializing database")
        }
    }
    
    private func startListeningForChanges(query: Query) {
        lastQuery = query
        lastQueryToken = query.addChangeListener { (change) in
            guard let results = change.results else { return }
            var hotels: [Hotel] = []
            for result in results {
                let hotelDocumentModel = try? JSONDecoder().decode(hotelDocumentModel.self, from: Data(result.toJSON().utf8))
                guard let hotel = hotelDocumentModel?.hotel else { continue }
                hotels.append(hotel)
            }
            self.queryUpdatesSubject.send(hotels)
        }
    }
    
    private func stopListeningForChanges() {
        guard let lastQueryToken = lastQueryToken else { return }
        lastQuery?.removeChangeListener(withToken: lastQueryToken)
    }
    
    func queryElements(descending: Bool = false) {// -> [Hotel]? {
        do {
            stopListeningForChanges()
            guard let query = try database?.createQuery("SELECT * FROM inventory.hotel WHERE type = 'hotel' ORDER BY title \(descending ? "DESC" : "ASC")") else { return }
            startListeningForChanges(query: query)
           // let results = try query.execute()
           // var hotels: [Hotel] = []
//            for result in results {
//                let hotelDocumentModel = try JSONDecoder().decode(hotelDocumentModel.self, from: Data(result.toJSON().utf8))
//                hotels.append(hotelDocumentModel.hotel)
//            }
//            return hotels
        } catch {
        }
//        return nil
    }
    
    func addNewElement(_ hotel: Hotel) {
        do {
            guard let collection = try database?.collection(name: "hotel", scope: "inventory") else { return }
            let doc = MutableDocument()
            let encodedHotel: Data = try JSONEncoder().encode(hotel)
            guard let jsonString = String(data: encodedHotel, encoding: .utf8) else { return }
            try doc.setJSON(jsonString)
            try collection.save(document: doc)
        } catch {
            
        }
    }
    
    func updateExistingElement(_ hotel: Hotel) {
        do {
            guard let collection = try database?.collection(name: "hotel", scope: "inventory") else { return }
            let query = try database?.createQuery("SELECT META().id FROM inventory.hotel WHERE type = 'hotel' AND id = \(hotel.id)")
            guard let results = try query?.execute() else { return }
            for result in results {
                let docsProps = result.toDictionary()
                guard let docid = docsProps["id"] as? String else { return }
                let doc = try collection.document(id: docid)
                guard let mutableDoc: MutableDocument = doc?.toMutable() else { return }
                let encodedHotel: Data = try JSONEncoder().encode(hotel)
                guard let jsonString = String(data: encodedHotel, encoding: .utf8) else { return }
                try mutableDoc.setJSON(jsonString)
                try collection.save(document: mutableDoc)
            }
        } catch {
            
        }
    }
    
    func deleteElement(_ hotel: Hotel) {
        do {
            guard let collection = try database?.collection(name: "hotel", scope: "inventory") else { return }
            let query = try database?.createQuery("SELECT META().id FROM inventory.hotel WHERE type = 'hotel' AND id = \(hotel.id)")
            
            guard let results = try query?.execute() else { return }
            for result in results {
                let docsProps = result.toDictionary()
                guard let docid = docsProps["id"] as? String else { return }
                guard let doc = try collection.document(id: docid) else { return }
                try collection.delete(document: doc)
            }
        } catch {
            
        }
    }
    
    private func getStartedWithReplication (replication: Bool) throws {
        let configuration: ConfigurationModel? = ConfigurationManager.shared.getConfiguration()
        // Get the database (and create it if it doesn’t exist).
        database = try Database(name: "travel-sample")
        guard let collection = try database?.createCollection(name: "hotel",scope: "inventory") else { return }
        
        if replication {
            guard let configuration else {
                ErrorManager.shared.showError(error: ConfigurationErrors.replicatorConfigMissing)
                return
            }
            // Create replicators to push and pull changes to and from the cloud.
            let targetEndpoint = URLEndpoint(url: configuration.capellaEndpointURL)
            var replConfig = ReplicatorConfiguration(target: targetEndpoint)
            replConfig.replicatorType = .pushAndPull
            
            // Add authentication.
            replConfig.authenticator = BasicAuthenticator(username: configuration.username, password: configuration.password)

            replConfig.addCollection(collection)
            
            // Create replicator (make sure to add an instance or static variable named replicator)
            replicator = Replicator(config: replConfig)
            guard let replicator else { return }
            // Listen to replicator change events.
            replicator.addChangeListener { (change) in
                if let error = change.status.error as NSError? {
                    print("Error code :: \(error.code)")
                }
            }
            
            // Start replication.
            replicator.start()
        } else {
            print("Not running replication")
        }
    }
}
