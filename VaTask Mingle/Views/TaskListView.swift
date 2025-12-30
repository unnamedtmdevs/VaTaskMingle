import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingAddTask = false
    @State private var showingAddProject = false
    @State private var showingProjectSelector = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Project selector
                        projectSelector
                        
                        // Search and filter
                        searchAndFilter
                        
                        // Task list
                        if viewModel.filteredTasks.isEmpty {
                            emptyState
                        } else {
                            tasksList
                        }
                    }
                    .padding()
                }
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                        }
                        .buttonStyle(NeumorphicButtonStyle())
                        .padding(.trailing, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("TaskMingle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProject = true }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.appAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
        .accentColor(.appAccent)
    }
    
    private var projectSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // All tasks button
                Button(action: { viewModel.selectedProject = nil }) {
                    HStack {
                        Image(systemName: "tray.full.fill")
                        Text("All Tasks")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(viewModel.selectedProject == nil ? .white : .white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.selectedProject == nil ? Color.appAccent : Color.white.opacity(0.1))
                    )
                }
                
                // Projects
                ForEach(viewModel.projects) { project in
                    Button(action: { viewModel.selectedProject = project }) {
                        HStack {
                            Image(systemName: project.icon)
                            Text(project.name)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(viewModel.selectedProject?.id == project.id ? .white : .white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedProject?.id == project.id ? Color.appAccent : Color.white.opacity(0.1))
                        )
                    }
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    private var searchAndFilter: some View {
        VStack(spacing: 12) {
            // Search
            NeumorphicTextField(placeholder: "Search tasks...", text: $viewModel.searchText)
            
            // Filter and sort
            HStack {
                // Status filter
                Menu {
                    Button("All") { viewModel.filterStatus = nil }
                    ForEach(Task.TaskStatus.allCases, id: \.self) { status in
                        Button(status.rawValue) {
                            viewModel.filterStatus = status
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(viewModel.filterStatus?.rawValue ?? "Filter")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // Sort
                Menu {
                    ForEach(TaskListViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            viewModel.sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.sortOption.rawValue)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                    )
                }
            }
        }
    }
    
    private var tasksList: some View {
        LazyVStack(spacing: 15) {
            ForEach(viewModel.filteredTasks) { task in
                TaskRowView(task: task, onTap: {
                    selectedTask = task
                }, onToggle: {
                    viewModel.toggleTaskStatus(task)
                })
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 100)
            
            Text("No Tasks")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Tap + to create your first task")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    let task: Task
    let onTap: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            NeumorphicCard {
                HStack(spacing: 15) {
                    // Status checkbox
                    Button(action: onToggle) {
                        Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(task.status == .completed ? .green : .appAccent)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .strikethrough(task.status == .completed)
                        
                        HStack {
                            // Priority badge
                            Text(task.priority.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(priorityColor(task.priority))
                                )
                            
                            // Due date
                            if let dueDate = task.dueDate {
                                HStack(spacing: 3) {
                                    Image(systemName: "calendar")
                                    Text(formatDate(dueDate))
                                }
                                .font(.system(size: 11))
                                .foregroundColor(dueDate < Date() && task.status != .completed ? .red : .white.opacity(0.6))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Status badge
                    Text(task.status.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor(task.status))
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    TaskListView()
}

