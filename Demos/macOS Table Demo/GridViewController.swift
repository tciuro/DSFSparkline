//
//  GridViewController.swift
//  macOS Table Demo
//
//  Created by Darren Ford on 27/12/19.
//

import Cocoa

import DSFSparkline

class GridViewController: NSViewController {
	@IBOutlet weak var grid: NSGridView!

	let sz = 33

	var dataSources: [[DSFSparklineDataSource]] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		grid.removeColumn(at: 0)
		grid.removeColumn(at: 0)

		grid.removeRow(at: 0)
		grid.removeRow(at: 0)
		grid.removeRow(at: 0)

		(0 ... sz).forEach { row in
			let item = (0 ... sz).map { _ in
				DSFSparklineDataSource(windowSize: 50, range: -1 ... 1)
			}
			dataSources.append(item)
		}

		(0 ... sz).forEach { row in
			let vs = (0 ... sz).map { column -> DSFSparklineLineGraph in
				let i = DSFSparklineLineGraph()
				i.showZero = true
				i.graphColor = self.color(row: row, col: column)
				i.lineWidth = 1.0
				i.translatesAutoresizingMaskIntoConstraints = false
				i.addConstraint(NSLayoutConstraint(item: i, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 32))
				i.addConstraint(NSLayoutConstraint(item: i, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 32))
				i.dataSource = self.dataSources[row][column]
				return i
			}

			self.grid.addColumn(with: vs)
		}

		self.updateWithNewValues()
	}

	private func lighter(_ color: NSColor) -> NSColor {
		var h: CGFloat = 0
		var s: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0

		let cl = color.usingColorSpace(.genericRGB)!

		cl.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return NSColor(calibratedHue: h,
							saturation: max(s + 0.3, 1.0),
							brightness: max(b + 0.3, 1.0), alpha: a)
	}

	func color(row: Int, col: Int) -> NSColor {

		// CMYK
		let xpos = CGFloat(col) / CGFloat(sz)
		let ypos = CGFloat(row) / CGFloat(sz)

		let c = hypot(xpos, ypos) / 1.414
		let m = hypot(1.0 - xpos, ypos) / 1.414
		let y = hypot(1.0 - xpos, 1.0 - ypos) / 1.414
		let k = hypot(xpos, 1.0 - ypos) / 1.414

//		return NSColor(deviceCyan: c, magenta: m, yellow: y, black: k, alpha: 1.0)
		var color = NSColor(deviceCyan: c, magenta: m, yellow: y, black: k, alpha: 1.0)
		return self.lighter(color)
	}

	func updateWithNewValues() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
			guard let `self` = self else {
				return
			}

			(0 ... self.sz).forEach { row in
				(0 ... self.sz).forEach { column in
					self.dataSources[row][column].push(value: CGFloat.random(in: -1 ... 1))
				}
			}

			self.updateWithNewValues()
		}
	}

}