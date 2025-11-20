import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/phase_card.dart';
import '../widgets/connection_banner.dart';
import '../utils/app_theme.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final stats = provider.getStatistics();
          final phases = provider.projectData!.phases;

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  backgroundColor: AppTheme.backgroundColor,
                  title: Row(
                    children: [
                      const Text('📱'),
                      const SizedBox(width: 8),
                      Text(
                        'Bill Scanner Dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Analytics',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: provider.refresh,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),

                // Connection Banner
                if (!provider.isConnected)
                  const SliverToBoxAdapter(
                    child: ConnectionBanner(),
                  ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Statistics Grid
                      _buildStatsGrid(context, stats),
                      const SizedBox(height: 24),

                      // Progress Bar
                      _buildOverallProgress(context, stats),
                      const SizedBox(height: 24),

                      // Timeline Info
                      _buildTimelineCard(context, stats),
                      const SizedBox(height: 24),

                      // Phases Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🚀 Development Phases',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${phases.length} phases',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phase Cards
                      ...phases.map((phase) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PhaseCard(phase: phase),
                          )),

                      const SizedBox(height: 80), // Extra space at bottom
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Overall Progress',
          value: '${stats['totalProgress']}%',
          icon: Icons.pie_chart,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          label: 'Tasks Completed',
          value: '${stats['completedTasks']}',
          icon: Icons.check_circle,
          color: AppTheme.successColor,
        ),
        StatCard(
          label: 'Total Tasks',
          value: '${stats['totalTasks']}',
          icon: Icons.list_alt,
          color: AppTheme.warningColor,
        ),
        StatCard(
          label: 'Current Phase',
          value: stats['currentPhase'],
          icon: Icons.rocket_launch,
          color: AppTheme.secondaryColor,
          isSmallText: true,
        ),
      ],
    );
  }

  Widget _buildOverallProgress(BuildContext context, Map<String, dynamic> stats) {
    final progress = stats['totalProgress'] / 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${stats['totalProgress']}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats['completedTasks']} of ${stats['totalTasks']} tasks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${stats['remainingTasks']} remaining',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimelineItem(
                  context,
                  'Days Elapsed',
                  '${stats['daysElapsed']}',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textSecondaryColor.withOpacity(0.2),
                ),
                _buildTimelineItem(
                  context,
                  'Tasks/Day',
                  stats['tasksPerDay'].toStringAsFixed(2),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textSecondaryColor.withOpacity(0.2),
                ),
                _buildTimelineItem(
                  context,
                  'Active Phases',
                  '${stats['activePhases']}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

