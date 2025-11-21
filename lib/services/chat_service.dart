import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GenerativeModel _model;

  ChatService() {
    // Initialize the Generative AI model with your actual API key
    const apiKey = 'AIzaSyCUDfL49t1KzrRZMj64cpKLRzz0I2UlERI';
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  // Get a stream of conversations for the current user
  Stream<QuerySnapshot> getConversations() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // Get a stream of messages for a specific conversation
  Stream<QuerySnapshot> getMessages(String conversationId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Create a new conversation and send the first message
  Future<String> createNewConversation(String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // Create the conversation document
    final newConversationRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .add({
      'title': text.substring(0, text.length > 30 ? 30 : text.length),
      'lastMessage': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    // Add the first message
    await sendMessage(text, conversationId: newConversationRef.id);

    return newConversationRef.id;
  }

  // Send a message to an existing conversation
  Future<void> sendMessage(String text, {required String conversationId}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userMessage = {
      'message': text,
      'author': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    };

    final conversationRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId);

    // Add user message
    await conversationRef.collection('messages').add(userMessage);

    // Update last message in conversation
    await conversationRef.update({
      'lastMessage': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    // Get AI response
    try {
      final prompt = text;
      final response = await _model.generateContent([Content.text(prompt)]);
      final aiText = response.text ?? 'I apologize, but I couldn\'t generate a response.';
      
      final aiResponse = {
        'message': aiText,
        'author': 'model',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await conversationRef.collection('messages').add(aiResponse);
    } catch (e) {
      // Fallback response if AI fails
      final fallbackResponse = {
        'message': 'I\'m having trouble connecting to my AI services right now. Please try again later.',
        'author': 'model',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await conversationRef.collection('messages').add(fallbackResponse);
    }
  }
}
