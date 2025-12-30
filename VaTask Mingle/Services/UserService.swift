import Foundation

class UserService: ObservableObject {
    static let shared = UserService()
    
    @Published var projects: [Project] = []
    @Published var currentUserEmail: String = ""
    
    private let projectsKey = "projects_storage"
    private let userEmailKey = "user_email"
    
    init() {
        loadProjects()
        loadUserEmail()
    }
    
    // MARK: - Project Management
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
        
        // Also delete all tasks in this project
        let tasksToDelete = TaskService.shared.tasks.filter { $0.projectId == project.id }
        tasksToDelete.forEach { TaskService.shared.deleteTask($0) }
    }
    
    // MARK: - Team Management
    
    func addTeamMember(to project: Project, email: String, role: TeamMember.MemberRole) {
        var updatedProject = project
        let member = TeamMember(email: email, role: role, joinedDate: Date())
        updatedProject.teamMembers.append(member)
        updateProject(updatedProject)
    }
    
    func removeTeamMember(from project: Project, memberId: UUID) {
        var updatedProject = project
        updatedProject.teamMembers.removeAll { $0.id == memberId }
        updateProject(updatedProject)
    }
    
    func shareProject(_ project: Project, withEmail email: String) -> String {
        // Generate invitation link (simplified version)
        let inviteCode = project.id.uuidString.prefix(8)
        return "taskmingle://join/\(inviteCode)"
    }
    
    // MARK: - User Management
    
    func setUserEmail(_ email: String) {
        currentUserEmail = email
        UserDefaults.standard.set(email, forKey: userEmailKey)
    }
    
    private func loadUserEmail() {
        currentUserEmail = UserDefaults.standard.string(forKey: userEmailKey) ?? ""
    }
    
    // MARK: - Persistence
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    func resetAllData() {
        projects = []
        currentUserEmail = ""
        UserDefaults.standard.removeObject(forKey: projectsKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
    }
}

