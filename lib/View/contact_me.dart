import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactMeScreen extends StatefulWidget {
  @override
  _ContactMeScreenState createState() => _ContactMeScreenState();
}

class _ContactMeScreenState extends State<ContactMeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Me'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/my-profile.jpeg'), // Add your profile image path here
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Dhanesh Sawant',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'I am a 3rd-year B.Tech Computer Science student at VIT Vellore, with experience as a Flutter developer at Pi Techniques Pvt Ltd. Additionally, I contribute to the Flutter BlueFireTeams Audioplayers package. I am passionate about building innovative solutions to real-world problems and thrive on exploring new technologies to create impactful applications.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),

                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('dhanesh23122003@gmail.com'),
              onTap: () {
                // Handle email tap
              },
            ),
            SizedBox(height: 16),
            Text(
              'Follow Me',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.github),
                  onPressed: () => _launchURL("https://github.com/Dhanesh-Sawant"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.twitter),
                  onPressed: () => _launchURL("https://x.com/DhaneshSawant23?t=z-ZQTz3PWrrgLr-X4qj88Q&s=08"),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.linkedin),
                  onPressed: () => _launchURL("https://www.linkedin.com/in/dhanesh-sawant-087003220/")
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram),
                  onPressed: () => _launchURL("https://www.instagram.com/dhanesh_sawant_23/"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    print("LAUNCHING URL");
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),mode: LaunchMode.inAppBrowserView);
      print("LAUNCHED URL");
    } else {
      throw 'Could not launch $url';
    }
  }

}
