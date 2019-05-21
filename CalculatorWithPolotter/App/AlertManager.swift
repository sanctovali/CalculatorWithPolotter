//
//  AlertManager.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit

class AlertManager {
	private init() {}
	static let shared = AlertManager()
	
	func showWarning(title: String, message: String? = nil) {
		let ac = UIAlertController(title: title, message: message ?? "", preferredStyle: .alert)
		let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
		ac.addAction(ok)
		UIApplication.topViewController()?.present(ac, animated: true, completion: nil)
	}
}

extension UIApplication {
	static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
		if let navigationController = base as? UINavigationController {
			return topViewController(base: navigationController.visibleViewController)
		}
		if let presented = base?.presentedViewController {
			return topViewController(base: presented)
		}
		return base
	}
}
