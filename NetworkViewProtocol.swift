import Foundation
import UIKit


/// This indicate that the ViewController has network operations that need to handle inside the ViewController.
protocol NetworkView: AnyObject where Self: UIViewController  {
    func showLoader(_ isLoading: Bool)
    func showError(message: String, title: String?)
    func noContentViewAppear(_ isAppear: Bool, title: String)
}


extension NetworkView {
    
    /// Showing Custom Loading Indicator to the view of ViewController
    /// - Parameter isLoading: true to show indicator, false to hide the indicator
    func showLoader(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                CustomLoader.startAnimation(on: self.view)
            } else {
                CustomLoader.stopAnimation(on: self.view)
            }
        }
    }
    
    
    /// Presenting error to the user in Custom Alert View
    /// - Parameters:
    ///   - message: Body Message
    ///   - title: Header Title
    func showError(message: String, title: String? = nil) {
        DispatchQueue.main.async {
            if let title = title {
                CustomAlert.present(on: self, title: title, message: message)
            } else {
                CustomAlert.present(on: self, message: message)
            }
        }
    }
    
    
    /// Showing Custom View that indicate the user that there is no data
    /// - Parameters:
    ///   - isAppear: true to show, false to hide
    ///   - title: message that appear to the user
    func noContentViewAppear(_ isAppear: Bool, title: String) {
        DispatchQueue.main.async {
            if isAppear {
                let contentEmptyView = ContentEmpty(title: title)
                self.view.addSubview(contentEmptyView)
                contentEmptyView.setSelfConstrains(on: self.view)
            } else {
                DispatchQueue.main.async {
                    self.view.subviews.filter({ $0 is ContentEmpty }).forEach({ $0.removeFromSuperview() })
                }
            }
        }
    }
}

