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
	
	/// replasing math operation symbols and spaces with url codes
	func encodeToURL(_ string: String) -> String {
		return string.replacingOccurrences(of: "+", with: "%2b").replacingOccurrences(of: "^", with: "%5e").replacingOccurrences(of: "÷", with: "%C3%B7").replacingOccurrences(of: "×", with: "%C3%97").replacingOccurrences(of: "√", with: "%E2%88%9A").replacingOccurrences(of: " ", with: "%20")
	}
	
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
