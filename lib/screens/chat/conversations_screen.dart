import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famai/models/conversation_model.dart';
import 'package:famai/services/chat_service.dart';
import 'package:famai/screens/chat/chat_screen.dart';
import 'package:famai/utils/sample_data_util.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:famai/services/plant_disease_service.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isScanning = false;
  String? _errorMessage;
  File? _selectedImage;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    try {
      // Add sample conversations for the demo
      final sampleData = SampleDataUtil();
      await sampleData.createSampleConversation();
    } catch (e) {
      debugPrint('Error initializing sample data: $e');
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndScanImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isScanning = true;
        });
        
        final result = await PlantDiseaseService.predictDisease(_selectedImage!);
        
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          
          _showScanResult(result);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showErrorDialog('Scanning failed: $e');
      }
    }
  }

  void _showScanResult(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Plant Disease Detection Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),
              Text(
                'Result: $result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result == 'Healthy' ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndScanImage();
              },
              child: Text('Scan Another'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: _isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt),
            onPressed: _isScanning ? null : _pickAndScanImage,
            tooltip: 'Scan Plant Disease',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(), // New chat
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _initializeData();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
        stream: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load conversations: ${snapshot.error}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList();

          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                title: Text(conversation.title),
                subtitle: Text(conversation.lastMessage),
                trailing: Text(
                  '${conversation.lastMessageTimestamp.toDate().hour}:${conversation.lastMessageTimestamp.toDate().minute}',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(conversationId: conversation.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
