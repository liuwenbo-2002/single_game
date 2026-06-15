import 'package:flutter/material.dart';
import '../data/games_data.dart';
import '../models/game_option.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/game_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _username = '玩家';

  List<GameOption> get _filteredGames {
    if (_searchQuery.isEmpty) return gameOptions;
    return gameOptions.where((g) {
      return g.name.contains(_searchQuery) ||
          g.description.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStartGame(GameOption game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在启动「${game.name}」...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildPlaceholder('游戏库', Icons.sports_esports);
      case 2:
        return _buildPlaceholder('个人中心', Icons.person);
      case 3:
        return _buildPlaceholder('设置', Icons.settings);
      default:
        return _buildHomePage();
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '功能开发中...',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderSection()),
          SliverToBoxAdapter(child: _buildSectionTitle()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    constraints.crossAxisExtent > 600 ? 3 : 2;
                final filtered = _filteredGames;
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              '没有找到匹配的游戏',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        GameCard(game: filtered[index], onStart: () => _onStartGame(filtered[index])),
                    childCount: filtered.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          UserHeader(
            username: _username,
            onAvatarTap: () => AvatarPicker.show(context),
          ),
          const SizedBox(height: 16),
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '所有游戏',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_searchQuery.isEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _currentNavIndex = 1),
              icon: const Text('查看全部', style: TextStyle(fontSize: 13)),
              label: const Icon(Icons.arrow_forward_ios, size: 12),
            ),
        ],
      ),
    );
  }
}
