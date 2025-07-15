import 'package:flutter/material.dart';
import '../flavors.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(F.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello ${F.title}'),
            Text('Flavor: ${F.name}'),
            Text(
              'Yesterday was ${DateTime.now().subtract(const Duration(days: 1)).toLocal()}',
            ),
            Text('Today is ${DateTime.now().toLocal()}'),
            Text(
              'Tomorrow will be ${DateTime.now().add(const Duration(days: 1)).toLocal()}',
            ),
            Text('for Ahmet Version'),
            Text("Dev'e göre değişiklik 20"),
          ],
        ),
      ),
    );
  }
}
