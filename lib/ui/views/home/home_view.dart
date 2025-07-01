import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CommonAppBar(), body: Center(child: Text('Welcome to the Home View!')));
  }
}
