//
//  ReplacingRootViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

protocol ReplacingRootViewController: class {

    var krm_previousRootViewController: UIViewController? { get set }
    
}


extension UIViewController {

    class func krm_presentAndReplaceRootViewControllerWithViewController<T : UIViewController where T: ReplacingRootViewController>(viewController: T) {
        let rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        UIView.transitionFromView(rootViewController.view, toView: viewController.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve) { success in
            if success {
                viewController.krm_previousRootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
                UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
            }
        }
    }

}


extension ReplacingRootViewController where Self: UIViewController {

    func krm_dismissAndRestoreRootViewController() {
        guard isViewLoaded() && view.window != nil else {
            karmiesLog("\(self) is already dismissed.")
            return
        }
        UIView.transitionFromView(view, toView: krm_previousRootViewController!.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve) { [unowned self] success in
            if success {
                UIApplication.sharedApplication().keyWindow?.rootViewController = self.krm_previousRootViewController
                self.krm_previousRootViewController = nil
            }
        }
    }
    
}
