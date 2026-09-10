import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_list_page.dart';

class ResourceTabDefinition {
  const ResourceTabDefinition({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.endpoint,
  });

  final String label;
  final String title;
  final String subtitle;
  final String endpoint;
}

class ResourceTabsPage extends StatelessWidget {
  const ResourceTabsPage({super.key, required this.tabs});

  final List<ResourceTabDefinition> tabs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: tabs.map((tab) => Tab(text: tab.label)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: tabs
                  .map(
                    (tab) => ResourceListPage(
                      title: tab.title,
                      subtitle: tab.subtitle,
                      endpoint: tab.endpoint,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
