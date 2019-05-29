//
//  ViewController.swift
//  CalculatorWithPolotter
//
//  Created by Valentin Kiselev on 21/05/2019.
//  Copyright © 2019 Valentin Kiselev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var wolframImageView: UIImageView!
	@IBOutlet weak var plotView: Plot!
	
	@IBOutlet weak var keyboardStack: UIStackView!
	@IBOutlet weak var realisationSwitch: UISwitch!
	@IBOutlet weak var hintImageView: UIImageView!
	@IBOutlet weak var hintLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var xStartValueLabel: UILabel!
	@IBOutlet weak var xEndValueLabel: UILabel!
	@IBOutlet weak var expressionLabel: UILabel!
	
	//MARK: Properties
	/// string that contailns expression to execute
	private var str = "" {
		didSet {
			expressionLabel.text = str
		}
	}
	///Expression transformed to RPN
	private var rpn = [String]()
	private let spellChecker = SpellChecker.shared
	private let calculator = Calculator.shared
	/// more points == more accuracy
	private let numberOfPoints: Double = 200
	/// indicates if we are enter the expression
	private var isExpressionLabelActive = true {
		didSet {
			if isExpressionLabelActive {
				isXStartValueLabelFocused = false
				isXEndValueLabelFocused = false
			}
		}
	}
	/// x bounds range for plot function
	private var xStartValue: Double!
	private var xEndValue: Double!
	
	/// indicates wich label for x range is active
	private var isXStartValueLabelFocused = false
	private var isXEndValueLabelFocused = false
	
	private var tapGestureRecognizer = UITapGestureRecognizer()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	/**
	Shows hint for for time in seconds from now
	*/
	private func showHint(for time: Double) {
		DispatchQueue.main.asyncAfter(deadline: .now() + time) {
			self.hintImageView.isHidden = true
			self.hintLabel.isHidden = true
		}
		UserDefaults.standard.set(true, forKey: "isHintWasShown")
	}
	
	/**
	Calculates points chart will go through
	*/
	private func getChartValues(from: Double, to: Double, step: Double) -> [Point]{
		var output = [Point]()
		let xIndex = (rpn.firstIndex(of: "x") != nil) ? rpn.firstIndex(of: "x") : rpn.firstIndex(of: "-x")
		for i in stride(from: from, through: to, by: step) {
			rpn[xIndex!] = i.stringValue
			let result = Double(calculator.calculate(rpn))
			output.append(Point(value: result!, label: i.roundToDecimal(2).stringValue))
		}
		return output
	}
	
	//MARK: X range set methods
	private func xRangeEntryModeToggle() {
		keyboardStack.subviews[0].isHidden.toggle()
		keyboardStack.subviews[1].isHidden.toggle()
		let openParenthesesButton = view.viewWithTag(24)
		openParenthesesButton?.isUserInteractionEnabled.toggle()
		let closeParenthesesButton = view.viewWithTag(25)
		closeParenthesesButton?.isUserInteractionEnabled.toggle()
	}
	/**
	saves x range values
	*/
	private func saveXBoundsValue() {
		if let xStartText = xStartValueLabel.text, let xStartValue = Double(xStartText) {
			self.xStartValue = xStartValue
		}
		if let xEndText = xEndValueLabel.text, let xEndValue = Double(xEndText) {
			self.xEndValue = xEndValue
		}
	}
	
	//MARK: Proceed calculation
	/**
	Calculate result of entry or plotting function using own realisation
	*/
	private func useOwnRealisation() {
		rpn = RPN(str).getExpression()
		guard str.contains("x") else {
			str = calculator.calculate(rpn)
			return
		}
		activityIndicator.startAnimating()
		defer { self.activityIndicator.stopAnimating() }
		if let x1 = xStartValue, let x2 = xEndValue {
			let data = getChartValues(from: x1, to: x2, step: (xEndValue - xStartValue) / numberOfPoints)
			plotView.data = data
			plotView.lineGap = (plotView.frame.size.width - plotView.rightSpace - plotView.leftSpace) / CGFloat(data.count)
		} else {
			AlertManager.shared.showWarning(title: "I/O error", message: "Invalid range for x")
		}
	}
	
	private func getAnswerFromWolframAlpha(from url: URL?) {
		NetworkManager.shared.fetchCalculation(url: url) {
			data in
			guard let data = data else { return }
			DispatchQueue.main.async {
				self.wolframImageView.clipsToBounds = true
				self.wolframImageView.contentMode = .scaleAspectFit
				defer { self.activityIndicator.stopAnimating() }
				guard let image = UIImage(data: data) else {
					AlertManager.shared.showWarning(title: "Proceed Error", message: "Can't get answer")
					return
				}
				if let cgimage = image.cgImage?.cropping(to: CGRect(x: 0, y: 80, width: image.size.width, height: image.size.height - 135)) {
					self.wolframImageView.image = UIImage(cgImage: cgimage)
				} else {
					self.wolframImageView.image = image
				}
			}
		}
	}
	
	private func useWolframAlpha(isFunction: Bool) {
		let baseStringUrl = "https://api.wolframalpha.com/v1/simple?appid="
		let appid = "YOUR_KEY"
		let expression = isFunction ? "&i=plot expression from startx to endx" : "&i=expression"
		let finalStringURL = baseStringUrl + appid + (expression
		.replacingOccurrences(of: "expression", with: str))
		.replacingOccurrences(of: "startx", with: xStartValue == nil ? "" : xStartValue.roundToDecimal(2).stringValue)
		.replacingOccurrences(of: "endx", with: xEndValue == nil ? "" : xEndValue.roundToDecimal(2).stringValue)
		.percentEncoded
		
		if let url = URL(string: finalStringURL) {
			activityIndicator.startAnimating()
			getAnswerFromWolframAlpha(from: url)
		} else {
			activityIndicator.stopAnimating()
			AlertManager.shared.showWarning(title: "Network Error", message: "Can't recognize valid url")
		}
	}
	//MARK: @IBAction
	/**
	Switch the realisation from my own to Wolfram Alpha and back
	*/
	@IBAction func realisationSwitched(_ sender: UISwitch) {
		plotView.isHidden.toggle()
		wolframImageView.isHidden.toggle()
	}
	/**
	handles x input - shows interface for x range setup and save x values
	*/
	@IBAction func xButtonTapped(_ sender: UIButton) {
		if spellChecker.isPossibleToAppend("x", in: str) {
			str.append("x")
			if !UserDefaults.standard.bool(forKey: "isHintWasShown") {
				hintLabel.isHidden = false
				hintImageView.isHidden = false
				showHint(for: 1.5)
			}
		}
		xRangeEntryModeToggle()
		isExpressionLabelActive.toggle()
	}
	/**
	Add number to expression or x ranre values. ")" is only for expression
	*/
	@IBAction func enterOperands(_ sender: UIButton) {
		guard let text = sender.titleLabel?.text else { return }
		if spellChecker.isPossibleToAppend(Character(text), in: str) {
			str.append(text)
		} else {
			if isXStartValueLabelFocused {
				guard text.mathPriority == 0 || text == "." else { return }
				xStartValueLabel.text?.append(text)
			} else if isXEndValueLabelFocused {
				guard text.mathPriority == 0 || text == "." else { return }
				xEndValueLabel.text?.append(text)
			}
		}
	}
	
	@IBAction func enterOperators(_ sender: UIButton) {
		guard let text = sender.titleLabel?.text else { return }
		if spellChecker.isPossibleToAppend(Character(text), in: str) {
			str.append(text)
		}
	}
	/**
	removes last element from active input
	*/
	@IBAction func eraseLeftTapped(_ sender: Any) {
		guard !str.isEmpty else { return }
		if isExpressionLabelActive {
			str.removeLast()
		} else {
			if isXStartValueLabelFocused {
				guard let text = xStartValueLabel?.text, !text.isEmpty else { return }
				xStartValueLabel.text?.removeLast()
			} else {
				guard let text = xEndValueLabel?.text, !text.isEmpty else { return }
				xEndValueLabel.text?.removeLast()
			}
		}
	}
	
	@IBAction func equalButtonPressed(_ sender: Any) {
		guard !str.isEmpty else { return }
		guard str.last!.isNumber || str.last! == ")" || str.last! == "x" else {
			AlertManager.shared.showWarning(title: "I/O error", message: "Invalid expression")
			return
		}
		guard spellChecker.hasBalancedParentheses(in: str) else {
			AlertManager.shared.showWarning(title: "I/O error", message: "Not valid parentheses entry")
			return
		}
		saveXBoundsValue()
		/// Check the way answer will calculate:
		/// using Wolfram Alpha simple API
		if realisationSwitch.isOn {
			if str.contains("x") {
				useWolframAlpha(isFunction: true)
			} else {
				useWolframAlpha(isFunction: false)
			}
			/// using my own realisation
		} else {
			useOwnRealisation()
		}
	}

}
//MARK: Initial setup
extension ViewController {

	
	private func setupUI() {
		expressionLabel.adjustsFontSizeToFitWidth = true
		xStartValueLabel.adjustsFontSizeToFitWidth = true
		xEndValueLabel.adjustsFontSizeToFitWidth = true
		xStartValueLabel.layer.borderWidth = 0.5
		xStartValueLabel.layer.borderColor = #colorLiteral(red: 0.3788265586, green: 0.3831583261, blue: 0.387270242, alpha: 1)
		xStartValueLabel.layer.cornerRadius = 2
		xEndValueLabel.layer.borderWidth = 0.5
		xEndValueLabel.layer.borderColor = #colorLiteral(red: 0.3788265586, green: 0.3831583261, blue: 0.387270242, alpha: 1)
		setupGestureRecognizer()
		activityIndicator.hidesWhenStopped = true
	}
}

extension ViewController {
	
	private func setupGestureRecognizer() {
		tapGestureRecognizer.numberOfTapsRequired = 1
		tapGestureRecognizer.numberOfTouchesRequired = 1
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setXStartValue))
		xStartValueLabel.addGestureRecognizer(tapGestureRecognizer)
		xStartValueLabel.isUserInteractionEnabled = true
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setXEndValue))
		xEndValueLabel.addGestureRecognizer(tapGestureRecognizer)
		xEndValueLabel.isUserInteractionEnabled = true
	}
	/**
	change active x range input
	*/
	@objc private func setXStartValue() {
		isXStartValueLabelFocused = true
		isXEndValueLabelFocused = false
	}
	/**
	change active x range input
	*/
	@objc private func setXEndValue() {
		isXStartValueLabelFocused = false
		isXEndValueLabelFocused = true
	}
}
