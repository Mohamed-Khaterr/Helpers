import UIKit

class AppWindow {
    var visibleViewController: UIViewController? {
        if let rootViewController = self.window?.rootViewController {
            return getVisibleViewController(rootViewController)
        } else {
            return nil
        }
    }
    
    /// Currently visible ViewController on screen
    /// - Returns: ViewController of specific type
    func visibleViewController<T>(type: T.Type) -> T? {
        return visibleViewController as? T
    }
    
    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }

        if let tabBarController = rootViewController as? UITabBarController, let selectedVC = tabBarController.selectedViewController {
            return getVisibleViewController(selectedVC)
        }

        return rootViewController
    }
}
