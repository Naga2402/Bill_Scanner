import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../utils/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Analytics Dashboard'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (!provider.hasData) {
            return const Center(child: Text('No data available'));
          }

          final stats = provider.getStatistics();
          final phases = provider.projectData!.phases;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Development Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildStatRow(
                        context,
                        'Overall Progress',
                        '${stats['totalProgress']}%',
                        AppTheme.primaryColor,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Tasks Completed',
                        '${stats['completedTasks']} / ${stats['totalTasks']}',
                        AppTheme.successColor,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Days Elapsed',
                        '${stats['daysElapsed']} days',
                        AppTheme.infoColor,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Tasks Per Day',
                        stats['tasksPerDay'].toStringAsFixed(2),
                        AppTheme.warningColor,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Active Phases',
                        '${stats['activePhases']}',
                        AppTheme.secondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phase Breakdown
              Text(
                '📈 Phase-by-Phase Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              ...phases.map((phase) {
                final statusColor = AppTheme.getStatusColor(phase.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(phase.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                phase.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                phase.status.replaceAll('-', ' ').toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${phase.completedTasksCount} / ${phase.totalTasksCount} tasks',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${phase.progressPercentage}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: phase.progress,
                            minHeight: 8,
                            backgroundColor: AppTheme.surfaceColor,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Timeline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 Timeline',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildTimelineItem(
                        context,
                        'Start Date',
                        provider.projectData!.startDate,
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineItem(
                        context,
                        'Days Elapsed',
                        '${stats['daysElapsed']} days',
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineItem(
                        context,
                        'Expected Launch',
                        'Q1 2026',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryColor,
              ),
        ),
      ],
    );
  }
}

