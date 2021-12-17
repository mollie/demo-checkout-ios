import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Get payment id
        guard
            let urlContext = URLContexts.first,
            let paymentId = Int(urlContext.url.lastPathComponent)
        else { return }
       
        // Refresh the PaymentsViewController's data
        guard
            let navigation = window?.rootViewController as? UINavigationController,
            let paymentsDelegate = navigation.viewControllers.compactMap({ $0 as? PaymentsViewControllerDelegate }).first
        else { return }
        paymentsDelegate.paymentCompleted()
    }
}

