import Foundation
import CoreLocation

class Building {
    var name:       String = ""
    var keyWords =  [String]()
    var longtitude: Double
    var latitude:   Double
    var loc: CLLocationCoordinate2D
    var catogory: String = ""
    
    init(myName: String, myKeyWords: [String], myLatitude: Double, myLongtitude: Double, myCatogory: String) {
        self.name       = myName
        self.keyWords   = myKeyWords
        self.latitude   = myLatitude
        self.longtitude = myLongtitude
        self.loc = CLLocationCoordinate2D(latitude: myLatitude,longitude: myLongtitude)
        self.catogory = myCatogory
    }
}
