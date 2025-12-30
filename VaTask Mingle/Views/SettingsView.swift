import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = UserSettingsViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile section
                        profileSection
                        
                        // Statistics section
                        statisticsSection
                        
                        // Preferences section
                        preferencesSection
                        
                        // Notifications section
                        notificationsSection
                        
                        // Danger zone
                        dangerZoneSection
                        
                        // App info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(.appAccent)
        .alert("Удалить аккаунт?", isPresented: $showingDeleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Все ваши данные будут удалены безвозвратно. Приложение будет сброшено к начальному состоянию.")
        }
    }
    
    private var profileSection: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Профиль")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.appAccent)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Пользователь")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            if !viewModel.userEmail.isEmpty {
                                Text(viewModel.userEmail)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text("Email")
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("email@example.com", text: $viewModel.userEmail)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .onChange(of: viewModel.userEmail) { _ in
                                viewModel.saveEmail()
                            }
                    }
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Статистика")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    StatRow(icon: "folder.fill", title: "Проектов", value: "\(viewModel.totalProjects)")
                    Divider().background(Color.white.opacity(0.2))
                    StatRow(icon: "list.bullet", title: "Всего задач", value: "\(viewModel.totalTasks)")
                    Divider().background(Color.white.opacity(0.2))
                    StatRow(icon: "checkmark.circle.fill", title: "Завершено", value: "\(viewModel.completedTasks)")
                    
                    if viewModel.totalTasks > 0 {
                        Divider().background(Color.white.opacity(0.2))
                        let completionRate = Int((Double(viewModel.completedTasks) / Double(viewModel.totalTasks)) * 100)
                        StatRow(icon: "chart.bar.fill", title: "Эффективность", value: "\(completionRate)%")
                    }
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Предпочтения")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Toggle("Показывать завершённые задачи", isOn: $viewModel.showCompletedTasks)
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                        .foregroundColor(.white)
                        .onChange(of: viewModel.showCompletedTasks) { _ in
                            viewModel.saveSettings()
                        }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text("Приоритет по умолчанию")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(Task.Priority.allCases, id: \.self) { priority in
                                Button(priority.rawValue) {
                                    viewModel.defaultPriority = priority
                                    viewModel.saveSettings()
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.defaultPriority.rawValue)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Уведомления")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Toggle("Включить уведомления", isOn: $viewModel.notificationsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                    .foregroundColor(.white)
                    .onChange(of: viewModel.notificationsEnabled) { _ in
                        viewModel.saveSettings()
                    }
                
                Text("Получайте напоминания о задачах и дедлайнах")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    private var dangerZoneSection: some View {
        NeumorphicCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Опасная зона")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Удалить аккаунт")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(NeumorphicButtonStyle(color: .red.opacity(0.7)))
                
                Text("Это действие удалит все ваши данные и вернёт приложение к начальному состоянию.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.appAccent)
            
            Text("TaskMingle")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Версия 1.0.0")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
            
            Text("© 2024 TaskMingle. Все права защищены.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
    }
    
    private func deleteAccount() {
        viewModel.deleteAccount()
        hasCompletedOnboarding = false
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appAccent)
                .frame(width: 25)
            
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SettingsView()
}

