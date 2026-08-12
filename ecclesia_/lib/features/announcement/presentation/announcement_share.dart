import 'package:share_plus/share_plus.dart';

import '../data/models/announcement_model.dart';

/// Shares an announcement as plain text via the OS share sheet.
Future<void> shareAnnouncement(AnnouncementModel post) {
  final buffer = StringBuffer(post.title)
    ..writeln()
    ..writeln();
  buffer.writeln(post.body);
  buffer
    ..writeln()
    ..write('— ${post.authorName}, via l\'app Ecclesia');

  return SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: post.title));
}
