//
//  JoinCanvasViewController.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 15/08/23.
//

import SwiftUI
import PencilKit

class JoinCanvasViewController: UIViewController {
    lazy var canvas: PKCanvasView = {
        let view = PKCanvasView()
        view.drawingPolicy = .default
        view.minimumZoomScale = 0.5
        view.maximumZoomScale = 2
        view.contentSize = CGSize(width: 10000, height: 10000)
        view.contentOffset = CGPoint(x: 5000, y: 5000)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.drawingGestureRecognizer.isEnabled = false
        return view
    }()
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)

        return toolPicker
    }()
    
    var drawingData = Data()
    var drawingChanged: (Data) -> Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(canvas)
        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        toolPicker.setVisible(false, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.delegate = self
        canvas.becomeFirstResponder()
        
        drawCanvas()
    }
    
    func drawCanvas() {
        if let drawing = try? PKDrawing(data: drawingData) {
            canvas.drawing = drawing
        }
    }
}

extension JoinCanvasViewController: PKToolPickerObserver, PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        drawingChanged(canvasView.drawing.dataRepresentation())
    }
}


