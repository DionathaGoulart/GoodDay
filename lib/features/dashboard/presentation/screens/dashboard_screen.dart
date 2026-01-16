import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this if not present
import '../../../daily_log/presentation/providers/daily_log_provider.dart';
import '../../../daily_log/data/models/daily_log_model.dart';
import '../../data/services/stats_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/data/models/activity_item_model.dart';
import 'package:good_day/core/theme/app_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final StatsService _statsService = StatsService();
  int _selectedYear = DateTime.now().year;

  String _translateMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return 'Feliz';
      case 'good': return 'Bom';
      case 'neutral': return 'Neutro';
      case 'sad': return 'Triste';
      case 'terrible': return 'Terrível';
      default: return mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyLogsAsync = ref.watch(dailyLogsControllerProvider);
    const spotifyGreen = AppTheme.primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Estatísticas', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: spotifyGreen,
            tabs: [
              Tab(text: 'Visão Geral'),
              Tab(text: 'Anual'),
            ],
          ),
        ),
        body: dailyLogsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text('Sem dados suficientes.', style: TextStyle(color: Colors.grey)));
            }
            return TabBarView(
              children: [
                _buildOverviewTab(logs, spotifyGreen),
                _buildAnnualTab(logs, spotifyGreen),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(List<DailyLog> logs, Color accentColor) {
     final currentStreak = _statsService.calculateCurrentStreak(logs);
     final longestStreak = _statsService.calculateLongestHappyStreak(logs);
     final avgMood = _statsService.calculateAverageMood(logs);
     
     return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(child: _SummaryCard(title: 'Sequência', value: '$currentStreak dias', icon: Icons.local_fire_department, color: AppTheme.pastelPink)),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryCard(title: 'Melhor Sequência', value: '$longestStreak dias', subtitle: 'Dias felizes', icon: Icons.sentiment_very_satisfied, color: AppTheme.pastelYellow)),
                ],
              ),
              const SizedBox(height: 8),
               Row(
                children: [
                  Expanded(child: _SummaryCard(title: 'Total Registros', value: '${logs.length}', icon: Icons.library_books, color: AppTheme.pastelTeal)),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryCard(title: 'Humor Médio', value: avgMood.toStringAsFixed(1), subtitle: '/ 5.0', icon: Icons.analytics, color: accentColor)),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Tendência (30 Dias)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                 height: 250,
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                 child: LineChart(_buildGenericLineChart(logs.take(30).toList(), accentColor)),
              ),
              
              const SizedBox(height: 24),
              const Text('Distribuição de Humor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              _buildMoodDistribution(logs),
          ],
        ),
     );
  }

  Widget _buildAnnualTab(List<DailyLog> logs, Color accentColor) {
      final years = logs.map((l) => l.date.year).toSet().toList()..sort();
      if (!years.contains(DateTime.now().year)) years.add(DateTime.now().year);
      if (!years.contains(_selectedYear)) _selectedYear = years.last;
      
      return SingleChildScrollView(
         padding: const EdgeInsets.all(16),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Year Selector
               DropdownButton<int>(
                 dropdownColor: const Color(0xFF282828),
                 value: _selectedYear,
                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                 underline: Container(height: 2, color: accentColor),
                 items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                 onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                 },
               ),
               const SizedBox(height: 24),
               
               // Year in Pixels
               Text('$_selectedYear em Pixels', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               _YearInPixels(data: _statsService.getYearInPixelsData(logs, _selectedYear)),
               
               const SizedBox(height: 24),
               const Text('Média Mensal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               Container(
                 height: 200,
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                 child: BarChart(_buildMonthlyBarChart(logs, _selectedYear, accentColor)),
               ),

               const SizedBox(height: 24),
               const Text('Por Dia da Semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               Container(
                 height: 200,
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                 child: BarChart(_buildDayOfWeekChart(logs, accentColor)),
               ),
               
               const SizedBox(height: 24),
               const Text('Top Atividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               _buildActivityList(logs, _selectedYear),
            ],
         ),
      );
  }

  // --- Charts Logic ---

  LineChartData _buildGenericLineChart(List<DailyLog> inputLogs, Color color) {
    // Sort logic 
    final sorted = List<DailyLog>.from(inputLogs)..sort((a,b) => a.date.compareTo(b.date));
    final chartLogs = sorted.length > 30 ? sorted.sublist(sorted.length - 30) : sorted;
    
    List<FlSpot> spots = [];
    for (int i = 0; i < chartLogs.length; i++) {
       spots.add(FlSpot(i.toDouble(), _statsService.moodToScore(chartLogs[i].mood).toDouble()));
    }

    return LineChartData(
       gridData: const FlGridData(show: false),
       titlesData: const FlTitlesData(
         show: true, 
         bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
         leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
       ), 
       borderData: FlBorderData(show: false),
       minY: 1, maxY: 6,
       lineBarsData: [
         LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3, dotData: const FlDotData(show: false), 
          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2))),
       ],
    );
  }

  BarChartData _buildMonthlyBarChart(List<DailyLog> logs, int year, Color color) {
     final averages = _statsService.calculateMonthlyAverages(logs, year);
     
     return BarChartData(
       gridData: const FlGridData(show: false),
       borderData: FlBorderData(show: false),
       titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
             showTitles: true,
             getTitlesWidget: (val, meta) {
                const months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
                final idx = val.toInt() - 1;
                if (idx >= 0 && idx < 12) return Text(months[idx], style: const TextStyle(color: Colors.grey, fontSize: 10));
                return const Text('');
             },
          )),
       ),
       maxY: 6, // 5 is max score
       barGroups: List.generate(12, (index) {
          final month = index + 1;
          return BarChartGroupData(x: month, barRods: [
             BarChartRodData(toY: averages[month] ?? 0, color: color, width: 12, borderRadius: BorderRadius.circular(4)),
          ]);
       }),
     );
  }

   BarChartData _buildDayOfWeekChart(List<DailyLog> logs, Color color) {
     final averages = _statsService.calculateDayOfWeekAverages(logs);
     
     return BarChartData(
       gridData: const FlGridData(show: false),
       borderData: FlBorderData(show: false),
       titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
             showTitles: true,
             getTitlesWidget: (val, meta) {
                const days = ['S','T','Q','Q','S','S','D']; // Mon=S, Tue=T... PT-BR: Seg, Ter, Qua, Qui, Sex, Sab, Dom
                // 'S','T','Q','Q','S','S','D'
                final idx = val.toInt() - 1;
                if (idx >= 0 && idx < 7) return Text(days[idx], style: const TextStyle(color: Colors.grey, fontSize: 10));
                return const Text('');
             },
          )),
       ),
       maxY: 6,
       barGroups: List.generate(7, (index) {
          final day = index + 1;
          return BarChartGroupData(x: day, barRods: [
             BarChartRodData(toY: averages[day] ?? 0, color: color, width: 12, borderRadius: BorderRadius.circular(4)),
          ]);
       }),
     );
  }


  Widget _buildMoodDistribution(List<DailyLog> logs) {
     final moodCounts = _statsService.calculateMoodCounts(logs);
     final total = logs.length;
     final sortedMoods = moodCounts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));

     return Column(
       children: sortedMoods.map((entry) {
          final percentage = (entry.value / total);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text(_translateMood(entry.key), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${entry.value} (${(percentage*100).toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 12),
                SizedBox(
                   width: 80,
                   child: LinearProgressIndicator(value: percentage, backgroundColor: Colors.grey[800], color: AppTheme.primaryColor, minHeight: 6),
                ),
              ],
            ),
          );
       }).toList(),
     );
  }
  
  Widget _buildActivityList(List<DailyLog> logs, int year) {
    final counts = _statsService.calculateActivityCounts(logs, year: year);
    if (counts.isEmpty) return const Text('Nenhuma atividade.', style: TextStyle(color: Colors.grey));
    
    final sorted = counts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    
    return Consumer(builder: (context, ref, _) {
       final settingsRepo = ref.watch(settingsRepositoryProvider);
       
       return Column(
         children: sorted.take(10).map((entry) {
            final item = settingsRepo.getItem(entry.key); 
            final ActivityItem? loadedItem = item; 
            final name = loadedItem?.name ?? 'Atividade';
            
            return ListTile(
               dense: true,
               contentPadding: EdgeInsets.zero,
               leading: CircleAvatar(
                 backgroundColor: Colors.grey[800],
                 child: Text(loadedItem?.emoji ?? '📌', style: const TextStyle(fontSize: 14)),
               ),
               title: Text(name, style: const TextStyle(color: Colors.white)),
               trailing: Text('${entry.value} vezes', style: const TextStyle(color: Colors.grey)),
            );
         }).toList(),
       );
    });
  }
}

