import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var userService = UserService.shared
    
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "#FE284A"
    
    let icons = ["folder.fill", "star.fill", "briefcase.fill", "house.fill", "cart.fill", "book.fill", "flame.fill", "heart.fill"]
    let colors = ["#FE284A", "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DFE6E9", "#A29BFE"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Project name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            NeumorphicTextField(placeholder: "Enter name...", text: $projectName)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextEditor(text: $projectDescription)
                                .frame(height: 80)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.appBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 3, y: 3)
                                        .shadow(color: Color.white.opacity(0.05), radius: 5, x: -3, y: -3)
                                )
                                .foregroundColor(.white)
                        }
                        
                        // Icon selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Icon")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? .white : .white.opacity(0.5))
                                            .frame(width: 60, height: 60)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedIcon == icon ? Color.appAccent : Color.white.opacity(0.1))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Color selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Color")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Create button
                        Button(action: createProject) {
                            Text("Create Project")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(NeumorphicButtonStyle())
                        .disabled(projectName.isEmpty)
                        .opacity(projectName.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
    }
    
    private func createProject() {
        let project = Project(
            name: projectName,
            description: projectDescription,
            color: selectedColor,
            icon: selectedIcon
        )
        userService.addProject(project)
        dismiss()
    }
}

#Preview {
    AddProjectView()
}

