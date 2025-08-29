// Copyright 2025 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI
import Foundation
import AppKit

struct AIChatView: View {
    @State private var chatManager = ChatManager()
    @State private var aiSettings = AISettings()
    @State private var selectedSession: ChatSession?
    @State private var showingSettings = false
    @State private var currentMessage = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        HSplitView {
            // Sidebar - Chat History
            ChatSidebarView(
                chatManager: chatManager,
                selectedSession: $selectedSession,
                showingSettings: $showingSettings
            )
            .frame(minWidth: 220, maxWidth: 300)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Main Chat Area
            ChatContentView(
                chatManager: chatManager,
                aiSettings: aiSettings,
                selectedSession: $selectedSession,
                currentMessage: $currentMessage,
                isLoading: $isLoading,
                errorMessage: $errorMessage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            chatManager.loadChatSessions()
            
            // Create first session if none exist
            if chatManager.chatSessions.isEmpty {
                let newSession = chatManager.createNewChat()
                selectedSession = newSession
            } else {
                selectedSession = chatManager.chatSessions.first
            }
        }
        .sheet(isPresented: $showingSettings) {
            AISettingsView(settings: aiSettings)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Chat Sidebar

struct ChatSidebarView: View {
    let chatManager: ChatManager
    @Binding var selectedSession: ChatSession?
    @Binding var showingSettings: Bool
    
    @State private var showingRenameAlert = false
    @State private var sessionToRename: ChatSession?
    @State private var newChatTitle = ""
    @State private var searchText = ""
    @State private var settingsButtonHovered = false
    @State private var newChatButtonHovered = false
    
    private var filteredChatSessions: [ChatSession] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return chatManager.chatSessions
        } else {
            let search = searchText.lowercased()
            return chatManager.chatSessions.filter { session in
                // Search in title
                if session.title.lowercased().contains(search) {
                    return true
                }
                // Search in message content
                return session.messages.contains { message in
                    message.content.lowercased().contains(search)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Text("AI Chat")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(
                                settingsButtonHovered 
                                ? Color.secondary.opacity(0.1)
                                : Color.clear
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Settings")
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            settingsButtonHovered = hovering
                        }
                    }
                    
                    Button(action: createNewChat) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(
                                newChatButtonHovered 
                                ? Color.secondary.opacity(0.1)
                                : Color.clear
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("New Chat")
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            newChatButtonHovered = hovering
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Search Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search conversations...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: { 
                            withAnimation(.easeInOut(duration: 0.2)) {
                                searchText = "" 
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Search Results Count
            if !searchText.isEmpty {
                HStack {
                    Text("\(filteredChatSessions.count) result\(filteredChatSessions.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                .background(Color(NSColor.controlBackgroundColor))
            }
            
            // Chat List
            if chatManager.chatSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No chats yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Click the + button to start your first AI chat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredChatSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No matching chats")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Try different search terms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredChatSessions, selection: $selectedSession) { session in
                    ChatSessionRow(
                        session: session, 
                        searchText: searchText,
                        isSelected: selectedSession?.id == session.id
                    )
                        .onTapGesture {
                            selectedSession = session
                        }
                        .contextMenu {
                            Button("Rename") {
                                sessionToRename = session
                                newChatTitle = session.title
                                showingRenameAlert = true
                            }
                            Button("Duplicate") {
                                duplicateChat(session)
                            }
                            Button("Export...") {
                                exportChat(session)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                deleteChat(session)
                            }
                        }
                }
            }
        }
        .frame(minWidth: 220)
        .alert("Rename Chat", isPresented: $showingRenameAlert) {
            TextField("Chat Title", text: $newChatTitle)
            Button("Cancel") {
                sessionToRename = nil
                newChatTitle = ""
            }
            Button("Rename") {
                if let session = sessionToRename {
                    renameChat(session, to: newChatTitle)
                }
                sessionToRename = nil
                newChatTitle = ""
            }
            .disabled(newChatTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Enter a new title for this chat")
        }
    }
    
    private func createNewChat() {
        let newSession = chatManager.createNewChat()
        selectedSession = newSession
    }
    
    private func duplicateChat(_ session: ChatSession) {
        let duplicated = chatManager.duplicateChat(session)
        selectedSession = duplicated
    }
    
    private func deleteChat(_ session: ChatSession) {
        chatManager.deleteChat(session)
        
        // Select another session if current was deleted
        if selectedSession?.id == session.id {
            selectedSession = chatManager.chatSessions.first
        }
    }
    
    private func renameChat(_ session: ChatSession, to newTitle: String) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            chatManager.renameChat(session, to: trimmedTitle)
        }
    }
    
    private func exportChat(_ session: ChatSession) {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Chat"
        savePanel.nameFieldStringValue = "\(session.title).md"
        savePanel.allowedContentTypes = [.plainText, .init(filenameExtension: "md") ?? .plainText]
        savePanel.canCreateDirectories = true
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            let content = generateExportContent(for: session)
            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
                print("✅ Chat exported to: \(url.path)")
            } catch {
                print("❌ Failed to export chat: \(error)")
            }
        }
    }
    
    private func generateExportContent(for session: ChatSession) -> String {
        var content = "# \(session.title)\n\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        
        content += "**Exported:** \(formatter.string(from: Date()))\n"
        content += "**Created:** \(formatter.string(from: session.createdAt))\n"
        content += "**Messages:** \(session.messages.count)\n\n"
        content += "---\n\n"
        
        for message in session.messages {
            let timestamp = DateFormatter.localizedString(from: message.timestamp, dateStyle: .none, timeStyle: .short)
            
            switch message.role {
            case .user:
                content += "## 👤 You (\(timestamp))\n\n"
                content += message.content + "\n\n"
            case .assistant:
                content += "## 🤖 Assistant (\(timestamp))\n\n"
                content += message.content + "\n\n"
            case .system:
                content += "## ⚙️ System (\(timestamp))\n\n"
                content += message.content + "\n\n"
            }
        }
        
        return content
    }
}

struct ChatSessionRow: View {
    let session: ChatSession
    var searchText: String = ""
    var isSelected: Bool = false
    @State private var isHovered = false
    
    private var previewText: String {
        if let firstUserMessage = session.messages.first(where: { $0.role == .user }) {
            return firstUserMessage.content
        }
        return "New conversation"
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: session.updatedAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.title)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .opacity(isHovered ? 1.0 : 0.7)
                }
                
                Text(previewText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected 
                    ? Color.secondary.opacity(0.2)
                    : (isHovered ? Color.secondary.opacity(0.1) : Color.clear)
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Chat Content

struct ChatContentView: View {
    let chatManager: ChatManager
    let aiSettings: AISettings
    @Binding var selectedSession: ChatSession?
    @Binding var currentMessage: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if let session = selectedSession {
                // Chat Header
                ChatHeaderView(
                    chatManager: chatManager,
                    sessionId: session.id,
                    aiSettings: aiSettings
                )
                
                Divider()
                
                // Messages
                ChatMessagesView(
                    chatManager: chatManager,
                    sessionId: session.id,
                    isLoading: isLoading
                )
                
                // Input Area
                ChatInputView(
                    currentMessage: $currentMessage,
                    isLoading: isLoading,
                    selectedModel: session.selectedModel ?? aiSettings.defaultModel,
                    onSend: { sendMessage() }
                )
            } else {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("Welcome to AI Chat")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select a chat from the sidebar or create a new one to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Create New Chat") {
                        let newSession = chatManager.createNewChat()
                        selectedSession = newSession
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func sendMessage() {
        guard let session = selectedSession,
              !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !isLoading else { 
            print("❌ UI: sendMessage guard failed - session: \(selectedSession?.id.uuidString ?? "nil"), message empty: \(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty), loading: \(isLoading)")
            return 
        }
        
        print("📱 UI: Sending message: '\(currentMessage.prefix(50))...'")
        
        
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        currentMessage = ""
        
        Task {
            await chatManager.sendMessage(
                messageText,
                in: session.id,
                with: aiSettings,
                isLoading: $isLoading,
                errorMessage: $errorMessage
            )
        }
    }
}

struct ChatHeaderView: View {
    let chatManager: ChatManager
    let sessionId: UUID
    let aiSettings: AISettings
    
    private var currentSession: ChatSession? {
        return chatManager.chatSessions.first(where: { $0.id == sessionId })
    }
    
    private var selectedModel: AIModel {
        return currentSession?.selectedModel ?? aiSettings.defaultModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentSession?.title ?? "New Chat")
                    .font(.body)
                    .lineLimit(1).background(Color.gray).padding(0)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(aiSettings.hasOpenAIAPIKey() ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(currentSession?.selectedModel != nil ? "\(selectedModel.displayName) (Custom)" : "\(selectedModel.displayName) (Default)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }.background(Color.green).padding(0)
            
            Spacer()
            
            HStack(spacing: 12) {
                // Model selector dropdown
                Menu {
                    if currentSession?.selectedModel != nil {
                        Button("Reset to Default (\(aiSettings.defaultModel.displayName))") {
                            resetToDefaultModel()
                        }
                        Divider()
                    }
                    
                    ForEach(AIModel.allModels, id: \.id) { model in
                        Button(action: {
                            updateChatModel(model)
                        }) {
                            HStack {
                                Text(model.displayName)
                                if model.id == selectedModel.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedModel.displayName)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Change model for this chat")
                
                Text("\(currentSession?.messages.count ?? 0) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppConstants.sectionBackground)
    }
    
    private func updateChatModel(_ model: AIModel) {
        if let sessionIndex = chatManager.chatSessions.firstIndex(where: { $0.id == sessionId }) {
            chatManager.chatSessions[sessionIndex].selectedModel = model
            // Save the updated session
            let storage = ChatStorage()
            storage.saveChatSession(chatManager.chatSessions[sessionIndex])
            print("✅ Updated chat model to: \(model.displayName)")
        }
    }
    
    private func resetToDefaultModel() {
        if let sessionIndex = chatManager.chatSessions.firstIndex(where: { $0.id == sessionId }) {
            chatManager.chatSessions[sessionIndex].selectedModel = nil
            // Save the updated session
            let storage = ChatStorage()
            storage.saveChatSession(chatManager.chatSessions[sessionIndex])
            print("✅ Reset chat to default model: \(aiSettings.defaultModel.displayName)")
        }
    }
}

struct ChatMessagesView: View {
    let chatManager: ChatManager
    let sessionId: UUID
    let isLoading: Bool
    @State private var showScrollToBottom = false
    @State private var scrollViewHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    private var currentSession: ChatSession? {
        return chatManager.chatSessions.first(where: { $0.id == sessionId })
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(currentSession?.messages ?? []) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                        
                        // Invisible marker at the bottom
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(16)
                }
                .onAppear {
                    // Show scroll button if there are enough messages
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showScrollToBottom = (currentSession?.messages.count ?? 0) > 3
                        }
                    }
                }
                .onChange(of: currentSession?.messages.count) { _, newCount in
                    // Auto-scroll to new messages
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                    
                    // Show/hide scroll button based on message count
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showScrollToBottom = (newCount ?? 0) > 3
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    if newValue {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: currentSession?.messages.last?.content) { _, _ in
                    // Auto-scroll during streaming updates
                    if let lastMessage = currentSession?.messages.last, lastMessage.isStreaming {
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                
                // Scroll to bottom button
                if showScrollToBottom {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }) {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.textBackgroundColor))
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    @State private var isHovered = false
    @State private var showCopiedFeedback = false
    
    private var isUser: Bool {
        message.role == .user
    }
    
    private var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    private func copyMessageContent() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
        
        // Show feedback
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedFeedback = true
        }
        
        // Hide feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopiedFeedback = false
            }
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            // Message Content
            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                Group {
                    if isUser {
                        // User messages: modern bubble
                        HStack {
                            Spacer(minLength: 60)
                            
                            Text(message.content)
                                .font(.body)
                                //.foregroundColor(.white)
                                .textSelection(.enabled)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    } else {
                        // Assistant messages: modern bubble with markdown or image
                        HStack {
                            if message.contentType == .image {
                                // Image message
                                VStack(alignment: .leading, spacing: 8) {
                                    if message.isStreaming {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text(message.content)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    } else if let imageURL = message.imageURL {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 200, height: 200)
                                        }
                                        .frame(maxWidth: 300, maxHeight: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        
                                        if !message.content.isEmpty {
                                            Text(message.content)
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 4)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                // Text message with markdown
                                MarkdownView(content: message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            
                            Spacer(minLength: 60)
                        }
                    }
                }
                
                // Always visible timestamp and actions
                HStack {
                    if !isUser {
                        // Assistant message actions (left aligned)
                        HStack(spacing: 8) {
                            Text(timeStamp)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Button(action: copyMessageContent) {
                                if showCopiedFeedback {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10))
                                        Text("Copied")
                                            .font(.system(size: 10))
                                    }
                                    .foregroundColor(.green)
                                    .transition(.opacity)
                                } else {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Copy message")
                            .opacity(isHovered || showCopiedFeedback ? 1.0 : 0.6)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    } else {
                        // User message actions (right aligned)
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: copyMessageContent) {
                                if showCopiedFeedback {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10))
                                        Text("Copied")
                                            .font(.system(size: 10))
                                    }
                                    .foregroundColor(.green)
                                    .transition(.opacity)
                                } else {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Copy message")
                            .opacity(isHovered || showCopiedFeedback ? 1.0 : 0.6)
                            
                            Text(timeStamp)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .animation(.easeInOut(duration: 0.2), value: showCopiedFeedback)
                
                if message.isStreaming && message.content.isEmpty {
                    HStack {
                        if !isUser {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                                Text("AI is thinking...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                            .padding(.top, 6)
                            Spacer()
                        }
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct ChatInputView: View {
    @Binding var currentMessage: String
    let isLoading: Bool
    let selectedModel: AIModel
    let onSend: () -> Void
    
    var body: some View {
        // Clean input area without section background - just the input box
        HStack(alignment: .bottom, spacing: 0) {
            // Text Input with integrated send button
            HStack(alignment: .bottom, spacing: 8) {
                // Auto-expanding TextEditor
                TextEditor(text: $currentMessage)
                    .font(.system(size: 16))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 24, maxHeight: 200) // Allow more expansion like ChatGPT
                    .disabled(isLoading)
                    .overlay(alignment: .topLeading) {
                        if currentMessage.isEmpty {
                            Text(selectedModel.type == .image ? "Describe the image you want to generate..." : "Message")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .background(Color.clear)
                                .allowsHitTesting(false)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                
                // Send Button (integrated inside the input area)
                Button(action: onSend) {
                    Circle()
                        .fill(
                            currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading 
                            ? Color.secondary.opacity(0.3)
                            : Color.accentColor
                        )
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(systemName: isLoading ? "stop.fill" : "arrow.up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isLoading ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isLoading)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading)
                .padding(.bottom, 4) // Align with text baseline
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        // No section background - just transparent
        .background(Color.clear)
    }
}

// MARK: - ScrollOffset Preference Key for scroll position detection

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    AIChatView()
}

// MARK: - Markdown Rendering

struct MarkdownView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(parseMarkdown(content), id: \.id) { element in
                renderMarkdownElement(element)
            }
        }
    }
    
    private func parseMarkdown(_ text: String) -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = text.components(separatedBy: .newlines)
        var i = 0
        
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            
            if line.isEmpty {
                elements.append(.spacing)
                i += 1
                continue
            }
            
            // Code blocks
            if line.hasPrefix("```") {
                let language = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                
                elements.append(.codeBlock(code: codeLines.joined(separator: "\n"), language: language))
                i += 1
                continue
            }
            
            // Headers
            if line.hasPrefix("# ") {
                elements.append(.header(level: 1, text: String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                elements.append(.header(level: 2, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                elements.append(.header(level: 3, text: String(line.dropFirst(4))))
            } else if line.hasPrefix("#### ") {
                elements.append(.header(level: 4, text: String(line.dropFirst(5))))
            } else if line.hasPrefix("##### ") {
                elements.append(.header(level: 5, text: String(line.dropFirst(6))))
            } else if line.hasPrefix("###### ") {
                elements.append(.header(level: 6, text: String(line.dropFirst(7))))
            } 
            // Lists
            else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                elements.append(.listItem(text: String(line.dropFirst(2))))
            }
            // Numbered lists
            else if line.range(of: #"^\d+\. "#, options: .regularExpression) != nil {
                let text = line.replacingOccurrences(of: #"^\d+\. "#, with: "", options: .regularExpression)
                elements.append(.numberedListItem(text: text))
            }
            // Blockquotes
            else if line.hasPrefix("> ") {
                elements.append(.blockquote(text: String(line.dropFirst(2))))
            }
            // Regular paragraph
            else {
                elements.append(.paragraph(text: line))
            }
            
            i += 1
        }
        
        return elements
    }
    
    @ViewBuilder
    private func renderMarkdownElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .header(let level, let text):
            HStack {
                Text(renderInlineMarkdown(text))
                    .font(headerFont(for: level))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, headerPadding(for: level))
            
        case .paragraph(let text):
            HStack {
                Text(renderInlineMarkdown(text))
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
            
        case .codeBlock(let code, let language):
            VStack(alignment: .leading, spacing: 4) {
                if !language.isEmpty {
                    HStack {
                        Text(language.uppercased())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Spacer()
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                        Spacer()
                    }
                    .padding(12)
                }
                .background(AppConstants.controlBackground.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.vertical, 8)
            
        case .listItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                Text(renderInlineMarkdown(text))
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.vertical, 2)
            
        case .numberedListItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("1.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                Text(renderInlineMarkdown(text))
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.vertical, 2)
            
        case .blockquote(let text):
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 4)
                VStack(alignment: .leading) {
                    Text(renderInlineMarkdown(text))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.leading, 16)
            
        case .spacing:
            Spacer()
                .frame(height: 8)
        }
    }
    
    private func renderInlineMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Bold **text**
        let boldPattern = #"\*\*(.*?)\*\*"#
        attributedString = processInlinePattern(in: attributedString, pattern: boldPattern) { range, match in
            attributedString[range].font = .body.bold()
            return String(match.dropFirst(2).dropLast(2))
        }
        
        // Italic *text*
        let italicPattern = #"\*(.*?)\*"#
        attributedString = processInlinePattern(in: attributedString, pattern: italicPattern) { range, match in
            attributedString[range].font = .body.italic()
            return String(match.dropFirst().dropLast())
        }
        
        // Inline code `text`
        let codePattern = #"`(.*?)`"#
        attributedString = processInlinePattern(in: attributedString, pattern: codePattern) { range, match in
            attributedString[range].font = .system(.body, design: .monospaced)
            attributedString[range].backgroundColor = Color.secondary.opacity(0.3)
            return String(match.dropFirst().dropLast())
        }
        
        return attributedString
    }
    
    private func processInlinePattern(
        in attributedString: AttributedString, 
        pattern: String,
        transform: (Range<AttributedString.Index>, String) -> String
    ) -> AttributedString {
        var result = attributedString
        let string = String(attributedString.characters)
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            // Process matches in reverse order to maintain index validity
            for match in matches.reversed() {
                if let range = Range(match.range, in: string) {
                    let matchText = String(string[range])
                    let replacementText = transform(
                        result.range(of: matchText) ?? result.startIndex..<result.endIndex,
                        matchText
                    )
                    
                    if let attributedRange = result.range(of: matchText) {
                        result.replaceSubrange(attributedRange, with: AttributedString(replacementText))
                    }
                }
            }
        } catch {
            // Return original if regex fails
            return result
        }
        
        return result
    }
    
    private func headerFont(for level: Int) -> Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3: return .title2
        case 4: return .title3
        case 5: return .headline
        case 6: return .subheadline
        default: return .body
        }
    }
    
    private func headerPadding(for level: Int) -> CGFloat {
        switch level {
        case 1: return 12
        case 2: return 10
        case 3: return 8
        case 4: return 6
        case 5: return 4
        case 6: return 2
        default: return 0
        }
    }
}

enum MarkdownElement {
    case header(level: Int, text: String)
    case paragraph(text: String)
    case codeBlock(code: String, language: String)
    case listItem(text: String)
    case numberedListItem(text: String)
    case blockquote(text: String)
    case spacing
    
    var id: String {
        switch self {
        case .header(let level, let text): return "h\(level)-\(text.hashValue)"
        case .paragraph(let text): return "p-\(text.hashValue)"
        case .codeBlock(let code, let language): return "code-\(language)-\(code.hashValue)"
        case .listItem(let text): return "li-\(text.hashValue)"
        case .numberedListItem(let text): return "nli-\(text.hashValue)"
        case .blockquote(let text): return "bq-\(text.hashValue)"
        case .spacing: return "sp-\(UUID().uuidString)"
        }
    }
}