// --- Components ---

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)), // Spotify Card Dark
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          if (subtitle != null) ...[
             const SizedBox(height: 4),
             Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
             Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ] else 
             Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _YearInPixels extends StatelessWidget {
  final Map<DateTime, int> data;

  const _YearInPixels({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          // Grid
          GridView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 32, // 1 label + 31 days
                childAspectRatio: 0.8,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
             ),
             itemCount: 13 * 32, // 1 Header Row + 12 Months
             itemBuilder: (context, index) {
                final row = index ~/ 32;
                final col = index % 32;

                // Header Row (Days)
                if (row == 0) {
                   if (col == 0) return const SizedBox();
                   if (col % 5 == 0) return Center(child: Text('$col', style: const TextStyle(color: Colors.grey, fontSize: 8))); // Show only every 5th day label
                   return const SizedBox();
                }

                final month = row; // 1..12
                // First Col is Month Label
                if (col == 0) {
                   const months = ['J','F','M','A','M','J','J','A','S','O','N','D']; // PT: J, F, M, A, M, J, J, A, S, O, N, D (Same mostly)
                   return Center(child: Text(months[month-1], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)));
                }

                final day = col; // 1..31
                
                // Simple validation:
                bool isValidDate = true;
                if ([4,6,9,11].contains(month) && day == 31) isValidDate = false;
                if (month == 2) {
                   if (day > 29) isValidDate = false;
                }

                if (!isValidDate) return Container(color: Colors.transparent);

                final score = _getScoreFor(month, day);
                return Container(
                   decoration: BoxDecoration(
                      color: _getColorForScore(score),
                      borderRadius: BorderRadius.circular(2),
                   ),
                );
             },
          ),
       ],
    );
  }
  
  int _getScoreFor(int month, int day) {
     for (var entry in data.entries) {
        if (entry.key.month == month && entry.key.day == day) return entry.value;
     }
     return 0; // No Data
  }

  Color _getColorForScore(int score) {
     switch (score) {
        case 5: return const Color(0xFF1DB954); // Happy
        case 4: return const Color(0xFF69F0AE); // Good
        case 3: return const Color(0xFFB3E5FC); // Neutral
        case 2: return const Color(0xFFFFA726); // Sad
        case 1: return const Color(0xFFE53935); // Terrible
        default: return const Color(0xFF333333); // Empty
     }
  }
}
