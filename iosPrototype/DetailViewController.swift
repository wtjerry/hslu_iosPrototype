import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    
    func configureView() {
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.text
                creationDateLabel.text = (String(describing: detail.creationDate))
                voteCount.text = (String(detail.voteCounter))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var detailItem: Feedback? {
        didSet {
            configureView()
        }
    }
}
