//
//  CurvedLogic.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit

struct CurvedSegment {
	var controlPoint1: CGPoint
	var controlPoint2: CGPoint
}

class CurveLogic {
	static let shared = CurveLogic()
	private init() {}
	
	private func controlPointsFrom(points: [CGPoint]) -> [CurvedSegment] {
		var result: [CurvedSegment] = []
		/// take control point distance from current point
		let delta: CGFloat = 0.3
		
		/// calculates temporary control points on same axis with current point. UIBezierPath becomes straight
		for i in 1..<points.count {
			let A = points[i-1]
			let B = points[i]
			///find point at distance =  0.3 from А to В
			let controlPoint1 = CGPoint(x: A.x + delta*(B.x-A.x), y: A.y + delta*(B.y - A.y))
			///find point at distance =  0.3 from B to A
			let controlPoint2 = CGPoint(x: B.x - delta*(B.x-A.x), y: B.y - delta*(B.y - A.y))
			let curvedSegment = CurvedSegment(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
			result.append(curvedSegment)
		}
		
		/// Calculates control points for curved UIBezierPath
		for i in 1..<points.count-1 {
			/// temporary control point on the previous - current points segment
			let CP2 = result[i-1].controlPoint2
			
			/// temporary control point on the current - next points segment
			let CP3 = result[i].controlPoint1
			
			/// current point
			let B = points[i]
			/// reflection of CP2 on the previous - current points segment (imaginary extension of it)
			let CP2R = CGPoint(x: 2 * B.x - CP2.x, y: 2 * B.y - CP2.y)
			
			/// reflection of CP2 on the current - next points segment (imaginary extension of it)
			let CP3R = CGPoint(x: 2 * B.x - CP3.x, y: 2 * B.y - CP3.y)
			/// replacing temporary control points with "good" CP's
			result[i].controlPoint1 = CGPoint(x: (CP2R.x + CP3.x)/2, y: (CP2R.y + CP3.y)/2)
			result[i-1].controlPoint2 = CGPoint(x: (CP3R.x + CP2.x)/2, y: (CP3R.y + CP2.y)/2)
		}
		
		return result
	}
	
	/**
	Make curve connecting all the points
	*/
	func createCurvedPath(_ dataPoints: [CGPoint]) -> UIBezierPath? {
		let path = UIBezierPath()
		path.move(to: dataPoints[0])
		
		var curveSegments: [CurvedSegment] = []
		curveSegments = controlPointsFrom(points: dataPoints)
		
		for i in 1..<dataPoints.count {
			path.addCurve(to: dataPoints[i], controlPoint1: curveSegments[i-1].controlPoint1, controlPoint2: curveSegments[i-1].controlPoint2)
		}
		return path
	}
}
