//
//  NetworkManager.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation

class NetworkManager {
	static let shared = NetworkManager()
	private init() {}

	func fetchCalculation(url: URL?, completion: @escaping (Data?) -> Void) {
		guard let url = url else {
			print("Error in \(#function) at line \(#line): URL is nil")
			completion(nil)
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {
				print ("Error in \(#function) at line \(#line): can't read the data")
				completion(nil)
				return
			}
			completion(data)
			}.resume()
	}
}
