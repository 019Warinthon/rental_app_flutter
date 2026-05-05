import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../../profile/providers/user_provider.dart';
import '../../../core/config/colors.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.read<UserProvider>();
    final chats = chatProvider.chats;
    final myId = userProvider.user.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: chatProvider.isLoading && chats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: chatProvider.fetchChats,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 80,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final isOwner = myId == chat.ownerId;
                      final otherName = isOwner ? chat.userName : chat.ownerName;
                      
                      String timeStr = '';
                      try {
                        final date = DateTime.parse(chat.updatedAt).toLocal();
                        timeStr = DateFormat('HH:mm').format(date);
                        // If not today, show date
                        final now = DateTime.now();
                        if (date.day != now.day || date.month != now.month || date.year != now.year) {
                           timeStr = DateFormat('dd/MM').format(date);
                        }
                      } catch(_) {}

                      return ListTile(
                        onTap: () async {
                          await chatProvider.openChatByModel(chat);
                          if (context.mounted) {
                            context.push('/chat');
                          }
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(LucideIcons.user, color: AppColors.primary, size: 24),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                otherName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              chat.lastMessage ?? 'Start a conversation',
                              style: TextStyle(
                                fontSize: 14,
                                color: chat.lastMessage == null 
                                  ? AppColors.textSecondary.withValues(alpha: 0.6)
                                  : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chat.propertyTitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.messageSquare, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with property owners to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
