import 'package:flutter/material.dart';
import 'package:good_day/core/theme/app_theme.dart';

class CategorizedIconPicker extends StatefulWidget {
  final Function(IconData) onIconSelected;

  const CategorizedIconPicker({super.key, required this.onIconSelected});

  @override
  State<CategorizedIconPicker> createState() => _CategorizedIconPickerState();
}

class _CategorizedIconPickerState extends State<CategorizedIconPicker> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<IconData>> _iconCategories = {
    'Geral': [
      Icons.star, Icons.favorite, Icons.check, Icons.close, Icons.add, Icons.remove,
      Icons.home, Icons.person, Icons.settings, Icons.search, Icons.menu,
    ],
    'Comida': [
      Icons.restaurant, Icons.local_dining, Icons.fastfood, Icons.local_cafe, Icons.local_bar,
      Icons.cake, Icons.local_pizza, Icons.icecream, Icons.breakfast_dining, Icons.lunch_dining,
      Icons.dinner_dining, Icons.kitchen,
    ],
    'Atividades': [
      Icons.work, Icons.school, Icons.book, Icons.menu_book, Icons.edit, Icons.computer,
      Icons.science, Icons.palette, Icons.brush, Icons.music_note, Icons.movie, Icons.theaters,
      Icons.mic, Icons.camera_alt,
    ],
    'Esporte': [
      Icons.fitness_center, Icons.directions_run, Icons.directions_bike, Icons.pool,
      Icons.sports_soccer, Icons.sports_basketball, Icons.sports_tennis, Icons.sports_volleyball,
      Icons.hiking, Icons.surfing,
    ],
    'Saúde': [
      Icons.local_hospital, Icons.favorite, Icons.healing, Icons.medication, Icons.local_pharmacy,
      Icons.bed, Icons.hotel, Icons.spa, Icons.self_improvement,
    ],
    'Viagem': [
      Icons.flight, Icons.train, Icons.directions_bus, Icons.directions_car, Icons.local_taxi,
      Icons.map, Icons.location_on, Icons.explore, Icons.beach_access, Icons.camera_alt,
    ],
    'Social': [
      Icons.people, Icons.person_add, Icons.groups, Icons.emoji_people, Icons.diversity_3,
      Icons.celebration, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied,
    ],
    'Natureza': [
      Icons.wb_sunny, Icons.nightlight_round, Icons.cloud, Icons.water_drop, Icons.park,
      Icons.forest, Icons.terrain, Icons.pets, Icons.bug_report,
    ],
    'Objetos': [
      Icons.shopping_cart, Icons.shopping_bag, Icons.wallet, Icons.credit_card, Icons.attach_money,
      Icons.phone, Icons.smartphone, Icons.laptop, Icons.tv, Icons.watch,
      Icons.chair, Icons.weekend, Icons.lightbulb,
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _iconCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: _iconCategories.keys.map((key) => Tab(text: key)).toList(),
          ),
          
          const Divider(height: 1, color: Colors.white10),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _iconCategories.values.map((icons) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: icons.length,
                  itemBuilder: (context, index) {
                    final icon = icons[index];
                    return InkWell(
                      onTap: () => widget.onIconSelected(icon),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
