
import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var candyImageView: UIImageView!
    
    var detailBuilding: Building? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detailBuilding = detailBuilding {
            if let detailDescriptionLabel = detailDescriptionLabel, candyImageView = candyImageView {
                detailDescriptionLabel.text = detailBuilding.name
                candyImageView.image = UIImage(named: detailBuilding.name)
                title = detailBuilding.keyWords[0]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
