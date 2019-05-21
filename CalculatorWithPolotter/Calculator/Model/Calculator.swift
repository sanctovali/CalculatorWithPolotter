//
//  Calculator.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation

class Calculator {
	
	private init() {}
	static let shared = Calculator()
	
	func calculate(_ expression: [String]) -> String {
		var stack = [Double]()
		expression.forEach { (element) in
			switch element {
			case "+":
				let first = stack.popLast() ?? 0
				let second = stack.popLast() ?? 0
				stack.append(first + second)
			case "-":
				let second = stack.popLast() ?? 0
				let first = stack.popLast() ?? 0
				stack.append(first - second)
			case "×":
				let first = stack.popLast() ?? 0
				let second = stack.popLast() ?? 0
				stack.append(first * second)
			case "÷":
				let second = stack.popLast() ?? 0
				let first = stack.popLast() ?? 0
				stack.append(first / second)
			case "^":
				let second = stack.popLast() ?? 0
				let first = stack.popLast() ?? 0
				stack.append(pow(first, second))
			case "√":
				let first = stack.popLast() ?? 0
				stack.append(sqrt(first))
			default:
				if let operand = Double(element) {
					stack.append(operand)
				}
			}
		}
		return String(stack.removeFirst())
	}
}
