import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Article.dart';
import 'package:my_app/WeatherData.dart';
import 'package:my_app/WelcomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('K204'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to K-204',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/Icon-192.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Weather'),
              onTap: () {
                Navigator.pop(context);
                _showCityInputDialog();
              },
            ),
            ListTile(
              title: const Text('News'),
              onTap: () {
                Navigator.pop(context);
                _showKeywordInputDialog();
              },
            ),
            ListTile(
              title: const Text('GMaps'),
              onTap: () {
                Navigator.pop(context);
                // Handle GMaps menu press
                print('GMaps menu pressed');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to K-204'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showCityInputDialog();
                },
                child: const Text('Weather'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _showKeywordInputDialog();
                },
                child: const Text('News'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Belum Selesai
                  print('Third Menu Pressed');
                },
                child: const Text('GMaps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter City'),
          content: TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                String enteredCity = _cityController.text.trim();
                if (enteredCity.isNotEmpty) {
                  WeatherData weatherData = await fetchWeatherData(enteredCity);
                  _showWeatherDialog(weatherData);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showWeatherDialog(WeatherData weatherData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Weather Information'),
          content: Column(
            children: [
              Text('City: ${weatherData.cityName}'),
              Text('Temperature: ${weatherData.temperature}°C'),
              Text('Weather Description: ${weatherData.weatherDescription}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showKeywordInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Keyword'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(labelText: 'Keyword'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _searchNews();
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _searchNews() {
    String searchKeyword = _searchController.text.trim();
    fetchNews(searchKeyword).then((articles) {
      _showNewsDialog(context, articles);
    }).catchError((error) {
      print("Failed to fetch news: $error");
    });
  }

  Future<WeatherData> fetchWeatherData(String city) async {
    const apiKey = '8e827c464eb07fc406b82bc834a3c380';

    final response = await http.get(
      Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final dynamic jsonBody = json.decode(response.body);
      return WeatherData.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

Future<List<Article>> fetchNews(String keyword) async {
  const apiKey = 'aba3f55aee2e409b95ef77a58d6c449a';
  String apiUrl = 'https://newsapi.org/v2/everything?q=$keyword&apiKey=$apiKey';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final dynamic jsonBody = json.decode(response.body);
    List<Article> articles = (jsonBody['articles'] as List)
        .map((articleJson) => Article.fromJson(articleJson))
        .toList();
    return articles;
  } else {
    throw Exception('Failed to load news');
  }
}

void _showNewsDialog(BuildContext context, List<Article> articles) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('News Results'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(articles[index].title),
                subtitle: Text(articles[index].description),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
