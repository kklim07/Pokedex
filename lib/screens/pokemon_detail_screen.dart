import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/pokemon_detail.dart';
import '../services/pokemon_service.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon? pokemon;
  final PokemonDetail? initialDetail;

  const PokemonDetailScreen({
    super.key,
    this.pokemon,
    this.initialDetail,
  }) : assert(pokemon != null || initialDetail != null,
            'Either pokemon or initialDetail must be provided');

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonService _pokemonService = PokemonService();
  late Future<PokemonDetail> _futureDetail;
  bool _isShiny = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDetail != null) {
      _futureDetail = Future.value(widget.initialDetail!);
    } else {
      _futureDetail = _pokemonService.getPokemonDetail(widget.pokemon!.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: const Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ), 
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (widget.pokemon != null) {
                          _futureDetail = _pokemonService
                              .getPokemonDetail(widget.pokemon!.url);
                        } else {
                          _futureDetail = _pokemonService
                              .getPokemonDetailByName(widget.initialDetail!.name);
                        }
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Text(
                        '#${detail.id.toString().padLeft(4, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isShiny
                            ? detail.shinyName[0].toUpperCase() +
                                detail.shinyName.substring(1)
                            : detail.name[0].toUpperCase() +
                                detail.name.substring(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Visibility(
                            visible: _isShiny,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          ),
                          
                          const SizedBox(width: 32),

                          GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.velocity.pixelsPerSecond.dx < -500) {
                                setState(() => _isShiny = true);
                              }
                              else if (details.velocity.pixelsPerSecond.dx > 500) {
                                setState(() => _isShiny = false);
                              }
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder:
                                  (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey<bool>(
                                    _isShiny),
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: Image.network(
                                  _isShiny
                                      ? detail
                                          .imageUrlShiny
                                      : detail.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context,
                                      error,
                                      stackTrace) =>
                                      Center(
                                    child: Icon(
                                      Icons
                                          .image_not_supported,
                                      color:
                                          Colors.white70,
                                      size: 64,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Visibility(
                            visible: !_isShiny,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Type',
                        Wrap(
                          spacing: 8,
                          children: detail.types
                              .map((type) => Chip(
                                    label: Text(
                                      type[0].toUpperCase() +
                                          type.substring(1),
                                      style: const TextStyle(
                                        color:
                                            Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor:
                                        _getTypeColor(type),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Physical Info',
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Height',
                                '${detail.heightInMeters} m',
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Weight',
                                '${detail.weightInKg} kg',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Abilities',
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < detail.abilities.length;
                                  i++) ...[
                                if (i > 0)
                                  const SizedBox(height: 12),
                                _buildDetailRow(
                                  'Ability ${i + 1}',
                                  detail.abilities[i][0]
                                          .toUpperCase() +
                                      detail.abilities[i]
                                          .substring(1),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Base Stats',
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < detail.stats.length;
                                  i++) ...[
                                if (i > 0)
                                  const SizedBox(height: 12),
                                _buildStatRow(
                                  detail.stats.keys.toList()[i],
                                  detail.stats.values.toList()[i],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String statName, int value) {
    final maxValue = 180.0;
    final percentage = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statName[0].toUpperCase() + statName.substring(1),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatColor(value),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return Colors.grey;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber;
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.brown;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.orange;
      case 'flying':
        return Colors.indigo;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.grey[800]!;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink[200]!;
      default:
        return Colors.grey;
    }
  }

  Color _getStatColor(int value) {
    if (value >= 120) {
      return Colors.green;
    } else if (value >= 90) {
      return Colors.lightGreen;
    } else if (value >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
