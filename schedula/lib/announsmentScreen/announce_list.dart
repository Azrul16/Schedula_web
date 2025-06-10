import 'package:flutter/material.dart';
import 'package:schedula/announsmentScreen/announce_item.dart';
import 'package:schedula/announsmentScreen/announce_model.dart';
import 'package:schedula/announsmentScreen/announcement_service.dart';
import 'package:schedula/utils/permission_handler.dart';

class AnnounceList extends StatefulWidget {
  const AnnounceList({super.key});

  @override
  State<AnnounceList> createState() => _AnnounceListState();
}

class _AnnounceListState extends State<AnnounceList> {
  bool _isCaptain = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final isCaptain = await PermissionHandler.isCurrentUserCaptain();
    if (mounted) {
      setState(() {
        _isCaptain = isCaptain;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Announcements>>(
      stream: _isCaptain 
          ? AnnouncementService.getAllAnnouncements()
          : AnnouncementService.getAnnouncementsForCurrentSemester(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final announcements = snapshot.data ?? [];
        
        if (announcements.isEmpty) {
          return const Center(
            child: Text('No announcements available'),
          );
        }
        return ListView.builder(
          itemCount: announcements.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return AnnounceItem(
              announcements[index],
              isStart: index == 0,
              isEnd: index == announcements.length - 1,
              task: announcements.length,
            );
          },
        );
      },
    );
  }
}
