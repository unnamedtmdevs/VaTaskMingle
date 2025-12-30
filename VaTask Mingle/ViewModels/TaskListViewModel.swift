import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var projects: [Project] = []
    @Published var selectedProject: Project?
    @Published var searchText: String = ""
    @Published var filterStatus: Task.TaskStatus?
    @Published var sortOption: SortOption = .dueDate
    
    private var cancellables = Set<AnyCancellable>()
    private let taskService = TaskService.shared
    private let userService = UserService.shared
    
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case status = "Status"
        case title = "Title"
    }
    
    init() {
        // Subscribe to service updates
        taskService.$tasks
            .sink { [weak self] _ in
                self?.updateTasks()
            }
            .store(in: &cancellables)
        
        userService.$projects
            .assign(to: &$projects)
        
        updateTasks()
    }
    
    var filteredTasks: [Task] {
        var result = tasks
        
        // Filter by project
        if let projectId = selectedProject?.id {
            result = result.filter { $0.projectId == projectId }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        
        // Sort
        switch sortOption {
        case .dueDate:
            result.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        case .priority:
            let priorityOrder: [Task.Priority] = [.urgent, .high, .medium, .low]
            result.sort { priorityOrder.firstIndex(of: $0.priority) ?? 0 < priorityOrder.firstIndex(of: $1.priority) ?? 0 }
        case .status:
            result.sort { $0.status.rawValue < $1.status.rawValue }
        case .title:
            result.sort { $0.title < $1.title }
        }
        
        return result
    }
    
    var tasksByStatus: [Task.TaskStatus: [Task]] {
        Dictionary(grouping: filteredTasks) { $0.status }
    }
    
    func addTask(title: String, description: String, priority: Task.Priority, dueDate: Date?) {
        let task = Task(
            title: title,
            description: description,
            projectId: selectedProject?.id,
            priority: priority,
            status: .todo,
            dueDate: dueDate
        )
        taskService.addTask(task)
    }
    
    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
    }
    
    func toggleTaskStatus(_ task: Task) {
        taskService.toggleTaskStatus(task)
    }
    
    private func updateTasks() {
        tasks = taskService.tasks
    }
}

