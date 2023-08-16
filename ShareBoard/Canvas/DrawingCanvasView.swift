//
//  DrawingCanvasView.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import SwiftUI
import CoreData
import PencilKit

struct DrawingCanvasView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var multipeerConn: MultipeerViewModel
    
    func updateUIViewController(_ uiViewController: DrawingCanvasViewController, context: Context) {
        uiViewController.drawingData = data
    }
    typealias UIViewControllerType = DrawingCanvasViewController
    
    var data: Data
    var id: UUID
    
    func makeUIViewController(context: Context) -> DrawingCanvasViewController {
        let viewController = DrawingCanvasViewController()
        
        if multipeerConn.session.connectedPeers.isEmpty {
            print("No Connected Peers")
        } else {
            multipeerConn.sendBinaryData(data)
        }
        
        viewController.drawingData = data
        viewController.drawingChanged = {data in
            multipeerConn.sendBinaryData(data)
            
            let request: NSFetchRequest<Drawing> = Drawing.fetchRequest()
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.predicate = predicate
            
            do {
                let result = try viewContext.fetch(request)
                let obj = result.first
                obj?.setValue(data, forKey: "canvasData")
                do {
                    try viewContext.save()
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        return viewController
    }
}

