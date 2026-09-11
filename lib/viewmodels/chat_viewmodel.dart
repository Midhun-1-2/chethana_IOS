import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chethanafm/services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  final bool _isLoading = false;
  bool _isSending = false;
  
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  // Search query & results
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  StreamSubscription? _searchSubscription;

  String get searchQuery => _searchQuery;
  List<Map<String, dynamic>> get searchResults => _searchResults;

  void setSearchQuery(String query, String currentUserId) {
    _searchQuery = query;
    _searchSubscription?.cancel();
    
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _searchSubscription = _chatService.searchUsers(query, currentUserId).listen((users) {
      _searchResults = users;
      notifyListeners();
    });
  }

  Stream<Map<String, dynamic>?> getUserDetailStream(String userId, {String? currentUserId}) {
    return _chatService.getUserDetailStream(userId, currentUserId: currentUserId);
  }

  // Get chat rooms stream
  Stream<List<Map<String, dynamic>>> getChatRooms(String currentUserId) {
    return _chatService.getChatRooms(currentUserId);
  }

  // Get messages stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String roomId) {
    return _chatService.getMessages(roomId);
  }

  // Get unread count stream
  Stream<int> getUnreadCount(String roomId, String currentUserId) {
    return _chatService.getUnreadCount(roomId, currentUserId);
  }

  // Get typing status stream
  Stream<bool> getTypingStatus(String roomId, String otherUserId) {
    return _chatService.getTypingStatus(roomId, otherUserId);
  }

  // ── Moderation: block & report (Guideline 1.2) ────────────────────────

  Stream<Set<String>> getBlockedUserIds(String currentUserId) {
    return _chatService.getBlockedUserIds(currentUserId);
  }

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
    required String blockedUserName,
    String? roomId,
    String? messageText,
  }) async {
    await _chatService.blockUser(
      currentUserId: currentUserId,
      blockedUserId: blockedUserId,
      blockedUserName: blockedUserName,
      roomId: roomId,
      messageText: messageText,
    );
  }

  Future<void> reportMessage({
    required String reporterId,
    required String roomId,
    required String messageId,
    required String messageText,
    required String reportedUserId,
    required String reportedUserName,
    String? reason,
  }) async {
    await _chatService.reportMessage(
      reporterId: reporterId,
      roomId: roomId,
      messageId: messageId,
      messageText: messageText,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      reason: reason,
    );
  }

  // Create room
  Future<String> getOrCreateChatRoom(String currentUserId, String otherUserId) async {
    return await _chatService.getOrCreateChatRoom(currentUserId, otherUserId);
  }

  // Join Live Chat
  Future<String> joinLiveChat(String showId) async {
    return await _chatService.joinLiveChat(showId);
  }


  // Send message
  Future<void> sendMessage(String roomId, String senderId, String receiverId, String text, {String? senderName, String? profileImage}) async {
    if (text.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();

    try {
      await _chatService.sendMessage(roomId, senderId, receiverId, text, senderName: senderName, profileImage: profileImage);
    } catch (e) {
      debugPrint("Error sending message: $e");
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Mark read
  Future<void> markAsRead(String roomId, String currentUserId) async {
    try {
      await _chatService.markMessagesAsRead(roomId, currentUserId);
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
    }
  }

  // Update typing indicator
  Future<void> setTypingStatus(String roomId, String userId, bool isTyping) async {
    try {
      await _chatService.setTypingStatus(roomId, userId, isTyping);
    } catch (e) {
      debugPrint("Error setting typing status: $e");
    }
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    super.dispose();
  }
}
