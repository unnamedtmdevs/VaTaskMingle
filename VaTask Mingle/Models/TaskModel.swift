import Foundation

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var projectId: UUID?
    var priority: Priority
    var status: TaskStatus
    var dueDate: Date?
    var createdDate: Date
    var completedDate: Date?
    var assignedTo: [String] // Email addresses
    var comments: [Comment]
    var tags: [String]
    var reminderDate: Date?
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Низкий"
        case medium = "Средний"
        case high = "Высокий"
        case urgent = "Срочный"
        
        var color: String {
            switch self {
            case .low: return "gray"
            case .medium: return "blue"
            case .high: return "orange"
            case .urgent: return "red"
            }
        }
    }
    
    enum TaskStatus: String, Codable, CaseIterable {
        case todo = "К выполнению"
        case inProgress = "В работе"
        case review = "На проверке"
        case completed = "Завершено"
    }
    
    init(title: String, description: String = "", projectId: UUID? = nil, priority: Priority = .medium, status: TaskStatus = .todo, dueDate: Date? = nil) {
        self.title = title
        self.description = description
        self.projectId = projectId
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.createdDate = Date()
        self.assignedTo = []
        self.comments = []
        self.tags = []
    }
}

struct Comment: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var author: String
    var createdDate: Date
    var mentions: [String] // Tagged users
}

