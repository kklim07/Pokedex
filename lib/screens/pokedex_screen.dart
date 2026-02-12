import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/item.dart';
import '../models/pokemon_detail.dart';
import '../services/pokemon_service.dart';
import 'pokemon_detail_screen.dart';
import 'item_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokemonService _pokemonService = PokemonService();
  final ScrollController _pokemonScrollController = ScrollController();
  final ScrollController _itemsScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  final List<Pokemon> _pokemonList = [];
  final List<Item> _itemList = [];
  
  int _currentPokemonOffset = 0;
  int _currentItemOffset = 0;
  bool _pokemonLoading = false;
  bool _pokemonHasMore = true;
  bool _itemsLoading = false;
  bool _itemsHasMore = true;
  bool _searchLoading = false;
  String? _pokemonError;
  String? _itemsError;
  String? _searchError;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pokemonScrollController.addListener(_onPokemonScroll);
    _itemsScrollController.addListener(_onItemsScroll);
    _loadMorePokemon();
    _loadMoreItems();
  }

  @override
  void dispose() {
    _pokemonScrollController.dispose();
    _itemsScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPokemonScroll() {
    if (_pokemonScrollController.position.pixels ==
            _pokemonScrollController.position.maxScrollExtent &&
        !_pokemonLoading &&
        _pokemonHasMore) {
      _loadMorePokemon();
    }
  }

  void _onItemsScroll() {
    if (_itemsScrollController.position.pixels ==
            _itemsScrollController.position.maxScrollExtent &&
        !_itemsLoading &&
        _itemsHasMore) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_pokemonLoading || !_pokemonHasMore) return;

    setState(() {
      _pokemonLoading = true;
      _pokemonError = null;
    });

    try {
      final response = await _pokemonService.getPokemon(
        limit: 20,
        offset: _currentPokemonOffset,
      );

      setState(() {
        _pokemonList.addAll(response.results);
        _currentPokemonOffset += response.results.length;
        _pokemonHasMore = response.next != null;
        _pokemonLoading = false;
      });
    } catch (e) {
      setState(() {
        _pokemonError = 'Failed to load Pokemon. Please try again.';
        _pokemonLoading = false;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_itemsLoading || !_itemsHasMore) return;

    setState(() {
      _itemsLoading = true;
      _itemsError = null;
    });

    try {
      final response = await _pokemonService.getItems(
        limit: 20,
        offset: _currentItemOffset,
      );

      setState(() {
        _itemList.addAll(response.results);
        _currentItemOffset += response.results.length;
        _itemsHasMore = response.next != null;
        _itemsLoading = false;
      });
    } catch (e) {
      setState(() {
        _itemsError = 'Failed to load items. Please try again.';
        _itemsLoading = false;
      });
    }
  }

  void _refreshPokemon() {
    setState(() {
      _pokemonList.clear();
      _currentPokemonOffset = 0;
      _pokemonHasMore = true;
      _pokemonError = null;
    });
    _loadMorePokemon();
  }

  void _refreshItems() {
    setState(() {
      _itemList.clear();
      _currentItemOffset = 0;
      _itemsHasMore = true;
      _itemsError = null;
    });
    _loadMoreItems();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchLoading = true;
      _searchError = null;
    });

    try {
      final PokemonDetail detail =
          await _pokemonService.getPokemonDetailByName(query);
      if (!mounted) return;
      setState(() => _searchLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PokemonDetailScreen(initialDetail: detail),
        ),
      );
    } catch (e) {
      setState(() {
        _searchLoading = false;
        _searchError = 'No Pokémon found for "$query".';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: Text(
          _selectedIndex == 0
              ? 'Pokédex'
              : _selectedIndex == 1
                  ? 'Items'
                  : 'Search Pokémon',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Poké List',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 44,
              height: 44,
              child: Image.asset('assets/img/pokeball.png', fit: BoxFit.contain),
            ),
            label: 'Item',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey[600],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildPokemonList();
    } else if (_selectedIndex == 1) {
      return _buildItemsList();
    } else {
      return _buildSearchView();
    }
  }

  Widget _buildPokemonList() {
    if (_pokemonList.isEmpty && _pokemonLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pokemonError != null && _pokemonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_pokemonError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPokemon,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.microtask(_refreshPokemon);
      },
      color: Colors.red,
      child: ListView.builder(
        controller: _pokemonScrollController,
        itemCount: _pokemonList.length + (_pokemonHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _pokemonList.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _pokemonLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }

          final pokemon = _pokemonList[index];
          return _buildPokemonCard(pokemon);
        },
      ),
    );
  }

  Widget _buildItemsList() {
    if (_itemList.isEmpty && _itemsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_itemsError != null && _itemList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_itemsError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.microtask(_refreshItems);
      },
      color: Colors.red,
      child: ListView.builder(
        controller: _itemsScrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _itemList.length + (_itemsHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _itemList.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _itemsLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }
          final item = _itemList[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildSearchView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: const InputDecoration(
              labelText: 'Name or ID',
              hintText: 'e.g. Pikachu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchLoading ? null : _search,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_searchLoading) const LinearProgressIndicator(),
          if (_searchError != null) ...[
            const SizedBox(height: 12),
            Text(_searchError!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(pokemon: pokemon),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  pokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(4, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pokemon.name[0].toUpperCase() +
                          pokemon.name.substring(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name[0].toUpperCase() + item.name.substring(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
