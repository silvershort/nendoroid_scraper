import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nendoroid_scraper/download_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final downloadManager = DownloadManager();
  final textController = TextEditingController();

  String nendoroidInformation = '';

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FilledButton(
              onPressed: () {
                downloadManager.fetchNendoKoreanData(startNumber: '2607');
              },
              child: Text('넨도 한글 데이터'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: '넨도 제품번호 입력',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final data = await downloadManager.fetchNendoEnJaData(productNumber: int.parse(textController.text));
                    setState(() {
                      nendoroidInformation = data;
                    });
                  },
                  child: const Text(
                    '검색',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SelectableText(
                nendoroidInformation,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
