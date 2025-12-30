import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: TaskDetailViewModel
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingReminderPicker = false
    @State private var reminderDate = Date()
    
    init(task: Task) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(task: task))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title and description
                        NeumorphicCard {
                            VStack(alignment: .leading, spacing: 15) {
                                if isEditing {
                                    TextField("Название", text: $viewModel.task.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    TextEditor(text: $viewModel.task.description)
                                        .frame(minHeight: 100)
                                        .foregroundColor(.white.opacity(0.8))
                                } else {
                                    Text(viewModel.task.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    if !viewModel.task.description.isEmpty {
                                        Text(viewModel.task.description)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                        
                        // Status and priority
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Статус")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Menu {
                                    ForEach(Task.TaskStatus.allCases, id: \.self) { status in
                                        Button(status.rawValue) {
                                            viewModel.task.status = status
                                            viewModel.updateTask()
                                        }
                                    }
                                } label: {
                                    Text(viewModel.task.status.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(statusColor(viewModel.task.status))
                                        )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Приоритет")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Menu {
                                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                                        Button(priority.rawValue) {
                                            viewModel.task.priority = priority
                                            viewModel.updateTask()
                                        }
                                    }
                                } label: {
                                    Text(viewModel.task.priority.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(priorityColor(viewModel.task.priority))
                                        )
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Dates info
                        NeumorphicCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                        .foregroundColor(.appAccent)
                                    Text("Создано:")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text(viewModel.formatDate(viewModel.task.createdDate))
                                        .foregroundColor(.white)
                                }
                                
                                if let dueDate = viewModel.task.dueDate {
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                    
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(.appAccent)
                                        Text("Срок:")
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        Text(viewModel.formatDate(dueDate))
                                            .foregroundColor(dueDate < Date() && viewModel.task.status != .completed ? .red : .white)
                                    }
                                }
                                
                                if let completedDate = viewModel.task.completedDate {
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Завершено:")
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        Text(viewModel.formatDate(completedDate))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        // Reminder
                        NeumorphicCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.appAccent)
                                    Text("Напоминание")
                                        .foregroundColor(.white)
                                    Spacer()
                                    
                                    if let reminder = viewModel.task.reminderDate {
                                        Text(viewModel.formatDate(reminder))
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Button(action: { showingReminderPicker.toggle() }) {
                                        Image(systemName: viewModel.task.reminderDate != nil ? "pencil" : "plus")
                                            .foregroundColor(.appAccent)
                                    }
                                }
                                
                                if showingReminderPicker {
                                    DatePicker("", selection: $reminderDate, in: Date()...)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .labelsHidden()
                                        .accentColor(.appAccent)
                                    
                                    Button("Установить") {
                                        viewModel.setReminder(date: reminderDate)
                                        showingReminderPicker = false
                                    }
                                    .buttonStyle(NeumorphicButtonStyle())
                                }
                            }
                        }
                        
                        // Project info
                        if let project = viewModel.project {
                            NeumorphicCard {
                                HStack {
                                    Image(systemName: project.icon)
                                        .foregroundColor(Color(hex: project.color))
                                    Text("Проект:")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text(project.name)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        // Comments section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Комментарии")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.task.comments) { comment in
                                NeumorphicCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(comment.author)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.appAccent)
                                            Spacer()
                                            Text(viewModel.formatDate(comment.createdDate))
                                                .font(.system(size: 11))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        
                                        Text(comment.text)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                            
                            // Add comment
                            VStack(spacing: 10) {
                                TextEditor(text: $viewModel.newComment)
                                    .frame(height: 80)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                    .foregroundColor(.white)
                                
                                Button(action: viewModel.addComment) {
                                    HStack {
                                        Image(systemName: "plus.bubble.fill")
                                        Text("Добавить комментарий")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                }
                                .buttonStyle(NeumorphicButtonStyle())
                                .disabled(viewModel.newComment.isEmpty)
                                .opacity(viewModel.newComment.isEmpty ? 0.5 : 1.0)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Delete button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Удалить задачу")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(NeumorphicButtonStyle(color: .red.opacity(0.7)))
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Детали задачи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        if isEditing {
                            viewModel.updateTask()
                        }
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Готово" : "Изменить") {
                        if isEditing {
                            viewModel.updateTask()
                        }
                        isEditing.toggle()
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .alert("Удалить задачу?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    viewModel.deleteTask()
                    dismiss()
                }
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }
    
    private func priorityColor(_ priority: Task.Priority) -> Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private func statusColor(_ status: Task.TaskStatus) -> Color {
        switch status {
        case .todo: return .gray.opacity(0.6)
        case .inProgress: return .blue.opacity(0.6)
        case .review: return .orange.opacity(0.6)
        case .completed: return .green.opacity(0.6)
        }
    }
}

#Preview {
    TaskDetailView(task: Task(title: "Sample Task", description: "This is a sample task", priority: .high))
}

