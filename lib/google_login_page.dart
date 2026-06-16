import 'package:flutter/material.dart';
import 'home_page.dart';

class GoogleLoginPage extends StatelessWidget {
  const GoogleLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png', width: 50),
            const SizedBox(height: 20),
            const Text('Login dengan Google', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Gunakan Akun Google Anda untuk masuk ke Parkirin', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ListTile(
              leading: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68')),
              title: Text(context.findAncestorWidgetOfExactType<HomePage>()?.username ?? 'Daniel Ardiyansah'),
              subtitle: const Text('daniel.ardiyansah@gmail.com'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const HomePage(username: "Daniel (Google)")),
                  (route) => false
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Gunakan akun lain'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
