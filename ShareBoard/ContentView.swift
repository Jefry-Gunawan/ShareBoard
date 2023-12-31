//
//  ContentView.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import SwiftUI
import CoreData
import CloudKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Drawing.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Drawing.title, ascending: true)])
    private var drawings: FetchedResults<Drawing>
    
    @State private var showSheet = false
    @State private var showJoinSheet = false
    
    @State private var selectedId: Drawing.ID = nil
    
    @EnvironmentObject var multipeerConn: MultipeerViewModel 
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationSplitView {
            List{
                ForEach(drawings) { drawing in
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if selectedId == drawing.id {
                            Button {
                                selectedId = drawing.id
                                print("\(String(describing: selectedId))")
                            } label: {
                                HStack {
                                    Text(drawing.title ?? "Untitled")
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                                    .padding(.vertical, -10)
                                    .padding(.horizontal, -10)
                                    .frame(maxWidth: .infinity)
                            )
                        } else {
                            Button {
                                selectedId = drawing.id
                                print("\(String(describing: selectedId))")
                            } label: {
                                HStack {
                                    Text(drawing.title ?? "Untitled")
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        NavigationLink(destination: DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title)) {
                            Text(drawing.title ?? "Untitled")
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .navigationTitle(Text("Board "))
            .toolbar {
                EditButton()
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.bottomBar) {
                    HStack {
                        Button(action: {
                            self.showSheet.toggle()
                        }, label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Board")
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                        .sheet(isPresented: $showSheet, content: {
                            AddNewCanvasView().environment(\.managedObjectContext, viewContext)
                        })
                        
                        
                        Button(action: {
                            self.showAlert.toggle()
                        }, label: {
                            Text("Join Board")
                        })
                        .alert("Choose your action first", isPresented: $showAlert, actions: {
                            Button {
                                multipeerConn.invite()
                            } label: {
                                Text("Connect with host")
                            }
                            
                            Button {
                                self.showJoinSheet.toggle()
                            } label: {
                                Text("Open Host Board")
                            }
                            
                            Button {
                                
                            } label: {
                                Text("Dismiss")
                            }

                        })
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .fullScreenCover(isPresented: $showJoinSheet, content: {
                            JoinView()
                        })
                    }
                }
            }
            
        } detail: {
            if selectedId != nil {
                ForEach(drawings) { drawing in
                    if drawing.id == selectedId {
                        let _ = print("CanvasData : \(drawing.canvasData ?? Data())")
                        DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title)
                    }
                }
            } else {
                VStack {
                    Image(systemName: "scribble.variable")
                        .font(.largeTitle)
                    Text("No board has been selected")
                        .font(.title)
                }
                    .navigationTitle("")
            }
            
        }
    }
    
    
    
    func deleteItem(at offset: IndexSet) {
        for index in offset {
            let itemToDelete = drawings[index]
            viewContext.delete(itemToDelete)
            
            if drawings[index].id == selectedId {
                selectedId = nil
            }
            
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
