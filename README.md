# MJSnackBar		

 [![Version](https://img.shields.io/cocoapods/v/MJSnackBar.svg?style=flat)](http://cocoapods.org/pods/MJSnackBar)
 [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
 [![License](https://img.shields.io/cocoapods/l/MJSnackBar.svg?style=flat)](http://cocoapods.org/pods/MJSnackBar)

 [![Platform](https://img.shields.io/cocoapods/p/MJSnackBar.svg?style=flat)](http://cocoapods.org/pods/MJSnackBar)
 [![Devices](https://img.shields.io/badge/Devices-iPhone | iPad-brightgreen.svg)]()
 [![Doc](https://img.shields.io/cocoapods/metrics/doc-percent/MJSnackBar.svg)](https://img.shields.io/cocoapods/metrics/doc-percent/MJSnackBar.svg)

 MJSnackBar is a pure Swift implementation of the [Android SnackBar](https://www.google.com/design/spec/components/snackbarstoasts.html#snackbarstoastsusage) which is very useful to display short informations and allow user to perform an action about it. It automatically disappear after a delay that you can set.

 ![MJSnackBar demo](Resources/presentation.gif)		

## Installation							

#### CocoaPods :							
 MJSnackBar is available through [CocoaPods](http://cocoapods.org). To install		
 it, simply add the following line to your Podfile:		     	

 ```ruby
  pod "MJSnackBar"		
 ``` 				

#### Carthage :		

You can use Carthage to include MJSnackBar into your project. Just add this dependency to your Cartfile:
```
  github "Shakarang/MJSnackBar"
```

## Example Project		

 The included example project provides a demonstration of MJSnackBar. It's a UITableView with a little ToDo list. When you delete an item, the MJSnackBar is presented with a button allowing user to undo that action.

### Usage :		

##### Preconfigured way :		

When instantiating the MJSnackBar, you have to pass, as a parameter, the view it will be shown on.

 ```swift	       	   
 let snackBar = MJSnackBar(onView: self.view)
 ``` 	 

#### Configuration :

It is a UIView subclass, so you are free to change the same properties like the ```backgroundColor```, etc..

However, there are some MJSnackBar properties that you can modify.

#### Data :

To show the MJSnackBar, you have to create a ```MJSnackBarData``` instance and call a specific method :

```swift
  let data = MJSnackBarData(withIdentifier: indexPath.row, message: msg, andActionMessage: "UNDO", objectSaved: dataArray[indexPath.row])

  snackbar.show(data: data, onView: self.view)
```

When showing the information to the user, you will often do an action behind it.
To help you handle the different events, the ```MJSnackBarData``` comes with multiple fields :

- **identifier** (Optional) : Int, help you identify the data.
- **message** : String, the message that will be displayed.
- **actionMessage** (Optional) : String, the action message that will be displayed.
- **objectSaved** (Optional) : Any, the object concerned by the data. You can retrieve it by casting it.

#### Handle events :

To be able to handle the different events, you have to implement 3 methods which come with the ```MJSnackBarDelegate```.
They let you know when a MJSnackBar is displayed, hidden, or if a user performed an action on it.

To tell the bar that your class can handle its events :
```swift
  snackbar.delegate = self
```

```swift

extension ViewController: MJSnackBarDelegate {

    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType) {
        print("👻 SnackBar disappeared \(data.message) - Reason : \(reason)")
    }

    func snackBarAppeared(with data: MJSnackBarData) {
        print("⭐ SnackBar appeared \(data.message)")
    }

    func snackBarActionTriggered(with data: MJSnackBarData) {

        print("👆 SnackBar touched \(data.message)")

        if let id = data.id {

            let indexPath = IndexPath(row: id, section: 0)

            if let originalData = data.originalObject as? String {
                self.dataArray.insert(originalData, at: id)
            }

            self.examplTableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}
```

## Contribution :

Feel free to fork the project or to give it a ⭐
