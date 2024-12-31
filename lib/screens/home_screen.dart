import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/character.dart';
import '../screens/character_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Character> characters = [];
  List<Character> filteredCharacters = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadCharacters() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      // Add 0.5s delay to simulate network request
      await Future.delayed(const Duration(milliseconds: 500));
      
      final String jsonString = await rootBundle.loadString('assets/data/characters.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<Character> loadedCharacters = (jsonData['characters'] as List)
          .map((data) => Character.fromJson(data))
          .toList();
      
      final random = Random();
      for (var i = loadedCharacters.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = loadedCharacters[i];
        loadedCharacters[i] = loadedCharacters[j];
        loadedCharacters[j] = temp;
      }
      
      setState(() {
        characters = loadedCharacters;
        filteredCharacters = List.from(loadedCharacters);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading characters: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load, please pull to refresh';
      });
    }
  }

  void _filterCharacters(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCharacters = List.from(characters);
      } else {
        filteredCharacters = characters.where((character) {
          return character.nickname.toLowerCase().contains(query.toLowerCase()) ||
                 character.role.toLowerCase().contains(query.toLowerCase()) ||
                 character.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by name, role, description...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16),
      onChanged: _filterCharacters,
    );
  }

  List<Widget> _buildActions() {
    if (isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchController.text.isEmpty) {
              setState(() {
                isSearching = false;
                filteredCharacters = List.from(characters);
              });
            } else {
              setState(() {
                _searchController.clear();
                filteredCharacters = List.from(characters);
              });
            }
          },
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            isSearching = true;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isSearching ? const BackButton() : null,
        title: isSearching ? _buildSearchField() : const Text('Home'),
        actions: _buildActions(),
      ),
      body: RefreshIndicator(
        onRefresh: loadCharacters,
        child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load, pull to refresh',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadCharacters,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredCharacters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No characters found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredCharacters.length,
                          itemBuilder: (context, index) {
                            final character = filteredCharacters[index];
                            return CharacterCard(character: character);
                          },
                        ),
                      ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailScreen(character: character),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                character.avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // 文本内容
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.nickname,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    character.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    character.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 