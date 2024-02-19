import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:sendbird_twinedo/pages/chat_screen%20copy.dart';
import 'dart:async';

import 'package:sendbird_twinedo/pages/chat_screen.dart';

const yourAppId = 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '강남스팟',
      theme: ThemeData.dark(),
      builder: (context, child) {
        return ScrollConfiguration(behavior: _AppBehavior(), child: child!);
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('강남스팟'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_outlined,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () {},
          ),
          backgroundColor: const Color(0xff0E0D0D),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24.0,
                ))
          ],
        ),
        body: DashChatScreen(
          appId: 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF',
          userId: 'twinedo.dev',
          otherUserIds: [''],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
