import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/messaging_repository.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => MessagingRepository(),
);

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(messagingRepositoryProvider).getConversations(),
);

final messagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, conversationId) =>
      ref.watch(messagingRepositoryProvider).getMessages(conversationId),
);