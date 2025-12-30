import Foundation
import UserNotifications

class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var tasks: [Task] = []
    
    private let tasksKey = "tasks_storage"
    
    init() {
        loadTasks()
        requestNotificationPermission()
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
        scheduleNotification(for: task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            updateNotification(for: task)
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        cancelNotification(for: task)
    }
    
    func toggleTaskStatus(_ task: Task) {
        var updatedTask = task
        switch task.status {
        case .todo:
            updatedTask.status = .inProgress
        case .inProgress:
            updatedTask.status = .review
        case .review:
            updatedTask.status = .completed
            updatedTask.completedDate = Date()
        case .completed:
            updatedTask.status = .todo
            updatedTask.completedDate = nil
        }
        updateTask(updatedTask)
    }
    
    func addComment(to task: Task, comment: Comment) {
        var updatedTask = task
        updatedTask.comments.append(comment)
        updateTask(updatedTask)
    }
    
    // MARK: - Filtering & Sorting
    
    func tasks(for projectId: UUID) -> [Task] {
        return tasks.filter { $0.projectId == projectId }
    }
    
    func upcomingTasks() -> [Task] {
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate > Date() && task.status != .completed
        }.sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }
    
    func overdueTasks() -> [Task] {
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && task.status != .completed
        }
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    func resetAllData() {
        tasks = []
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func scheduleNotification(for task: Task) {
        guard let reminderDate = task.reminderDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о задаче"
        content.body = task.title
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    private func updateNotification(for task: Task) {
        cancelNotification(for: task)
        scheduleNotification(for: task)
    }
    
    private func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}

