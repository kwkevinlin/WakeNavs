# WakeNavs
A campus navigations tool

### WakeNavs
WakeNavs is an iOS app that provides **turn-by-turn navigation** to buildings and parking lots to the Wake Forest University campus (can be customizable). 

##### Navigation
The navigation works just like Google Maps, and the routes on the map view change as you walk towards/away from your target destination. In other words, the blue line on the map will always direct you from your current location (wherever you are) to your selected destination. 

##### Search
WakeNavs also has an extensive search function, where you can type in a subset of a string, for example "manc", and the result will return "Manchester Hall". You can also search via Points of Interests (POI), for example typing in "Chick-Fil-A" will return "Benson University Center". 

##### Detail
On the table view, swiping left will allow you to go to a page where details about the building are listed (see screenshot titled "Detail View"). Swiping right will take you to the map view, where the app provides turn-by-turn navigation from user's current location to selected destination.

### Technology: 
WakeNavs uses Google Maps SDK for iOS to generate the map display, and Google Directions API to retrieve route destinations from origin (user's location) to destination (selected from table view). Valid Google API keys can be found in the file called keys.plist. The project also uses MGSwipeTableCell to provide swiping functionalities in the table view. The project dependencies are managed using CocoaPods.

### Execute: 
To run the program, execute **WakeNavs.xcworkspace** (not WakeNavs.xcodeproj).

### Gallery:
!["Table View"](http://i.imgur.com/YKvxQfR.png)
!["Swipe Left"](http://i.imgur.com/oxRYTZR.png)
!["Swipe Right"](http://i.imgur.com/BR9mP32.png)
!["Detail View"](http://i.imgur.com/vNVUiDu.png)
!["Map View"](http://i.imgur.com/bRRg4Rx.png)
