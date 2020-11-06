import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static Future openLink({@required String url}) => _launchUrl(url);

  static Future _launchUrl(String url) async {
    print('hello');
    if (await canLaunch(url)) {
      print('world');
      await launch(url);
    }
  }

  static Future openEmail({
    @required String toEmail,
    @required String subject,
    @required String body,
  }) async {
    print('kek');
    final url =
        'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

    await _launchUrl(url);
  }
}
