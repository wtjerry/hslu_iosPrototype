import UIKit
import CoreData

class MasterViewController: UITableViewController, UISearchBarDelegate {

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
    @IBOutlet var searchBarOutlet: UITableView!
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
            
            self.pushFeedbackToServer(feedback)
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
        let urlString = "https://fischli.pythonanywhere.com/getJSONwithparam/"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, AnyObject>]
                    
                    self.fetchFeedbacksFromDatabase()
                    
                    let context = self.managedObjectContext!
                    for element in json {
                        let text = element["text"] as! String
                        if !self.feedbacks.contains(where: {$0.text == text}) {
                            let newFeedback = Feedback(context: context)
                            newFeedback.text = text
                            newFeedback.creationDate = ISO8601DateFormatter().date(from: element["creationDate"] as! String)
                            newFeedback.voteCounter = element["votes"] as! Int32
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
    
    func pushFeedbackToServer(_ feedback: Feedback) {
        let formatter = ISO8601DateFormatter()
        let formattedDate = formatter.string(from: feedback.creationDate!)
        let parameters = ["text": feedback.text!, "creationDate": formattedDate, "votes": feedback.voteCounter] as [String : Any]
        
        let url = URL(string: "https://fischli.pythonanywhere.com/postJSONparam/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            return
        })
        task.resume()
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Put filtercode in here
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Put prefiltercode in here
    }
    @IBAction func clickedOutsideSearchbar(_ sender: Any) {
        debugPrint("TESATASDF")
        self.searchBarOutlet.resignFirstResponder()
    }
    @IBAction func increaseDecreaseFeedbackCounter(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? SpecializedTableViewCell {
            let indexPath = self.tableView.indexPath(for: cell)
            if let index = indexPath?.last as? Int {
                if(sender.currentTitle == "+") {
                    feedbacks[index].voteCounter += 1
                } else {
                    feedbacks[index].voteCounter -= 1
                }
                //Put saving code in here
                self.tableView.reloadData()
            }
        }
    }
    
}
