//
//  RPN.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation

struct RPN {
	
	private var expression: [String]
	
	func getExpression() -> [String]{
		return expression
	}
	
	init(_ expression: String) {
		self.expression = RPN.convertRPN(from: RPN.expToArray(expression))
	}
	
	/**
	Transformes the input math expression to Reverse Polish notation
	*/
	
	private static func convertRPN(from input: [String]) -> [String] {
		var output = [String]()
		var stack = [String]()
		input.forEach { (element) in
			switch element.mathPriority {
				///chek for numbers and x
			case -1...0:
				output.append(element)
				///check for open parentheses
			case 1:
				stack.append(element)
				///check for close parentheses
			case 5:
				while let last = stack.last {
					if last.mathPriority != 1 {
						output.append(stack.removeLast())
					} else {
						stack.removeLast()
					}
				}
				///chech for math operators priority
			default:
				while let last = stack.last {
					guard last.mathPriority >= element.mathPriority else { break }
					output.append(stack.removeLast())
				}
				stack.append(element)
			}
		}
		output += stack.reversed()
		return output
	}
	/**
		Converts input string into array of math operands and operators
	*/
	private static func expToArray(_ exp: String) -> [String] {
		var returnArray = [String]()
		var temp = ""
		for char in exp {
			/// chech for unary minus in expression
			if char == "-" && (returnArray.isEmpty || (returnArray.last!.mathPriority >= 1 && returnArray.last != ")")) {
				if temp.isEmpty {
					temp.append(char)
				} else {
					returnArray.append(temp)
					temp.removeAll(keepingCapacity: false)
					returnArray.append(String(char))
				}
			} else if String(char).mathPriority >= 1 {
				if !temp.isEmpty {
					returnArray.append(temp)
					temp.removeAll(keepingCapacity: false)
				}
				returnArray.append(String(char))
			} else {
				temp.append(char)
			}
		}
		if !temp.isEmpty {
			returnArray.append(temp)
		}
		return returnArray
	}
}
