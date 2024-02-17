import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final List<Map<String, dynamic>> _items = [];
  int _page = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      Uri.parse(
          'https://api-stg.together.buzz/mocks/discovery?page=$_page&limit=10'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('data')) {
        final List<dynamic> dataList = data['data'];
        if (dataList.isNotEmpty) {
          setState(() {
            _items.addAll(dataList.cast<Map<String, dynamic>>());
            _page++;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('Unexpected data format: $data');
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (kDebugMode) {
        print('Failed to load data: ${response.statusCode}');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discovery Page ',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 220, 24, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        // Set app bar color to black
      ),
      body: Theme(
        data: ThemeData.dark().copyWith(
          // Update theme colors to pink and black
          scaffoldBackgroundColor: Colors.black,
          hintColor: Colors.pink,
          primaryColor: Colors.pink,
        ),
        child: ListView.builder(
          itemCount: _items.length + (_isLoading ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index < _items.length) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.only(
                    left: 1.0, right: 1.0, top: 5.0, bottom: 2.0),
                child: Card(
                  color: Colors.black,
                  shadowColor: Colors.pink,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      item['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item['description'] ?? 'No Description',
                      style: const TextStyle(fontSize: 14),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.network(
                          item['image_url'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Add navigation logic or any other action when a card is tapped
                    },
                  ),
                ),
              );
            } else {
              // Loading indicator
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ), 
                ),
              );
            }
          },
          // Implement pagination with infinite scrolling
          controller: _scrollController,
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_isLoading) return;
    if (_scrollController.position.extentAfter < 500) {
      _fetchData();
    }
  }
}
