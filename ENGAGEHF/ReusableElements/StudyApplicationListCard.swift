//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct StudyApplicationListCard<Content: View>: View {
    let content: () -> Content

    
    var body: some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Color(uiColor: .secondarySystemGroupedBackground)
                    .ignoresSafeArea()
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowSeparator(.hidden)
    }
    
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

extension Text {
    func studyApplicationHeaderStyle() -> some View {
        self
            .font(.title2.bold())
            .foregroundStyle(Color(.label))
    }
}


#if DEBUG
extension List {
    // periphery:ignore - Used in previews
    func studyApplicationList() -> some View {
        self
            .listRowSpacing(-8)
            .listSectionSpacing(-16)
            .listStyle(.plain)
            .background {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
            }
    }
}

#Preview("Sections") {
    NavigationStack {
        List {
            ForEach(0..<2) { _ in
                Section(
                    content: {
                        ForEach(0..<2) { _ in
                            StudyApplicationListCard {
                                HStack {
                                    Text(verbatim: "Content ...")
                                    Spacer()
                                }
                            }
                        }
                            .listRowSeparator(.hidden)
                    },
                    header: {
                        Text(Date.now, style: .date)
                            .studyApplicationHeaderStyle()
                    }
                )
            }
        }
            .studyApplicationList()
            .navigationTitle(Text(verbatim: "List With Sections"))
    }
}

#Preview("No Sections") {
    NavigationStack {
        List {
            ForEach(0..<2) { _ in
                StudyApplicationListCard {
                    HStack {
                        Text(verbatim: "Content ...")
                        Spacer()
                    }
                }
            }
        }
            .studyApplicationList()
            .navigationTitle(Text(verbatim: "List Without Sections"))
    }
}
#endif
