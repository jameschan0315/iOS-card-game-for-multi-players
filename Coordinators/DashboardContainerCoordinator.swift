//
//  DashboardContainerCoordinator.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 12/16/17.
//  Copyright © 2017 GB Soft. All rights reserved.
//

import Foundation

protocol Coordinator {
	func start()
}

final class DashboardContainerCoordinator: Coordinator {
	
	private var childCoordinators = [Coordinator]()
	
	private weak var rootViewController: RootViewController?
	private weak var navigationController: UINavigationControllerType?
	private weak var dashboardContainerViewController: DashboardContainerViewController?
	
	init(navigationController: UINavigationControllerType) {
		self.navigationController = navigationController
	}
	
	func start() {
		guard let navigationController = navigationController else { return }
		let viewModel = DashboardContainerViewModelType()
		let container = DashboardContainerViewController(viewModel)
		
		navigationController.pushViewController(container, animated: true)
		
		dashboardContainerViewController = container
	}
}
