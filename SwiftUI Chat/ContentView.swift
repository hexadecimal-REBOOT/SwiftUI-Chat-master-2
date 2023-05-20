import SwiftUI

struct ChatMessage : Hashable, Identifiable {
    var id = UUID()
    var message: String
    var avatar: String
    var color: Color
    var isMe: Bool = false
}

        // This function should take the user's message, send it to the API, and call the completion handler with the model's response.
    

class ContentViewViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private let apiManager = OpenAIAPIManager()

    func sendMessage(_ content: String) {
        let newMessage = ChatMessage(message: content, avatar: "C", color: .green, isMe: true)
        messages.append(newMessage)
        apiManager.chatWithGPT3(userMessage: content) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let assistantResponse):
                    let assistantMessage = ChatMessage(message: assistantResponse, avatar: "A", color: .blue, isMe: false)
                    self?.messages.append(assistantMessage)
                case .failure(let error):
                    // Handle error
                    print("Error occurred while chatting with GPT3: \(error)")
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @State private var composedMessage: String = ""

    var body: some View {
        VStack {
            List(viewModel.messages) { msg in
                ChatRow(chatMessage: msg)
            }
            HStack {
                TextField("Message...", text: $composedMessage).frame(minHeight: CGFloat(30))
                Button(action: {
                    viewModel.sendMessage(composedMessage)
                    composedMessage = ""
                }) {
                    Text("Send")
                }
            }.frame(minHeight: CGFloat(50)).padding()
        }
    }
}

struct ChatRow : View {
    var chatMessage: ChatMessage
    var body: some View {
        Group {
            if !chatMessage.isMe {
                HStack {
                    Group {
                        Text(chatMessage.avatar)
                        Text(chatMessage.message)
                            .bold()
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(chatMessage.color)
                            .cornerRadius(10)
                    }
                }
            } else {
                HStack {
                    Group {
                        Spacer()
                        Text(chatMessage.message)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(chatMessage.color)
                        .cornerRadius(10)
                        Text(chatMessage.avatar)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(ContentViewViewModel())
    }
}

