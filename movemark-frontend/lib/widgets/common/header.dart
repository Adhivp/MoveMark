import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfileAvatar;
  final VoidCallback? onProfileTap;
  final String? profileInitials;

  const Header({
    Key? key,
    required this.title,
    this.actions,
    this.showProfileAvatar = true,
    this.onProfileTap,
    this.profileInitials = 'AD',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title Section
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF2C3E50),
          ),
        ),

        // Actions Section
        Row(
          children: [
            // Custom actions if provided
            if (actions != null) ...actions!,

            // Notification Icon
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // Show notifications
                _showNotifications(context);
              },
            ),

            const SizedBox(width: 8),

            // Profile Avatar
            if (showProfileAvatar)
              InkWell(
                onTap: onProfileTap ?? () => _showProfileMenu(context),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      profileInitials ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView(
            shrinkWrap: true,
            children: const [
              NotificationItem(
                title: 'New Leave Request',
                message: 'John Doe requested annual leave',
                time: '2 mins ago',
                isUnread: true,
              ),
              NotificationItem(
                title: 'Attendance Update',
                message: 'Monthly attendance report is ready',
                time: '1 hour ago',
                isUnread: true,
              ),
              NotificationItem(
                title: 'System Update',
                message: 'System maintenance scheduled',
                time: '1 day ago',
                isUnread: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mark all as read'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        // Update the PopupMenuItem widgets to use const and proper widget construction
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person_outline),
              SizedBox(width: 8),
              Text('My Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings_outlined),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'logout') {
        // Handle logout
      } else if (value == 'profile') {
        // Navigate to profile
      } else if (value == 'settings') {
        // Navigate to settings
      }
    });
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      isThreeLine: true,
      dense: true,
      onTap: () {
        // Handle notification tap
        Navigator.pop(context);
      },
    );
  }
}
