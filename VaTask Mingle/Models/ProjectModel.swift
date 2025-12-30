import Foundation

struct Project: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var color: String
    var createdDate: Date
    var teamMembers: [TeamMember]
    var icon: String
    
    init(name: String, description: String = "", color: String = "#FE284A", icon: String = "folder.fill") {
        self.name = name
        self.description = description
        self.color = color
        self.createdDate = Date()
        self.teamMembers = []
        self.icon = icon
    }
    
    func progress(tasks: [Task]) -> Double {
        let projectTasks = tasks.filter { $0.projectId == id }
        guard !projectTasks.isEmpty else { return 0.0 }
        let completedTasks = projectTasks.filter { $0.status == .completed }.count
        return Double(completedTasks) / Double(projectTasks.count)
    }
}

struct TeamMember: Identifiable, Codable {
    var id: UUID = UUID()
    var email: String
    var role: MemberRole
    var joinedDate: Date
    
    enum MemberRole: String, Codable, CaseIterable {
        case owner = "Владелец"
        case admin = "Администратор"
        case member = "Участник"
        case viewer = "Наблюдатель"
    }
}

