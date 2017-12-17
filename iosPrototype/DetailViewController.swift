import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescription: UITextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    
    func configureView() {
        if let detail = detailItem {
            if let label = detailDescription {
                label.text = detail.text
                creationDateLabel.text = (String(describing: detail.creationDate!))
                voteCount.text = (String(detail.voteCounter))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        detailDescription.textContainerInset = UIEdgeInsets.zero
        detailDescription.textContainer.lineFragmentPadding = 0
    }

    var detailItem: Feedback? {
        didSet {
            configureView()
        }
    }
}
