import Foundation
import Combine

class TaskDetailViewModel: ObservableObject {
    @Published var task: Task
    @Published var newComment: String = ""
    @Published var newMention: String = ""
    @Published var showingShareSheet = false
    
    private let taskService = TaskService.shared
    private let userService = UserService.shared
    
    init(task: Task) {
        self.task = task
    }
    
    var project: Project? {
        guard let projectId = task.projectId else { return nil }
        return userService.projects.first { $0.id == projectId }
    }
    
    func updateTask() {
        taskService.updateTask(task)
    }
    
    func deleteTask() {
        taskService.deleteTask(task)
    }
    
    func addComment() {
        guard !newComment.isEmpty else { return }
        
        let comment = Comment(
            text: newComment,
            author: userService.currentUserEmail.isEmpty ? "Вы" : userService.currentUserEmail,
            createdDate: Date(),
            mentions: extractMentions(from: newComment)
        )
        
        taskService.addComment(to: task, comment: comment)
        
        // Update local task
        task.comments.append(comment)
        newComment = ""
    }
    
    func assignTask(to email: String) {
        if !task.assignedTo.contains(email) {
            task.assignedTo.append(email)
            updateTask()
        }
    }
    
    func removeAssignee(_ email: String) {
        task.assignedTo.removeAll { $0 == email }
        updateTask()
    }
    
    func toggleStatus() {
        taskService.toggleTaskStatus(task)
    }
    
    func setReminder(date: Date) {
        task.reminderDate = date
        updateTask()
    }
    
    private func extractMentions(from text: String) -> [String] {
        let pattern = "@\\w+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let results = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results?.compactMap { result in
            guard let range = Range(result.range, in: text) else { return nil }
            return String(text[range]).replacingOccurrences(of: "@", with: "")
        } ?? []
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

