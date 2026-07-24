import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/messaging_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: conversations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (convos) {
          if (convos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No messages yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('Start a conversation from a listing page',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: convos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final convo = convos[index];
              final isHost = convo['host_id'] == currentUserId;
              final otherPerson = isHost
                  ? convo['guest']['full_name'] ?? 'Guest'
                  : convo['host']['full_name'] ?? 'Host';
              final listingTitle =
                  convo['listing']['title'] ?? 'Listing';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1B3A6B),
                  child: Text(
                    otherPerson[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(otherPerson,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(listingTitle,
                    style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(
                  '/chat',
                  extra: {
                    'conversationId': convo['id'],
                    'otherPersonName': otherPerson,
                    'listingTitle': listingTitle,
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}