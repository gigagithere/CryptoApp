//
//  CustomSearchBar.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        CustomTextField(icon: "magnifyingglass", placeholder: "Search Coins", text: $text)
    }
}

#Preview {
    CustomSearchBar(text: .constant("Bitcoin"))
}
