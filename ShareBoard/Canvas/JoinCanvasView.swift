//
//  JoinCanvasView.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 15/08/23.
//

import SwiftUI
import CoreData
import PencilKit

struct JoinCanvasView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var multipeerConn: MultipeerViewModel
    
    func updateUIViewController(_ uiViewController: JoinCanvasViewController, context: Context) {
        print("AAA")
        uiViewController.drawingData = data
        uiViewController.drawCanvas()
    }
    typealias UIViewControllerType = JoinCanvasViewController
    
    var data: Data
    
    func makeUIViewController(context: Context) -> JoinCanvasViewController {
        let viewController = JoinCanvasViewController()
        
        viewController.drawingData = data

        viewController.drawingChanged = {data in
            
        }
        return viewController
    }
}
