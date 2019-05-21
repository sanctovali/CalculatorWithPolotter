//
//  SpellChecker.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation

class SpellChecker {
	
	private init() {}
	
	static let shared = SpellChecker()
	
	private static let num = "0123456789"
	private	let combinations = [
		"+÷×^": ")\(num)x",
		"(√": "+÷×-^", "-": "\(num)+÷×-()x",
		")": "\(num)x", ".": "\(num)",
		"123456789": ".(+÷×^-√\(num)",
		"x": "+÷×-^(√",
		"0" : "\(num).+÷×-^"
	]
	
	/**
	Check for parentheses balance
	*/
	func hasBalancedParentheses(in str: String) -> Bool {
		var amount = 0
		for c in str {
			if c == "(" {
				amount += 1
			} else if c == ")" {
				amount -= 1
			}
			if amount == -1 {
				return false
			}
		}
		return amount == 0
	}
	
	//MARK: Entry check
	/**
	check if possible to add the selected character to expression
	*/
	func isPossibleToAppend(_ char: Character, in str: String) -> Bool {
		let possibleBeFirst = "-123456789x(√"
		guard let last = str.last else {
			if possibleBeFirst.contains(char) {
				return true
			}
			return false
		}
		for (key, value) in combinations {
			if key.contains(char) && value.contains(last) {
				return true
			}
		}
		return false
	}
	
}
