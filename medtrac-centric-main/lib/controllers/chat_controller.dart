import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage({required this.text, required this.isMe});
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[
    ChatMessage(text: 'Hello, how are you?', isMe: false),
    ChatMessage(text: 'I am good, thank you! How about you?', isMe: true),
    ChatMessage(text: 'I am doing well. Are you ready for your session?', isMe: false),
    ChatMessage(text: 'Yes, I am!', isMe: true),
    ChatMessage(text: 'Great, let’s get started.', isMe: false),
    ChatMessage(text: 'Sure!', isMe: true),
  ].obs;
}
