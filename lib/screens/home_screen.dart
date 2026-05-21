import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/products_provider.dart';
import 'products_screen.dart';
import 'chat_screen.dart';
import 'create_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _tabs = const [
    ProductsScreen(),
    ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Carga inicial del contador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserStatsProvider>().refresh();
    });
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  Future<void> _openCreateProduct() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateProductScreen()),
    );
    if (created == true && mounted) {
      // Refrescar lista y contador
      await context.read<ProductsProvider>().fetch();
      await context.read<UserStatsProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user  = context.watch<AuthProvider>().user;
    final stats = context.watch<UserStatsProvider>();
    final isAdmin = user?.role == 'admin';
    final showFab = isAdmin && _index == 0;

    // Texto del badge: "Nombre (N)"
    final displayName = user?.name ?? '—';
    final count = stats.stats?.productCount ?? 0;
    final badge = '$displayName ($count)';

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Catálogo' : 'Chat en vivo'),
        actions: [
          // Badge "Nombre (N)" siempre visible
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (v) {
              if (v == 'logout') _confirmLogout();
              if (v == 'refresh') context.read<UserStatsProvider>().refresh();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Rol: ${user?.role ?? "—"}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Productos creados: $count',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'refresh', child: Text('Actualizar contador')),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: _openCreateProduct,
              icon: const Icon(Icons.add),
              label: const Text('Crear producto'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Productos'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}
