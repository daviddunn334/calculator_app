import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 40,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Tracker',
                        style: AppTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage NDT equipment and supplies',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equipment & Supplies',
                      style: AppTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement add inventory item
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingLarge,
                          vertical: AppTheme.paddingMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search and filter bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search inventory...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // TODO: Implement filters
                        },
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Categories
                _buildCategorySection('Equipment', [
                  _buildInventoryCard(
                    name: 'UT Flaw Detector',
                    model: 'OmniScan MX2',
                    status: InventoryStatus.inUse,
                    lastMaintenance: 'Last maintained: Jan 15, 2024',
                    serialNumber: 'SN: UT-2023-456',
                  ),
                  _buildInventoryCard(
                    name: 'MT Yoke',
                    model: 'Y-7',
                    status: InventoryStatus.available,
                    lastMaintenance: 'Last maintained: Dec 20, 2023',
                    serialNumber: 'SN: MT-2023-789',
                  ),
                ]),
                const SizedBox(height: 24),
                _buildCategorySection('Consumables', [
                  _buildInventoryCard(
                    name: 'MT Particles (Black)',
                    model: '14A Powder',
                    status: InventoryStatus.lowStock,
                    quantity: 'Quantity: 2 bottles',
                    serialNumber: 'Batch: MP-2024-001',
                  ),
                  _buildInventoryCard(
                    name: 'UT Couplant',
                    model: 'Glycerin Gel',
                    status: InventoryStatus.available,
                    quantity: 'Quantity: 15 bottles',
                    serialNumber: 'Batch: UC-2024-003',
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: item,
            )),
      ],
    );
  }

  Widget _buildInventoryCard({
    required String name,
    required String model,
    required InventoryStatus status,
    String? lastMaintenance,
    String? quantity,
    required String serialNumber,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Text(
                    status.label,
                    style: AppTheme.bodySmall.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w600,
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
                  lastMaintenance ?? quantity ?? '',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  serialNumber,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum InventoryStatus {
  available(Colors.green, 'Available'),
  inUse(Colors.blue, 'In Use'),
  lowStock(Colors.orange, 'Low Stock'),
  maintenance(Colors.red, 'Maintenance');

  final Color color;
  final String label;

  const InventoryStatus(this.color, this.label);
} 