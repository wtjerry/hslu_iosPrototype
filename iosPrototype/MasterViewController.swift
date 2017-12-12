import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    public let CreateIdentifier : String = "createIdentifier"

    var feedbacks: [Feedback] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.fetchJSONToDatabaseAndUpdateUI()
    }
    @IBAction func backWithoutSaving(segue: UIStoryboardSegue) {
    }
    @IBAction func backButSave(segue: UIStoryboardSegue) {
        if let descController = segue.source as? CreateNewEntryController {
            let context = self.managedObjectContext!
            let feedback = Feedback(context: context)
            feedback.text = descController.DescriptionInput.text as String?
            feedback.creationDate = Date.init()
            feedback.voteCounter = 0
            do {
                try context.save()
            } catch let error as NSError {
                print(error)
            }
            self.fetchFeedbacksFromDatabase()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        self.fetchFeedbacksFromDatabase()
        self.tableView.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    func fetchFeedbacksFromDatabase() {
        let fetchRequest: NSFetchRequest<Feedback> = Feedback.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try self.managedObjectContext!.fetch(fetchRequest)
            self.feedbacks = results
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchJSONToDatabaseAndUpdateUI() {
        let urlString = "https://wherever.ch/hslu/iPhoneAdressData.json"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, AnyObject>]
                    
                    self.fetchFeedbacksFromDatabase()
                    
                    let context = self.managedObjectContext!
                    for element in json {
                        let name = element["lastName"] as! String
                        if !self.feedbacks.contains(where: {$0.text == name}) {
                            let newFeedback = Feedback(context: context)
                            newFeedback.text = name
                            newFeedback.voteCounter = element["plz"] as! Int32
                        }
                    }
                    try context.save()
                    
                    self.fetchFeedbacksFromDatabase()
                    DispatchQueue.main.sync {
                        self.tableView.reloadData()
                    }
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
        return self.feedbacks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpecializedTableViewCell
        let feedback = self.feedbacks[indexPath.item]
        cell.descriptionContent.text = feedback.text
        cell.CountValue.text = String(feedback.voteCounter)
        return cell
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
