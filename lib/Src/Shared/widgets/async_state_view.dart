import 'package:flutter/material.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.isEmpty,
    required this.child,
    required this.onRetry,
    this.emptyTitle = 'Nenhum registro encontrado',
    this.emptyMessage = 'Quando houver dados, eles aparecerão aqui.',
  });
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget child;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_outlined, size: 42),
                const SizedBox(height: 12),
                Text('Não foi possível carregar os dados', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
              ]),
            ),
          ),
        ),
      );
    }
    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inbox_outlined, size: 46),
            const SizedBox(height: 12),
            Text(emptyTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(emptyMessage, textAlign: TextAlign.center),
          ]),
        ),
      );
    }
    return child;
  }
}
