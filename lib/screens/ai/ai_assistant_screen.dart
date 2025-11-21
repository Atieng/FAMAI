import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:famai/services/plant_disease_service.dart';
import 'package:famai/models/plant_disease_model.dart';
import 'package:famai/services/ai_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AIService _aiService = AIService();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    _addMessage('AI Assistant', '🌱 Welcome to FamAI!\n\nI\'m your agricultural assistant. Here\'s what I can help you with:\n\n📱 **Plant Disease Scanning** - Tap the camera icon to scan plants\n💬 **Agricultural Advice** - Ask me anything about farming\n🌾 **Crop Management** - Get tips for better yields\n\nHow can I assist you today?', isUser: false);
  }

  void _addMessage(String sender, String text, {bool isUser = false, bool isError = false}) {
    setState(() {
      _messages.add(ChatMessage(
        sender: sender,
        text: text,
        isUser: isUser,
        isError: isError,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    _addMessage('You', userMessage, isUser: true);
    setState(() => _isLoading = true);

    try {
      final response = await _aiService.sendMessage(userMessage);
      _addMessage('AI Assistant', response, isUser: false);
    } catch (e) {
      _addMessage('AI Assistant', '❌ Sorry, I encountered an error. Please try again.', isUser: false, isError: true);
    } finally {
      setState(() => _isLoading = false);
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
        final imageFile = File(image.path);
        setState(() => _isScanning = true);
        
        _addMessage('You', '📷 Scanning plant image...', isUser: true);
        
        final response = await PlantDiseaseService.detectDisease(imageFile);
        
        String resultMessage;
        if (response.hasError) {
          resultMessage = '❌ Scanning failed: ${response.error}';
        } else if (response.hasResults) {
          final result = response.primaryResult!;
          final analysis = PlantDiseaseService.analyzeResult(result);
          
          resultMessage = result.confidenceValue >= 70 
            ? '⚠️ I detected **${result.diseaseName}** with ${result.confidence} confidence. ${analysis.riskAssessment}'
            : '🔍 Possible **${result.diseaseName}** detected (${result.confidence} confidence). Monitor closely.';
            
          _showDetailedResult(response, imageFile);
        } else {
          resultMessage = '❓ Unable to detect disease. Please try with a clearer image.';
        }
        
        _addMessage('Plant Scanner', resultMessage, isUser: false, isError: response.hasError);
      }
    } catch (e) {
      _addMessage('Plant Scanner', '❌ Scanning failed: $e', isUser: false, isError: true);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showDetailedResult(PlantDiseaseResponse response, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plant Analysis Result',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                if (response.hasResults && !response.hasError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(response.primaryResult!.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getSeverityColor(response.primaryResult!.severity),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getSeverityIcon(response.primaryResult!.severity),
                              color: _getSeverityColor(response.primaryResult!.severity),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                response.primaryResult!.diseaseName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getSeverityColor(response.primaryResult!.severity),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${response.primaryResult!.confidence}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getSeverityColor(response.primaryResult!.severity),
                          ),
                        ),
                        Text(
                          'Plant: ${response.primaryResult!.plantType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getSeverityColor(response.primaryResult!.severity),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.helpCircle, color: Colors.grey, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            response.hasError ? 'Analysis Failed' : 'No Disease Detected',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickAndScanImage();
                      },
                      icon: const Icon(LucideIcons.camera, size: 16),
                      label: const Text('Scan Another'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.bot,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: _isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(LucideIcons.camera, color: Theme.of(context).colorScheme.primary),
            onPressed: _isScanning ? null : _pickAndScanImage,
            tooltip: 'Scan Plant Disease',
          ),
          IconButton(
            icon: Icon(LucideIcons.trash2, color: Theme.of(context).colorScheme.error),
            onPressed: () {
              setState(() => _messages.clear());
              _addMessage('AI Assistant', '🌱 Welcome to FamAI!\n\n📱 **Plant Disease Scanning** is available - tap the camera icon above to scan plants for diseases.\n\n💬 AI chat is temporarily under maintenance.\n\nTry scanning a plant image to get started!', isUser: false);
            },
            tooltip: 'Clear Chat',
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
              ? _buildEmptyState()
              : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bot,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI Agricultural Assistant',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about farming, plants, or crops!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            children: [
              _buildSuggestionChip('🌱 Plant care tips'),
              _buildSuggestionChip('🐛 Pest control'),
              _buildSuggestionChip('🌾 Crop rotation'),
              _buildSuggestionChip('💡 Best practices'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text.replaceAll(RegExp(r'[^\w\s]'), '').trim();
        _sendMessage();
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: message.isError 
                  ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isError ? LucideIcons.alertCircle : LucideIcons.bot,
                size: 16,
                color: message.isError 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : message.isError
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: !message.isUser && !message.isError ? const Radius.circular(4) : const Radius.circular(16),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                        ? Theme.of(context).colorScheme.onPrimary
                        : message.isError
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.user,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about farming, plants, or crops...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                prefixIcon: Icon(
                  LucideIcons.messageCircle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      LucideIcons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(DiseaseSeverity severity) {
    switch (severity) {
      case DiseaseSeverity.low:
        return Colors.orange;
      case DiseaseSeverity.medium:
        return Colors.deepOrange;
      case DiseaseSeverity.high:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(DiseaseSeverity severity) {
    switch (severity) {
      case DiseaseSeverity.low:
        return LucideIcons.alertTriangle;
      case DiseaseSeverity.medium:
        return LucideIcons.alertCircle;
      case DiseaseSeverity.high:
        return LucideIcons.xCircle;
    }
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}
