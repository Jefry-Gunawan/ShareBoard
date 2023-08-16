//
//  DrawingView.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import SwiftUI

struct DrawingView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var multipeerConn: MultipeerViewModel
    
    @State private var showAlert: Bool = false
    @State private var boardCode: String = ""
    
    @State var id: UUID?
    @State var data: Data?
    @State var title: String?
    
    var body: some View {
        VStack {
            DrawingCanvasView(data: data ?? Data(), id: id ?? UUID())
                .environment(\.managedObjectContext, viewContext)
                .navigationBarTitle(title ?? "Untitled", displayMode: .inline)
                .toolbar {
                    Button {
//                        multipeerConn.advertise(title: self.title ?? "")
                        self.showAlert.toggle()
                    } label: {
                        Text("Share")
                    }
                    .alert("Board Code", isPresented: $showAlert) {
                        TextField("Board Code", text: $boardCode)
                            .textInputAutocapitalization(.never)
                        Button("OK", action: submit)
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Please enter your desired board code")
                    }

                }
        }
        .onDisappear() {
            multipeerConn.disconnectAndStopAdvertising()
        }
    }
    
    func submit() {
        multipeerConn.advertise(boardCode: self.boardCode)
    }
}

