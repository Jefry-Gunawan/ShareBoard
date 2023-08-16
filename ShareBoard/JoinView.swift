//
//  JoinView.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 14/08/23.
//

import SwiftUI

struct JoinView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var multipeerConn: MultipeerViewModel
    
    var body: some View {
        JoinCanvasView(data: multipeerConn.binaryDataOut)
        
        Spacer()
        
        Button {
            dismiss()
        } label: {
            Text("Dismiss")
        }
    }
}

struct JoinView_Previews: PreviewProvider {
    static var previews: some View {
        JoinView()
    }
}
