import 'package:flutter/material.dart';

class LearnMorePage extends StatelessWidget {
  static const routeName = '/learnmore';
  const LearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn More'),
      ),
      body: const Center(
        child: Text('This is the Learn More page.'),
      ),
    );
  }
}
