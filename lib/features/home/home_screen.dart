import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../shared/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Key for local storage of favorite tool IDs
  static const String _favoritesKey = 'home_favorite_tools';

  late Set<String> _favoriteToolIds;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    if (StorageService.isBoxOpen(StorageService.settingsBoxName)) {
      final box = StorageService.getSettingsBox();
      final List<dynamic>? raw = box.get(_favoritesKey);
      if (raw != null) {
        _favoriteToolIds = raw.map((e) => e.toString()).toSet();
      } else {
        // Default favorites for quick access
        _favoriteToolIds = {'dice', 'coin', 'spin', 'timers'};
      }
    } else {
      _favoriteToolIds = {'dice', 'coin', 'spin', 'timers'};
    }
  }

  Future<void> _toggleFavorite(String id) async {
    setState(() {
      if (_favoriteToolIds.contains(id)) {
        _favoriteToolIds.remove(id);
      } else {
        _favoriteToolIds.add(id);
      }
    });

    if (StorageService.isBoxOpen(StorageService.settingsBoxName)) {
      final box = StorageService.getSettingsBox();
      await box.put(_favoritesKey, _favoriteToolIds.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTools = [
      // Randomizers
      _ToolItem(
        id: 'dice',
        icon: Icons.casino,
        title: 'Dice Roller',
        desc: '3D dice with realistic tumble & shake detection.',
        route: '/dice',
        category: 'Randomizers',
      ),
      _ToolItem(
        id: 'coin',
        icon: Icons.monetization_on,
        title: 'Coin Toss',
        desc: 'Minted 3D coin flip with thickness & streaks.',
        route: '/coin',
        category: 'Randomizers',
      ),
      _ToolItem(
        id: 'spin',
        icon: Icons.track_changes,
        title: 'Spin Wheel',
        desc: 'Custom segments, friction physics & elimination.',
        route: '/spin',
        category: 'Randomizers',
      ),
      // Timers
      _ToolItem(
        id: 'timers',
        icon: Icons.timer,
        title: 'Game Timers',
        desc: 'Countdown, Stopwatch, Chess Clock & Turn Timer.',
        route: '/timers',
        category: 'Timers',
      ),
      // Scoring & Teams
      _ToolItem(
        id: 'teams',
        icon: Icons.groups,
        title: 'Team Generator',
        desc: 'Balance rosters and auto-split players.',
        route: '/teams',
        category: 'Scoring & Teams',
      ),
      _ToolItem(
        id: 'scores',
        icon: Icons.scoreboard,
        title: 'Score Tracker',
        desc: 'Round-by-round points tally with undo history.',
        route: '/scores',
        category: 'Scoring & Teams',
      ),
      _ToolItem(
        id: 'cricket',
        icon: Icons.sports_cricket,
        title: 'Cricket Scorer',
        desc: 'Gully & club scorekeeper with legal ball rules.',
        route: '/cricket',
        category: 'Scoring & Teams',
      ),
      _ToolItem(
        id: 'tournament',
        icon: Icons.emoji_events,
        title: 'Tournament Gen',
        desc: 'Single elimination brackets for 4 to 32 players.',
        route: '/tournament',
        category: 'Tournament',
      ),
    ];

    final favoriteTools = allTools.where((t) => _favoriteToolIds.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_esports,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            const Text(
              'PLAYMATE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & About',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Play Hero Bar
                _buildQuickPlayBar(context, theme, isDark),
                const SizedBox(height: AppSpacing.l),

                // Favorites / Frequently Used Tools
                if (favoriteTools.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUICK ACCESS',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${favoriteTools.length} pinned',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteTools.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
                      itemBuilder: (context, index) {
                        final tool = favoriteTools[index];
                        return _buildQuickAccessChip(context, tool, theme, isDark);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],

                // All Tools Categorized Grid Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALL GAME TOOLS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${allTools.length} tools',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),

                // Complete Tools Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisSpacing: AppSpacing.m,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: allTools.length,
                  itemBuilder: (context, index) {
                    final tool = allTools[index];
                    final isFavorite = _favoriteToolIds.contains(tool.id);
                    return _buildToolCard(context, tool, isFavorite, theme, isDark);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPlayBar(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'QUICK START',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Text(
                'Offline Toolkit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Ready to play? Pick a tool to begin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push('/dice'),
                  icon: const Icon(Icons.casino, size: 18),
                  label: const Text('Roll Dice'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push('/coin'),
                  icon: const Icon(Icons.monetization_on, size: 18),
                  label: const Text('Toss Coin'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessChip(
    BuildContext context,
    _ToolItem tool,
    ThemeData theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => context.push(tool.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(AppSpacing.s + 2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  tool.icon,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              tool.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              tool.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    _ToolItem tool,
    bool isFavorite,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push(tool.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tool.icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber[700] : theme.colorScheme.secondary,
                    ),
                    tooltip: isFavorite ? 'Unpin from quick access' : 'Pin to quick access',
                    onPressed: () => _toggleFavorite(tool.id),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                tool.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tool.desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF666666),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final String id;
  final IconData icon;
  final String title;
  final String desc;
  final String route;
  final String category;

  const _ToolItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.desc,
    required this.route,
    required this.category,
  });
}
