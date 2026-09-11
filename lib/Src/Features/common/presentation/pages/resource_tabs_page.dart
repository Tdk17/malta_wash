import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_list_page.dart';

class ResourceTabDefinition {
  const ResourceTabDefinition({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.endpoint,
    this.visibleKeys,
    this.labels = const {},
  });

  final String label;
  final String title;
  final String subtitle;
  final String endpoint;
  final List<String>? visibleKeys;
  final Map<String, String> labels;
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
            color: Colors.transparent,
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
                      visibleKeys: tab.visibleKeys,
                      labels: tab.labels,
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
