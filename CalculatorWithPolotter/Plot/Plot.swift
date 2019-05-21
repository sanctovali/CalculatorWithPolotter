//
//  Plot.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//
import UIKit

class Plot: UIView {
	/// layer contains a plot
	private let dataLayer: CALayer = CALayer()
	/// layer contains the dataLayer
	private let mainLayer: CALayer = CALayer()
	/// layer contains the mainLayer and a titles on x axis
	private let scrollView: UIScrollView = UIScrollView()
	/// layer contains a grid
	private let gridLayer: CALayer = CALayer()
	
	/// array of points of every point of [Point] coordinate on view
	private var dataPoints: [CGPoint]?
	
	/// points distance on the plot
	var lineGap: CGFloat = 10
	/// free space at the top of the plot
	let topSpace: CGFloat = 1.0
	/// free space on the right side of the plot
	let rightSpace: CGFloat = 15
	/// free space on the left side of the plot
	let leftSpace: CGFloat = 40
	/// free space at the bottom of the plot
	let bottomSpace: CGFloat = 30.0
	
	/// indent from the top line of the plot to the top view bound. value in %
	let topHorizontalLine: CGFloat = 1.033
	/// auxialiary variable to alternate titles position of the y axis
	private var isOdd = true
	/// auxialiary variable to display titles on the axes
	/// titles will be displayed only at first, 1/4, 1/2, 3/4 from all points and the last
	private var gridValues: [CGFloat] = [0, 0.25, 0.5, 0.75, 1]
	
	var data: [Point]? {
		didSet {
			self.setNeedsLayout()
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
		setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}
	
	private func setupView() {
		mainLayer.addSublayer(dataLayer)
		scrollView.layer.addSublayer(mainLayer)
		self.layer.addSublayer(gridLayer)
		self.addSubview(scrollView)
		self.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	override func layoutSubviews() {
		scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
		if let data = data {
			scrollView.contentSize = CGSize(width: CGFloat(data.count) * lineGap, height: self.frame.size.height)
			mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(data.count) * lineGap, height: self.frame.size.height)
			dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
			dataPoints = convertDataEntriesToPoints(entries: data)
			gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
			clean()
			drawGrid()
			drawCurvedChart()
			
		}
	}
	
	/**
	Convert Point values to CGPoint corresponding to view coordinates
	*/
	private func convertDataEntriesToPoints(entries: [Point]) -> [CGPoint] {
		if let max = entries.max()?.value,
			let min = entries.min()?.value {
			
			var result: [CGPoint] = []
			let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
			
			for i in 0..<entries.count {
				let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
				let point = CGPoint(x: CGFloat(i)*lineGap + leftSpace, y: height)
				result.append(point)
			}
			return result
		}
		return []
	}
	
	/**
	Build curve connecting all entry points
	*/
	private func drawCurvedChart() {
		guard let dataPoints = dataPoints, dataPoints.count > 0 else {
			return
		}
		if let path = CurveLogic.shared.createCurvedPath(dataPoints) {
			let lineLayer = CAShapeLayer()
			lineLayer.path = path.cgPath
			lineLayer.strokeColor = UIColor.black.cgColor
			lineLayer.fillColor = UIColor.clear.cgColor
			dataLayer.addSublayer(lineLayer)
		}
	}
	
	/**
	Adds grid and titles for it lines
	*/
	private func drawGrid() {
		guard let data = data else { return }
		
		gridValues.forEach { (value) in
			var height: CGFloat = 0
			var width: CGFloat = 0
			if let dataPoints = dataPoints {
				height = dataPoints[Int(value * CGFloat(dataPoints.count - 1))].y
				width = dataPoints[Int(value * CGFloat(dataPoints.count - 1))].x
			}
			/**
			Adds line at the coordinate - vertical if (x = width, y = 0) or horizontal if (x = 0, y = height) at gridLayer
			*/
			func drawLineOn(x: CGFloat = 0, y: CGFloat = 0, isAxis: Bool) {
				let path = UIBezierPath()
				path.move(to: CGPoint(x: x, y: y))
				let width = x == 0 ? gridLayer.frame.size.width : x
				let height = y == 0 ? gridLayer.frame.size.height : y
				path.addLine(to: CGPoint(x: width, y: height))
				let lineLayer = CAShapeLayer()
				lineLayer.path = path.cgPath
				lineLayer.fillColor = UIColor.clear.cgColor
				lineLayer.strokeColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1).cgColor
				lineLayer.lineWidth = 0.5
				lineLayer.lineDashPattern = isAxis ? nil : [8, 8]
				gridLayer.addSublayer(lineLayer)
				let point = data[Int(value * CGFloat(data.count - 1))]
				let textLayer = CATextLayer()
				textLayer.foregroundColor = #colorLiteral(red: 0.07429666688, green: 0.01593330854, blue: 0.4000134008, alpha: 1).cgColor
				textLayer.backgroundColor = UIColor.clear.cgColor
				textLayer.contentsScale = UIScreen.main.scale
				textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
				textLayer.fontSize = 12
				///titles for y axis
				if x == 0 {
					var textFrame: CGRect {
						get {
							if isOdd {
								isOdd.toggle()
								return CGRect(x: x, y: y, width: 50, height: 16)
							} else {
								isOdd.toggle()
								return CGRect(x: x, y: y - 16, width: 50, height: 16)
							}
						}
					}
					textLayer.frame = textFrame
					textLayer.string = String(format: "%.2f", point.value)
					///titles for x axis
				} else if y == 0{
					let textFrame = CGRect(x: width - rightSpace, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: 50, height: 16)
					textLayer.frame = textFrame
					textLayer.string = point.label
				}
				gridLayer.addSublayer(textLayer)
			}
			let isAxis = value == 0
			drawLineOn(x: 0, y: height, isAxis: isAxis)
			drawLineOn(x: width, y: 0, isAxis:  isAxis)
		}
	}
	
	/**
	cleans superview
	*/
	private func clean() {
		mainLayer.sublayers?.forEach({
			if $0 is CATextLayer {
				$0.removeFromSuperlayer()
			}
		})
		dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
		gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
	}
	
}

