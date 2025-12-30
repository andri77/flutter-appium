import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(BibleVersesApp());
}

class BibleVersesApp extends StatelessWidget {
  const BibleVersesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Verses',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'serif',
      ),
      home: BibleVersesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BibleVerse {
  final String verse;
  final String reference;
  final String topic;
  final String translation;

  BibleVerse({
    required this.verse, 
    required this.reference, 
    required this.topic,
    required this.translation,
  });
}

class BibleTranslation {
  final String id;
  final String name;
  final String language;

  BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
  });
}

class BackgroundOption {
  final String id;
  final String name;
  final String imageUrl;

  BackgroundOption({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class BibleVersesScreen extends StatefulWidget {
  const BibleVersesScreen({super.key});

  @override
  _BibleVersesScreenState createState() => _BibleVersesScreenState();
}

class _BibleVersesScreenState extends State<BibleVersesScreen> with TickerProviderStateMixin {
  Timer? _timer;
  BibleVerse? _currentVerse;
  String _selectedTopic = 'All';
  String _selectedTranslation = '9879dbb7cfe39e4d-01'; // New International Version
  String _selectedBackground = 'nature1';
  final Random _random = Random();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  final Map<String, ImageProvider> _cachedImages = {};

  // Your API key - replace with your actual API key from https://scripture.api.bible/
  static const String API_KEY = '3fe0a79cba6f5a695c3d834bd2efcd49';
  static const String BASE_URL = 'https://api.scripture.api.bible/v1';

  final List<String> _topics = [
    'All', 'Health', 'Finance', 'Love', 'Miracle', 'Joy', 'Gratitude', 'Faith', 'Hope'
  ];

  final List<BibleTranslation> _translations = [
    BibleTranslation(id: 'de4e12af7f28f599-02', name: 'English Standard Version', language: 'English'),
    BibleTranslation(id: '2dd568eeff29fb3c-02', name: 'Terjemahan Baru', language: 'Indonesian'),
    BibleTranslation(id: 'c315fa9f71d4af3a-01', name: 'King James Version', language: 'English'),
    BibleTranslation(id: '9879dbb7cfe39e4d-01', name: 'New International Version', language: 'English'),
  ];

  final List<BackgroundOption> _backgrounds = [
    BackgroundOption(id: 'nature1', name: 'Mountain Dawn', imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature2', name: 'Ocean Sunset', imageUrl: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature3', name: 'Forest Path', imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature4', name: 'Starry Night', imageUrl: 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature5', name: 'Golden Fields', imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature6', name: 'Peaceful Lake', imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature7', name: 'Desert Peace', imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature8', name: 'Garden Bloom', imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature9', name: 'Valley View', imageUrl: 'https://images.unsplash.com/photo-1500622944204-b135684e99fd?w=800&h=1200&fit=crop&q=80'),
    BackgroundOption(id: 'nature10', name: 'Sacred Stones', imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&h=1200&fit=crop&q=80'),
  ];

  // Pre-defined verse references categorized by topic
  final Map<String, List<String>> _verseReferences = {
    'Health': [
      '3JN.1.2', 'PSA.147.3', 'JER.30.17', 'JER.17.14', 'JAS.5.14',
      'PRO.17.22', 'PRO.3.7-8', 'ISA.58.11', 'ISA.40.29', 'EXO.23.25',
      'PRO.4.20-22', 'JAS.5.15', '1PE.2.24'
    ],
    'Finance': [
      'PHP.4.19', 'MAL.3.10', 'PRO.3.9-10', '1SA.2.7', 'LUK.6.38',
      'PRO.10.22', '1TI.6.18', 'PRO.19.17', '2CO.9.11', 'DEU.8.18',
      'PRO.28.20', 'PRO.10.4'
    ],
    'Love': [
      '1CO.13.4', '1PE.4.8', '1CO.13.13', '1JN.4.7', '1JN.4.9',
      '1JN.4.19', 'JHN.13.34', 'JHN.15.13', '1CO.13.6', '1TH.3.12',
      '1CO.16.14', '1JN.3.1'
    ],
    'Miracle': [
      'MAT.19.26', 'LUK.1.37', 'JER.33.3', 'EPH.3.20', 'JER.32.27',
      'JER.32.17', 'LUK.18.27', 'MAT.17.20', '2CO.9.8', 'ZEP.3.17',
      'PRO.19.21'
    ],
    'Joy': [
      'NEH.8.10', 'PHP.4.4', 'PSA.16.11', 'ROM.15.13', 'PSA.30.5',
      'PSA.126.5', 'PSA.118.24', 'ROM.12.12', '1PE.1.8', 'PSA.100.1',
      'JAS.1.2', 'JHN.15.11'
    ],
    'Gratitude': [
      '1TH.5.18', 'PSA.100.4', 'PSA.107.8', 'PSA.9.1', 'COL.3.17',
      'PHP.4.6', '2CO.9.15', 'JAS.1.17', 'PSA.107.1', 'COL.3.15',
      '1CO.15.57'
    ],
    'Faith': [
      'HEB.11.1', '2CO.5.7', 'HEB.11.6', 'JOS.1.9', 'ROM.10.9',
      'EPH.2.8', 'ROM.5.1', '1TI.6.12', '2TI.4.7', 'HEB.10.23',
      'ROM.10.17', 'PRO.3.5'
    ],
    'Hope': [
      'JER.29.11', 'ROM.15.13', 'ISA.40.31', 'PSA.31.24', 'PSA.42.11',
      'HEB.10.23', 'ROM.5.2', '1PE.1.3', 'LAM.3.25', 'PSA.62.5',
      'HEB.3.6'
    ]
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _preloadImages();
    _fetchRandomVerse();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _preloadImages() {
    for (var background in _backgrounds) {
      if (background.imageUrl.isNotEmpty) {
        final imageProvider = NetworkImage(background.imageUrl);
        _cachedImages[background.id] = imageProvider;
        // Preload the image
        precacheImage(imageProvider, context).catchError((error) {
          print('Failed to preload image ${background.name}: $error');
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      _fetchRandomVerse();
    });
  }

  Future<void> _fetchRandomVerse() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // Fade out current verse
    await _animationController.reverse();

    try {
      // Get random verse reference based on selected topic
      List<String> availableReferences = _selectedTopic == 'All' 
          ? _verseReferences.values.expand((list) => list).toList()
          : _verseReferences[_selectedTopic] ?? [];
      
      if (availableReferences.isEmpty) {
        // Fallback to a default verse
        availableReferences = ['JHN.3.16'];
      }

      String randomReference = availableReferences[_random.nextInt(availableReferences.length)];
      
      // Fetch verse from API
      final response = await http.get(
        Uri.parse('$BASE_URL/bibles/$_selectedTranslation/verses/$randomReference?content-type=text&include-notes=false&include-titles=false&include-chapter-numbers=false&include-verse-numbers=false'),
        headers: {
          'api-key': API_KEY,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verseData = data['data'];
        
        // Get topic for this verse
        String topic = _selectedTopic;
        if (topic == 'All') {
          topic = _getTopicForReference(randomReference);
        }

        // Get translation name
        String translationName = _translations.firstWhere(
          (t) => t.id == _selectedTranslation,
          orElse: () => BibleTranslation(id: '', name: 'Unknown', language: ''),
        ).name;

        setState(() {
          _currentVerse = BibleVerse(
            verse: verseData['content'].toString().trim(),
            reference: verseData['reference'],
            topic: topic,
            translation: translationName,
          );
        });

        // Fade in new verse
        _animationController.forward();
      } else {
        throw Exception('Failed to load verse: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching verse: $e');
      // Show error message or fallback verse
      setState(() {
        _currentVerse = BibleVerse(
          verse: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
          reference: 'John 3:16',
          topic: 'Love',
          translation: 'Fallback',
        );
      });
      _animationController.forward();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTopicForReference(String reference) {
    for (String topic in _verseReferences.keys) {
      if (_verseReferences[topic]!.contains(reference)) {
        return topic;
      }
    }
    return 'Faith'; // Default topic
  }

  void _onTopicChanged(String? newTopic) {
    if (newTopic != null && newTopic != _selectedTopic) {
      setState(() {
        _selectedTopic = newTopic;
      });
      _fetchRandomVerse();
    }
  }

  void _onTranslationChanged(String? newTranslation) {
    if (newTranslation != null && newTranslation != _selectedTranslation) {
      setState(() {
        _selectedTranslation = newTranslation;
      });
      _fetchRandomVerse();
    }
  }

  void _onBackgroundChanged(String? newBackground) {
    if (newBackground != null && newBackground != _selectedBackground) {
      setState(() {
        _selectedBackground = newBackground;
      });
    }
  }

  Widget _buildBackground() {
    if (_selectedBackground == 'gradient') {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[300]!,
              Colors.orange[600]!,
              Colors.orange[800]!,
            ],
          ),
        ),
      );
    } else {
      final imageProvider = _cachedImages[_selectedBackground];
      return Container(
        decoration: BoxDecoration(
          image: imageProvider != null
              ? DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.multiply,
                  ),
                )
              : null,
          gradient: imageProvider == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange[300]!,
                    Colors.orange[600]!,
                    Colors.orange[800]!,
                  ],
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header
                  Text(
                    'Daily Bible Verses',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Translation Selector
                  Semantics(
                    label: 'translation_dropdown',
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedTranslation,
                        underline: SizedBox(),
                        icon: Icon(Icons.language, color: Colors.orange[800]),
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        isExpanded: true,
                        items: _translations.map((BibleTranslation translation) {
                          return DropdownMenuItem<String>(
                            value: translation.id,
                            child: Text(
                              '${translation.name} (${translation.language})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _onTranslationChanged,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 15),
                  
                  // Topic and Background Selectors Row
                  Row(
                    children: [
                      // Topic Selector
                      Expanded(
                        child: Semantics(
                          label: 'topic_dropdown',
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedTopic,
                              underline: SizedBox(),
                              icon: Icon(Icons.category, color: Colors.orange[800]),
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              isExpanded: true,
                              items: _topics.map((String topic) {
                                return DropdownMenuItem<String>(
                                  value: topic,
                                  child: Text(topic),
                                );
                              }).toList(),
                              onChanged: _onTopicChanged,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 10),
                      
                      // Background Selector
                      Expanded(
                        child: Semantics(
                          label: 'background_dropdown',
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedBackground,
                              underline: SizedBox(),
                              icon: Icon(Icons.wallpaper, color: Colors.orange[800]),
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              isExpanded: true,
                              items: _backgrounds.map((BackgroundOption background) {
                                return DropdownMenuItem<String>(
                                  value: background.id,
                                  child: Text(
                                    background.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: _onBackgroundChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Main Verse Display
                  Expanded(
                    child: Center(
                      child: _currentVerse != null
                          ? FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: EdgeInsets.all(30),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Topic Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[600],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        _currentVerse!.topic,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Verse Text
                                    Text(
                                      '"${_currentVerse!.verse}"',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Reference
                                    Text(
                                      '- ${_currentVerse!.reference}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    
                                    // Translation
                                    if (_currentVerse!.translation != 'Fallback')
                                      Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          _currentVerse!.translation,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                    ),
                  ),
                  
                  // Bottom Actions
                  Center(
                    child: Semantics(
                      label: 'new_verse_button',
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _fetchRandomVerse,
                        icon: _isLoading 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.refresh),
                        label: Text(_isLoading ? 'Loading...' : 'New Verse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}