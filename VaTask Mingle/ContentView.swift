//
//  ContentView.swift
//  VaTask Mingle
//
//  Created by Simon Bakhanets on 31.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                TaskListView()
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    .tag(0)
                
                ProjectDashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
            .accentColor(.appAccent)
            .onAppear {
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.appBackground)
                
                // Unselected item color
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.5))
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.white.opacity(0.5))]
                
                // Selected item color
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appAccent)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.appAccent)]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                // Customize navigation bar
                let navAppearance = UINavigationBarAppearance()
                navAppearance.configureWithOpaqueBackground()
                navAppearance.backgroundColor = UIColor(Color.appBackground)
                navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                UINavigationBar.appearance().standardAppearance = navAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                UINavigationBar.appearance().compactAppearance = navAppearance
            }
        }
    }
}

#Preview {
    ContentView()
}
