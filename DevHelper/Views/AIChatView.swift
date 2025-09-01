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
import MarkdownUI

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
            // .padding(.top, 44)
            // .ignoresSafeArea(edges: .top)
            
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
            // .padding(.top, 44)
            // .ignoresSafeArea(edges: .top)
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
    
    // Detect current color scheme
    @Environment(\.colorScheme) var colorScheme
    
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
                    .fontWeight(.medium)
                    .padding(.leading, 8)
                
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
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search conversations...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
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
            .background(colorScheme == .dark ? AppConstants.controlBackground : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.bottom, 2)
            
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
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
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
                    chatManager: chatManager,
                    sessionId: session.id,
                    onSendWithText: { messageText in
                        sendMessageDirectly(messageText)
                    },
                    onSendWithImages: { messageText, images in
                        sendMessageWithImages(messageText, images: images)
                    },
                    onSendWithTool: { messageText, tool in
                        sendMessageWithTool(messageText, tool: tool)
                    },
                    onToolChanged: { newTool in
                        updateSessionTool(newTool)
                    }
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
    
    private func sendMessageDirectly(_ messageText: String) {
        guard let session = selectedSession, !isLoading else { 
            print("❌ UI: sendMessageDirectly guard failed - session: \(selectedSession?.id.uuidString ?? "nil"), loading: \(isLoading)")
            return 
        }
        
        print("📱 UI: Sending message directly: '\(messageText.prefix(50))...'")
        
        // Track AI Chat message event
        EventManager.shared.reportAIChatMessage(messageLength: messageText.count)
        
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
    
    private func sendMessageWithImages(_ messageText: String, images: [ChatMessageImage]) {
        guard let session = selectedSession, !isLoading else { 
            print("❌ UI: sendMessageWithImages guard failed - session: \(selectedSession?.id.uuidString ?? "nil"), loading: \(isLoading)")
            return 
        }
        
        print("📱 UI: Sending message with \(images.count) images: '\(messageText.prefix(50))...'")
        
        // Track AI Chat message event (including images)
        EventManager.shared.reportAIChatMessage(messageLength: messageText.count)
        
        Task {
            await chatManager.sendMessageWithImages(
                messageText,
                images: images,
                in: session.id,
                with: aiSettings,
                isLoading: $isLoading,
                errorMessage: $errorMessage
            )
        }
    }
    
    private func sendMessageWithTool(_ messageText: String, tool: ChatToolMode) {
        guard let session = selectedSession, !isLoading else { 
            print("❌ UI: sendMessageWithTool guard failed - session: \(selectedSession?.id.uuidString ?? "nil"), loading: \(isLoading)")
            return 
        }
        
        print("📱 UI: Sending message with tool \(tool.displayName): '\(messageText.prefix(50))...'")
        
        // Track AI Chat message event
        EventManager.shared.reportAIChatMessage(messageLength: messageText.count)
        
        Task {
            await chatManager.sendMessageWithTool(
                messageText,
                tool: tool,
                in: session.id,
                with: aiSettings,
                isLoading: $isLoading,
                errorMessage: $errorMessage
            )
        }
    }
    
    private func updateSessionTool(_ newTool: ChatToolMode) {
        guard let sessionIndex = chatManager.chatSessions.firstIndex(where: { $0.id == selectedSession?.id }) else {
            print("❌ UI: Could not find session to update tool")
            return
        }
        
        print("📱 UI: Updating session tool to: \(newTool.displayName)")
        chatManager.updateSessionTool(at: sessionIndex, tool: newTool)
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
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(aiSettings.hasOpenAIAPIKey() ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(currentSession?.selectedModel != nil ? "\(selectedModel.displayName) (Custom)" : "\(selectedModel.displayName) (Default)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
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
    @State private var isAtBottom = false
    
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
                                .onAppear {
                                    // If this is the last message, user is at bottom
                                    if message.id == currentSession?.messages.last?.id {
                                        isAtBottom = true
                                    }
                                }
                                .onDisappear {
                                    // If this is the last message, user is not at bottom
                                    if message.id == currentSession?.messages.last?.id {
                                        isAtBottom = false
                                    }
                                }
                        }
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
                .onChange(of: sessionId) { _, _ in
                    // When session changes, scroll to the last message instead of "bottom" anchor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessage = currentSession?.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                        showScrollToBottom = (currentSession?.messages.count ?? 0) > 3
                    }
                }
                .onChange(of: currentSession?.messages.count) { _, newCount in
                    // Show/hide scroll button based on message count
                    showScrollToBottom = (newCount ?? 0) > 3
                }
                .onChange(of: currentSession?.messages.last?.content) { _, _ in
                    // Auto-scroll during streaming updates to follow the conversation
                    if let lastMessage = currentSession?.messages.last, lastMessage.isStreaming {
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Scroll to bottom button (only show when not at bottom and has messages)
                if showScrollToBottom && !isAtBottom {
                    Button(action: {
                        if let lastMessage = currentSession?.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 32, height: 32)
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
    @State private var showImagePreview = false
    
    private var isUser: Bool {
        message.role == .user
    }
    
    private var timeStamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    private func copyMessageContent() {
        if message.contentType == .image {
            // Copy image to clipboard
            if let imageURL = message.effectiveImageURL, let url = URL(string: imageURL) {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = NSImage(data: data) {
                            DispatchQueue.main.async {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setData(image.tiffRepresentation, forType: .tiff)
                                
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
                        }
                    } catch {
                        print("❌ Failed to copy image: \(error)")
                    }
                }
            }
        } else {
            // Copy text content
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
    }
    
    private func saveImage() {
        guard message.contentType == .image,
              let imageURL = message.effectiveImageURL,
              let url = URL(string: imageURL) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    let savePanel = NSSavePanel()
                    savePanel.title = "Save Generated Image"
                    savePanel.nameFieldStringValue = "generated_image.png"
                    savePanel.allowedContentTypes = [.png, .jpeg]
                    savePanel.canCreateDirectories = true
                    
                    if savePanel.runModal() == .OK, let saveURL = savePanel.url {
                        do {
                            try data.write(to: saveURL)
                            print("✅ Image saved to: \(saveURL.path)")
                        } catch {
                            print("❌ Failed to save image: \(error)")
                        }
                    }
                }
            } catch {
                print("❌ Failed to download image: \(error)")
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
                                    } else if message.hasImages {
                                        // Display multiple images
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Display all images in a grid or horizontal scroll
                                            if message.images.count > 1 {
                                                // Multiple images in a grid
                                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: min(2, message.images.count)), spacing: 4) {
                                                    ForEach(message.images) { imageItem in
                                                        AsyncImage(url: URL(string: imageItem.effectiveImageURL ?? "")) { image in
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                        } placeholder: {
                                                            Rectangle()
                                                                .fill(Color.secondary.opacity(0.3))
                                                                .overlay {
                                                                    ProgressView()
                                                                }
                                                        }
                                                        .frame(width: 150, height: 150)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .onTapGesture {
                                                            // TODO: Show full image preview
                                                        }
                                                    }
                                                }
                                            } else if let firstImage = message.images.first {
                                                // Single image - larger display
                                                AsyncImage(url: URL(string: firstImage.effectiveImageURL ?? "")) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(width: 200, height: 200)
                                                }
                                                .frame(maxWidth: 300, maxHeight: 300)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .onTapGesture {
                                                    // TODO: Show full image preview
                                                }
                                            } else if let imageURL = message.effectiveImageURL {
                                                // Legacy single image support (inside hasImages block)
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
                                                .onTapGesture {
                                                    print("🖼️ Image tapped - imageURL: \(message.imageURL ?? "nil")")
                                                    showImagePreview = true
                                                }
                                                .help("Click to view full size")
                                                .overlay(alignment: .topTrailing) {
                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.6))
                                                        .clipShape(Circle())
                                                        .padding(8)
                                                }
                                            }
                                            
                                            // Display text content if present
                                            if !message.content.isEmpty {
                                                Text(message.content)
                                                    .textSelection(.enabled)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    } else if let imageURL = message.effectiveImageURL {
                                        // Legacy single image support
                                        VStack(alignment: .leading, spacing: 8) {
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
                                            .onTapGesture {
                                                print("🖼️ Image tapped - imageURL: \(message.imageURL ?? "nil")")
                                                showImagePreview = true
                                            }
                                            .help("Click to view full size")
                                            .overlay(alignment: .topTrailing) {
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                                    .opacity(isHovered ? 1.0 : 0.0)
                                                    .animation(.easeInOut(duration: 0.2), value: isHovered)
                                                    .padding(8)
                                            }
                                            
                                            if !message.content.isEmpty {
                                                Text(message.content)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                // Text message with MarkdownUI library
                                VStack {
                                    Markdown(message.content)
                                        .textSelection(.enabled)
                                        .markdownBlockStyle(\.codeBlock) { configuration in
                                            configuration.label
                                                .padding(12)
                                                .background(Color(NSColor.textBackgroundColor))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .markdownTextStyle {
                                                    FontFamilyVariant(.monospaced)
                                                    FontSize(13)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            
                            Spacer(minLength: 60)
                        }
                    }
                }
                
                // Timestamp and actions (only show when not streaming)
                if !message.isStreaming {
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
                                        Image(systemName: message.contentType == .image ? "photo.on.rectangle" : "doc.on.doc")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help(message.contentType == .image ? "Copy image" : "Copy message")
                                .opacity(isHovered || showCopiedFeedback ? 1.0 : 0.6)
                                
                                // Save button for images
                                if message.contentType == .image {
                                    Button(action: saveImage) {
                                        Image(systemName: "square.and.arrow.down")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .help("Save image")
                                    .opacity(isHovered ? 1.0 : 0.6)
                                }
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
                }
                
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
        .sheet(isPresented: $showImagePreview) {
            if let imageURL = message.effectiveImageURL {
                ImagePreviewView(imageURL: imageURL, prompt: message.imagePrompt ?? "Generated Image")
            } else {
                Text("No image URL available")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

struct ChatInputView: View {
    @Binding var currentMessage: String
    let isLoading: Bool
    let selectedModel: AIModel
    let chatManager: ChatManager
    let sessionId: UUID
    let onSendWithText: (String) -> Void
    let onSendWithImages: (String, [ChatMessageImage]) -> Void
    let onSendWithTool: (String, ChatToolMode) -> Void
    let onToolChanged: (ChatToolMode) -> Void
    
    @State private var selectedImages: [ChatMessageImage] = []
    
    private var selectedTool: ChatToolMode {
        if let session = chatManager.chatSessions.first(where: { $0.id == sessionId }) {
            return session.selectedTool
        }
        return .chat
    }
    
    // Calculate dynamic height based on content
    private var calculatedHeight: CGFloat {
        let lineHeight: CGFloat = 20
        let padding: CGFloat = 60
        let toolbarHeight: CGFloat = 40
        let minHeight: CGFloat = lineHeight + padding + toolbarHeight
        let maxHeight: CGFloat = 200
        
        if currentMessage.isEmpty {
            return minHeight
        }
        
        // Estimate height based on content
        let lineCount = max(1, currentMessage.components(separatedBy: .newlines).count)
        let estimatedHeight = CGFloat(lineCount) * lineHeight + toolbarHeight
        
        return min(maxHeight, max(minHeight, estimatedHeight))
    }

    var body: some View {
        VStack(spacing: 8) {
            // Image preview area (if images are selected)
            if !selectedImages.isEmpty {
                ImagePreviewBar(
                    images: selectedImages,
                    onRemove: { image in
                        selectedImages.removeAll { $0.id == image.id }
                    }
                )
                .padding(.horizontal, 20)
            }
            
            // Input area
            HStack(alignment: .bottom, spacing: 0) {
                // Text Input with overlaid toolbar and send button
                ZStack(alignment: .bottomTrailing) {
                    // Auto-expanding TextEditor (full width)
                    TextEditor(text: $currentMessage)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .frame(height: calculatedHeight)
                        .disabled(isLoading)
                        .onKeyPress { key in
                            print("🔑 onKeyPress key: \(key)")
                            if key.key == .return && !key.modifiers.contains(.shift) {
                                // Enter: Send message
                                sendMessage()
                                return .handled
                            }
                            return .ignored
                        }
                        .overlay(alignment: .topLeading) {
                            if currentMessage.isEmpty {
                                Text(getPlaceholderText())
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .background(Color.clear)
                                    .allowsHitTesting(false)
                                    .padding(.top, 4)
                                    .padding(.leading, 4)
                            }
                        }
                    
                }
                .overlay(alignment: .bottomLeading) {
                    // Tool selection toolbar (floating overlay at bottom-left)
                    HStack(spacing: 4) {
                        // File upload button (plus icon)
                        Button(action: {
                            print("🔄 Plus button clicked")
                            openImagePicker()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 28, height: 28)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Upload images")
                        .disabled(isLoading)
                        
                        // Tool selection buttons
                        ForEach([ChatToolMode.webSearch, ChatToolMode.imageGeneration], id: \.self) { tool in
                            Button(action: {
                                print("🔄 Tool button clicked: \(tool.displayName)")
                                print("🔍 Current selectedTool in UI: \(selectedTool.displayName)")
                                print("🔍 Is tool selected: \(selectedTool == tool)")
                                let newTool = selectedTool == tool ? .chat : tool
                                print("🔍 New tool will be: \(newTool.displayName)")
                                onToolChanged(newTool)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: tool.iconName)
                                        .font(.system(size: 14, weight: .medium))
                                    if selectedTool == tool {
                                        Text(tool.displayName)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                }
                                .foregroundColor(selectedTool == tool ? .white : .secondary)
                                .padding(.horizontal, selectedTool == tool ? 8 : 6)
                                .padding(.vertical, 4)
                                .background(selectedTool == tool ? Color.accentColor : Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .onAppear {
                                    print("🎨 Button \(tool.displayName) appearance - selectedTool: \(selectedTool.displayName), isSelected: \(selectedTool == tool)")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help(tool.displayName)
                            .disabled(isLoading)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom, 8)
                    .padding(.leading, 8)
                    .allowsHitTesting(true)
                }
                .overlay(alignment: .bottomTrailing) {
                    // Send Button (floating overlay at bottom-right)
                    Button(action: sendMessage) {
                        Circle()
                            .fill(
                                canSendMessage()
                                ? Color.accentColor
                                : Color.secondary.opacity(0.3)
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
                    .disabled(!canSendMessage() && !isLoading)
                    .padding(.bottom, 8)
                    .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .animation(.easeInOut(duration: 0.2), value: calculatedHeight)
    }
    
    private func getPlaceholderText() -> String {
        if !selectedImages.isEmpty {
            return "Ask about these images..."
        } else {
            switch selectedTool {
            case .chat:
                return "Ask anything..."
            case .webSearch:
                return "Search the web..."
            case .imageGeneration:
                return "Describe the image you want to generate..."
            }
        }
    }
    
    private func canSendMessage() -> Bool {
        let hasText = !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImages = !selectedImages.isEmpty
        return (hasText || hasImages) && !isLoading
    }
    
    private func sendMessage() {
        let messageToSend = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let imagesToSend = selectedImages
        let toolToUse = selectedTool
        
        if canSendMessage() {
            currentMessage = ""
            selectedImages = []
            // Reset tool selection after sending (optional - you can keep it selected if preferred)
            // selectedTool = .chat
            
            if !imagesToSend.isEmpty {
                onSendWithImages(messageToSend, imagesToSend)
            } else if toolToUse != .chat {
                onSendWithTool(messageToSend, toolToUse)
            } else {
                onSendWithText(messageToSend)
            }
        }
    }
    
    private func handleImageSelection(_ urls: [URL]) {
        Task {
            do {
                var newImages: [ChatMessageImage] = []
                
                for url in urls {
                    let imageId = UUID()
                    let localPath = try await ImageStorageService.shared.saveUploadedImage(from: url, imageId: imageId)
                    
                    let image = ChatMessageImage(
                        localImagePath: localPath,
                        caption: url.lastPathComponent
                    )
                    newImages.append(image)
                }
                
                await MainActor.run {
                    selectedImages.append(contentsOf: newImages)
                }
                
                print("✅ Added \(newImages.count) images for upload")
                
            } catch {
                print("❌ Failed to process uploaded images: \(error)")
            }
        }
    }
    
    private func openImagePicker() {
        let picker = NSOpenPanel()
        picker.title = "Select Images"
        picker.allowsMultipleSelection = true
        picker.canChooseDirectories = false
        picker.canChooseFiles = true
        picker.allowedContentTypes = [.image]
        
        if picker.runModal() == .OK {
            handleImageSelection(picker.urls)
        }
    }
}

// MARK: - ScrollOffset Preference Key for scroll position detection

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ImagePreviewView: View {
    let imageURL: String
    let prompt: String
    @Environment(\.dismiss) private var dismiss
    @State private var imageLoadError: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and buttons
            HStack {
                Text("Generated Image")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    saveImageToFile()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Main image content
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading image...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(0)
                case .failure(let error):
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Failed to load image")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Copy URL") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(imageURL, forType: .string)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    VStack {
                        ProgressView()
                        Text("Unknown state")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(0)
        }
        .frame(width: 800, height: 860)
        .padding(0)
        .onAppear {
            print("🖼️ ImagePreviewView opened with URL: \(imageURL)")
        }
    }
    
    private func saveImageToFile() {
        guard let url = URL(string: imageURL) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    let savePanel = NSSavePanel()
                    savePanel.title = "Save Generated Image"
                    savePanel.nameFieldStringValue = "generated_image.png"
                    savePanel.allowedContentTypes = [.png, .jpeg]
                    savePanel.canCreateDirectories = true
                    
                    if savePanel.runModal() == .OK, let saveURL = savePanel.url {
                        do {
                            try data.write(to: saveURL)
                            print("✅ Image saved to: \(saveURL.path)")
                        } catch {
                            print("❌ Failed to save image: \(error)")
                        }
                    }
                }
            } catch {
                print("❌ Failed to download image: \(error)")
            }
        }
    }
}

// MARK: - Image Upload Components

struct ImagePreviewBar: View {
    let images: [ChatMessageImage]
    let onRemove: (ChatMessageImage) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(images) { image in
                    ImagePreviewThumbnail(image: image, onRemove: onRemove)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 80)
    }
}

struct ImagePreviewThumbnail: View {
    let image: ChatMessageImage
    let onRemove: (ChatMessageImage) -> Void
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Image thumbnail
            AsyncImage(url: URL(string: image.effectiveImageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_), .empty:
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Remove button
            if isHovered {
                Button(action: {
                    onRemove(image)
                }) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 5, y: -5)
                .transition(.opacity)
            }
        }
        .padding(10) // Add padding to accommodate the delete button
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}


#Preview {
    AIChatView()
}

