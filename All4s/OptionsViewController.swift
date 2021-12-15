//
//  OptionsViewController.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/9/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
	
	@IBOutlet weak var userName: UITextField!
	@IBAction func showRootVC(_ sender: Any) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		if let rootVC = sb.instantiateViewController(withIdentifier: "RootVC") as? RootViewController {
			self.present(rootVC, animated: true, completion: {() in
				rootVC.setUsername(text:self.userName.text!)
				rootVC.startGame(false)
			})
		}
	}
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
