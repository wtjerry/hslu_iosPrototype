import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var feedbacks: [Feedback] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.retrieveData()
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.addDummyDataToStorage
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        
        
        let fetchRequest: NSFetchRequest<Feedback> = Feedback.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try self.fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            self.feedbacks = results
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    func addDummyDataToStorage() {
        let context = self.fetchedResultsController.managedObjectContext
        let newFeedback = Feedback(context: context)
        newFeedback.text = "TestFeedback"
        newFeedback.creationDate = Date()
        newFeedback.voteCounter = 42
        
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func retrieveData() {
        let urlString = "https://wherever.ch/hslu/iPhoneAdressData.json"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, AnyObject>]
                    //let json = try JSONSerialization.jsonObject(with: data!, options: SONSerialization.ReadingOptions.mutableContainers) as! Array<AnyObject>

                    let context = self.fetchedResultsController.managedObjectContext

                    for element in json {
                        let newFeedback = Feedback(context: context)
                        newFeedback.text = element["lastName"] as! String
                        newFeedback.voteCounter = element["plz"] as! Int32
                    }
                    try context.save()

                } catch let error as NSError {
                    print(error)
                }
            }

        }.resume()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = self.feedbacks[indexPath.item]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = fetchedResultsController.sections![section]
        return self.feedbacks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpecializedTableViewCell
        let feedback = self.feedbacks[indexPath.item]
        cell.descriptionContent.text = feedback.text
        cell.CountValue.text = String(feedback.voteCounter)
        return cell
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Feedback> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Feedback> = Feedback.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Feedback>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
