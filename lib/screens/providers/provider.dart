import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wordbridge/screens/data/hive.dart';
import 'package:wordbridge/screens/models/item_box.dart';

class MainProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _allWords = [];
  List<DocumentSnapshot> _filteredWords = [];
  String _selectedWord = '';
  String _languageName = '';
  bool _showFavorites = false;

  String get selectedWord => _selectedWord;
  String get languageName => _languageName;
  List<DocumentSnapshot> get filteredWords => _filteredWords;
  bool get showFavorites => _showFavorites;
  final TextEditingController wordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _spokenText = '';
  List<DocumentSnapshot> _searchResults = [];

  bool get speechEnabled => _speechEnabled;
  String get spokenText => _spokenText;
  List<DocumentSnapshot> get searchResults => _searchResults;

  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> startListening() async {
    print('Listening');
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print('status: $status');
        if (status == 'notListening') {
          _speechEnabled = false;
          notifyListeners();
        }
      },
      onError: (error) {
        print('error: $error');
        _speechEnabled = false;
        notifyListeners();
      },
    );

    if (available) {
      Fluttertoast.showToast(
        msg: 'Microphone is enabled.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepPurpleAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _speechToText.listen(
        onResult: (result) {
          _spokenText = result.recognizedWords;
          print(_spokenText);
          searchController.text = _spokenText;
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: searchController.text.length),
          );
          searchWords(_spokenText);
          notifyListeners();
        },
      );
      _speechToText.listen(
        onResult: (result) {
          _spokenText = result.recognizedWords.toLowerCase();
          print(_spokenText);

          if (_spokenText == "clear search") {
            searchController.clear();
            _spokenText = "";
          } else {
            searchController.text = _spokenText;
            searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: searchController.text.length),
            );
          }

          searchWords(searchController.text);
          notifyListeners();
        },
      );
      _speechEnabled = true;
      notifyListeners();
    }
  }

  void stopListening() async {
    print('Stopped Listening');
    Fluttertoast.showToast(
      msg: 'Microphone is disabled.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.deepPurpleAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    _speechEnabled = false;
    await _speechToText.stop();
    notifyListeners();
  }

  MainProvider() {
    fetchWords();
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    updateFavorites();
  }

  void fetchWords() async {
    final snapshot = await _firestore.collection('admin').get();
    _allWords = snapshot.docs;
    _filteredWords = _allWords;
    notifyListeners();
  }

  List<DocumentSnapshot> getFavoriteWords() {
    return _allWords.where((doc) {
      String word = doc['word'];
      return isFavorite(word);
    }).toList();
  }

  void searchWords(String query) {
    String searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      _searchResults = _allWords;
    } else {
      _searchResults = _allWords.where((doc) {
        String word = (doc['word'] ?? '').toString().toLowerCase();
        return word.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void selectWord(String word, String language) {
    _selectedWord = word;
    _languageName = language;
    print("Selected word: $word | Language: $language");
    notifyListeners();
  }

  bool isFavorite(String word) {
    return favorite.values
        .cast<FavoriteModel>()
        .any((fav) => fav.word == word && fav.isChecked);
  }

  Future<void> toggleFavorite(String word) async {
    var existingItem = favorite.values.cast<FavoriteModel>().firstWhere(
          (fav) => fav.word == word,
          orElse: () => FavoriteModel(word: '', isChecked: false),
        );

    if (existingItem.word.isNotEmpty) {
      existingItem.isChecked = !existingItem.isChecked;
      await existingItem.save();
    } else {
      await favorite.add(FavoriteModel(word: word, isChecked: true));
    }
    notifyListeners();
  }

  void updateFavorites() {
    if (_showFavorites) {
      _filteredWords = getFavoriteWords();
    } else {
      _filteredWords = _allWords;
    }
    notifyListeners();
  }

  void showSignLanguage(BuildContext context, String selectedWord) async {
    if (selectedWord.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No word selected.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepPurpleAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    FirebaseFirestore.instance
        .collection('admin')
        .where('word', isEqualTo: selectedWord)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String animationUrl = querySnapshot.docs.first['link'];
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            final scaleAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));
            return FadeTransition(
              opacity: animation,
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedWord,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      animationUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Text("Failed to load image.");
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              ),
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      } else {
        Fluttertoast.showToast(
          msg: 'No animation found for "$selectedWord".',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Error fetching data: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void clearSelectedWords() {
    _selectedWord = '';
    print('Cleared selected word');
    notifyListeners();
  }
}
