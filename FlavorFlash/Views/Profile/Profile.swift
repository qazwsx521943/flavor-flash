//
//  Profile.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct Profile: View {

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 100, height: 100)

                }

                VStack {
                    Text("Jason")
                        .font(.title)
                        .bold()
                    Text("美食獵人")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }

            List {
                Section("Settings") {
                    ForEach(settingConfigs) { config in
                        NavigationLink(value: config) {
                            Text(config.title)
                        }
                    }
                }

                Section("Account") {
                    ForEach(accountConfigs) { config in
                        //                        NavigationLink(value: config) {
                        NavigationLink(value: config) {
                            Text(config.title)
                        }
                        .foregroundStyle(config.title == "Delete" ? .red : .white)
                        //                        }
                    }
                }
            }
            .navigationDestination(for: SettingItem.self) { setting in
                Text(setting.title)
            }
            .navigationDestination(for: AccountConfigs.self) { config in
                Button(config.title) {

                }
                .padding()
            }
        }
    }
}

#Preview {
    Profile()
}
