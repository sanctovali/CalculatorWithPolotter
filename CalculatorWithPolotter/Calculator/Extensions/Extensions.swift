//
//  Extensions.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation

extension Double {
	/**
	Rounds value to fractionDigits digits after point
	*/
	func roundToDecimal(_ fractionDigits: Int = 3) -> Double {
		let multiplier = pow(10, Double(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
	/// returns string value of the number
	var stringValue: String {
		return String(describing: self)
	}
}
/**
Returns an integer value that represents which kind of
math symbol or digit entered string is
*/

extension String {
	var mathPriority: Int {
		get {
			switch self {
			case "(":
				return 1
			case "+", "-":
				return 2
			case "×", "÷":
				return 3
			case "^", "√":
				return 4
			case ")":
				return 5
			case "x":
				return -1
			default:
				return 0
			}
		}
	}
}
