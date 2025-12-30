import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskListViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.Priority = .medium
    @State private var selectedDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Название задачи")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            NeumorphicTextField(placeholder: "Введите название...", text: $title)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
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
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Приоритет")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(Task.Priority.allCases, id: \.self) { p in
                                    Button(action: { priority = p }) {
                                        Text(p.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(priority == p ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(priority == p ? priorityColor(p) : Color.white.opacity(0.1))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Due date toggle
                        Toggle("Установить срок", isOn: $hasDueDate)
                            .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.05))
                            )
                        
                        // Date picker
                        if hasDueDate {
                            DatePicker("Срок выполнения",
                                       selection: $selectedDate,
                                       in: Date()...,
                                       displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(.appAccent)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                        
                        // Create button
                        Button(action: createTask) {
                            Text("Создать задачу")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(NeumorphicButtonStyle())
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
    }
    
    private func createTask() {
        viewModel.addTask(
            title: title,
            description: description,
            priority: priority,
            dueDate: hasDueDate ? selectedDate : nil
        )
        dismiss()
    }
    
    private func priorityColor(_ priority: Task.Priority) -> Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

#Preview {
    AddTaskView(viewModel: TaskListViewModel())
}

