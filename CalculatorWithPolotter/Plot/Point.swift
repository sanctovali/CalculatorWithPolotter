//
//  Point.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import Foundation
/**
Struct is describing a point of a plot
*/
struct Point {
	let value: Double
	let label: String
}

extension Point: Comparable {
	static func <(lhs: Point, rhs: Point) -> Bool {
		return lhs.value < rhs.value
	}
	static func ==(lhs: Point, rhs: Point) -> Bool {
		return lhs.value == rhs.value
	}
}
