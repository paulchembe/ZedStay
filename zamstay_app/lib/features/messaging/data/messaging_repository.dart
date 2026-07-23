import 'package:supabase_flutter/supabase_flutter.dart';

class MessagingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Get or create a conversation
  Future<String> getOrCreateConversation({
    required String listingId,
    required String hostId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Check if conversation already exists
    final existing = await _client
        .from('conversations')
        .select()
        .eq('listing_id', listingId)
        .eq('host_id', hostId)
        .eq('guest_id', user.id)
        .maybeSingle();

    if (existing != null) return existing['id'];

    // Create new conversation
    final response = await _client.from('conversations').insert({
      'listing_id': listingId,
      'host_id': hostId,
      'guest_id': user.id,
    }).select().single();

    return response['id'];
  }

  // Get all conversations for current user
  Future<List<Map<String, dynamic>>> getConversations() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('conversations')
        .select('''
          *,
          listing:listings(title, city),
          host:users!host_id(full_name, email),
          guest:users!guest_id(full_name, email)
        ''')
        .or('host_id.eq.${user.id},guest_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get messages for a conversation
  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': user.id,
      'content': content,
    });
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', user.id);
  }
}