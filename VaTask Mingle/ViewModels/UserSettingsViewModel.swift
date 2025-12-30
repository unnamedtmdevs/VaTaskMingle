import Foundation

class UserSettingsViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var notificationsEnabled: Bool = true
    @Published var showCompletedTasks: Bool = true
    @Published var defaultPriority: Task.Priority = .medium
    @Published var showDeleteConfirmation: Bool = false
    
    private let userService = UserService.shared
    private let taskService = TaskService.shared
    
    private let notificationsKey = "notifications_enabled"
    private let showCompletedKey = "show_completed_tasks"
    private let defaultPriorityKey = "default_priority"
    
    init() {
        loadSettings()
        userEmail = userService.currentUserEmail
    }
    
    func saveEmail() {
        userService.setUserEmail(userEmail)
    }
    
    func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: notificationsKey)
        UserDefaults.standard.set(showCompletedTasks, forKey: showCompletedKey)
        UserDefaults.standard.set(defaultPriority.rawValue, forKey: defaultPriorityKey)
    }
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsKey)
        showCompletedTasks = UserDefaults.standard.bool(forKey: showCompletedKey)
        
        if let priorityRaw = UserDefaults.standard.string(forKey: defaultPriorityKey),
           let priority = Task.Priority(rawValue: priorityRaw) {
            defaultPriority = priority
        }
    }
    
    func deleteAccount() {
        // Reset all data
        taskService.resetAllData()
        userService.resetAllData()
        
        // Reset settings
        UserDefaults.standard.removeObject(forKey: notificationsKey)
        UserDefaults.standard.removeObject(forKey: showCompletedKey)
        UserDefaults.standard.removeObject(forKey: defaultPriorityKey)
        
        // Reset onboarding
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        userEmail = ""
    }
    
    var totalTasks: Int {
        taskService.tasks.count
    }
    
    var completedTasks: Int {
        taskService.tasks.filter { $0.status == .completed }.count
    }
    
    var totalProjects: Int {
        userService.projects.count
    }
}

