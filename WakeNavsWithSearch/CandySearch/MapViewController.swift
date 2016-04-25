
import UIKit

class MapViewController: UIViewController {
    
    
    var detailBuilding: Building? {
        didSet {
            setTitle()
        }
    }
    
    func setTitle() {
        if let detailBuilding = detailBuilding {
            title = detailBuilding.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
