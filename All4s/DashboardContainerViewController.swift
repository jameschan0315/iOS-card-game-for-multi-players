//
//  DashboardContainerViewController.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 12/16/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import UIKit

protocol UINavigationControllerType: class {
	func pushViewController(_ viewController: UIViewController, animated: Bool)
}

final class DashboardContainerViewController: UIViewController {
	
//	let disposeBag = DisposeBag()
	private(set) var viewModel: DashboardContainerViewModelType
	
	init(_ viewModel: DashboardContainerViewModelType) {
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
		
		configure(viewModel: viewModel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(viewModel: DashboardContainerViewModelType) {
//		viewModel.bindViewDidLoad(rx.viewDidLoad)
		
//		viewModel.rx_title
//			.drive(rx.title)
//			.addDisposableTo(disposeBag)
	}
}

