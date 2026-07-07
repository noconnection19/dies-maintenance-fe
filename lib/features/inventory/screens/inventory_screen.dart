import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_shell.dart';
import '../../dashboard/data/line_stop_service.dart';

class InventoryPart {
  final String partNo;
  final String name;
  final String location;
  final int initialStock;
  int currentStock;

  InventoryPart({
    required this.partNo,
    required this.name,
    required this.location,
    required this.initialStock,
  }) : currentStock = initialStock;
}

class InventoryHomeScreen extends StatefulWidget {
  final String? taskId;
  final PartOrder? editOrder;

  const InventoryHomeScreen({
    super.key,
    this.taskId,
    this.editOrder,
  });

  @override
  State<InventoryHomeScreen> createState() => _InventoryHomeScreenState();
}

class _InventoryHomeScreenState extends State<InventoryHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.editOrder != null) {
      for (final detail in widget.editOrder!.details) {
        final idx = _parts.indexWhere(
          (p) => p.name == detail.partName && p.partNo == detail.partCd,
        );
        if (idx != -1) {
          _cart[idx] = detail.qty;
          _parts[idx].currentStock = (_parts[idx].initialStock - detail.qty).clamp(0, 9999);
        }
      }
    }
  }

  // Mock Inventory Parts
  final List<InventoryPart> _parts = [
    InventoryPart(partNo: '123456789AWE', name: 'Shield Shock 11mm', location: 'WH01-R04-4A', initialStock: 5),
    InventoryPart(partNo: '123456789AWE', name: 'Shield Shock 15mm', location: 'WH01-R04-4A', initialStock: 5),
    InventoryPart(partNo: '123456789AWE', name: 'Shield Shock 7mm', location: 'WH01-R04-4A', initialStock: 21),
    InventoryPart(partNo: '123456789AWE', name: 'Shield Shock 20mm', location: 'WH01-R04-4A', initialStock: 21),
    InventoryPart(partNo: '123456789AWE', name: 'Seal Ring Kit A', location: 'WH01-R04-4A', initialStock: 0),
    InventoryPart(partNo: '123456789AWE', name: 'Gasket Sheet 2mm', location: 'WH01-R04-4A', initialStock: 21),
    InventoryPart(partNo: '123456789AWE', name: 'Lock Bolt M12', location: 'WH01-R04-4A', initialStock: 21),
    InventoryPart(partNo: '123456789AWE', name: 'Spring Washer 8mm', location: 'WH01-R04-4A', initialStock: 21),
    InventoryPart(partNo: '123456789AWE', name: 'Hex Nut M10', location: 'WH01-R04-4A', initialStock: 21),
  ];

  // Shopping Cart: Map of Part index to quantity in cart
  final Map<int, int> _cart = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addToCart(int index) {
    final part = _parts[index];
    if (part.currentStock <= 0) return;

    setState(() {
      part.currentStock--;
      _cart[index] = (_cart[index] ?? 0) + 1;
    });
  }

  void _removeFromCart(int index) {
    if (!_cart.containsKey(index)) return;
    final part = _parts[index];

    setState(() {
      part.currentStock++;
      final newQty = _cart[index]! - 1;
      if (newQty <= 0) {
        _cart.remove(index);
      } else {
        _cart[index] = newQty;
      }
    });
  }

  void _submitOrder() {
    if (_cart.isEmpty) return;
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirmation Order Part',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kindly double-check that all selected parts are accurate before confirming your order.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.green, size: 16),
                      label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _processOrder();
                      },
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Confirm to Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processOrder() async {
    final payload = _cart.entries.map((entry) {
      final part = _parts[entry.key];
      final qty = entry.value;
      return {
        'part_cd': part.partNo,
        'part_name': part.name,
        'location': part.location,
        'qty': qty,
      };
    }).toList();

    try {
      if (widget.editOrder != null) {
        await LineStopService.updatePartOrder(widget.editOrder!.id, payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (widget.taskId != null) {
        await LineStopService.createPartOrder(widget.taskId!, payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order created successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order to inventory completed successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter parts based on query
    final List<int> filteredIndices = [];
    for (int i = 0; i < _parts.length; i++) {
      final part = _parts[i];
      if (part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          part.partNo.toLowerCase().contains(_searchQuery.toLowerCase())) {
        filteredIndices.add(i);
      }
    }

    return AppShell(
      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Back button & Title ────────────────────────────────
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
                label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  backgroundColor: AppColors.greenLight,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              const Text(
                'PART INVENTORY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // ── Split Layout ──────────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left Column: Grid Panel ──
                Expanded(
                  flex: 7,
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Dies Repair',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Search input row
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Search part no or name here...',
                                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.divider),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.divider),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _searchQuery = _searchCtrl.text);
                                },
                                icon: const Icon(Icons.search, size: 16),
                                label: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Grid View of parts
                          Expanded(
                            child: filteredIndices.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No parts found matching your criteria.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: filteredIndices.length,
                                    itemBuilder: (context, idx) {
                                      final partIdx = filteredIndices[idx];
                                      final part = _parts[partIdx];
                                      final isOutOfStock = part.currentStock <= 0;

                                      return Card(
                                        color: const Color(0xFFF8FAFC),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isOutOfStock
                                                ? const Color(0xFFE2E8F0)
                                                : const Color(0xFFE2E8F0),
                                            width: 1,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Image placeholder
                                            Container(
                                              height: 100,
                                              width: double.infinity,
                                              color: const Color(0xFFF1F5F9),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.construction_rounded,
                                                  size: 32,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    part.partNo,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textMuted,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    part.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Location: ${part.location}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Stock: ${part.currentStock}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: isOutOfStock
                                                              ? AppColors.error
                                                              : AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: isOutOfStock ? null : () => _addToCart(partIdx),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: isOutOfStock
                                                                  ? Colors.grey.shade300
                                                                  : const Color(0xFF10B981),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 14,
                                                            color: isOutOfStock
                                                                ? Colors.grey.shade400
                                                                : const Color(0xFF10B981),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // ── Right Column: Shopping Cart ──
                Expanded(
                  flex: 3,
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Added Part List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Divider(height: 32, color: AppColors.divider),

                          // Cart content
                          Expanded(
                            child: _cart.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No parts added yet.\nStart by adding a part',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _cart.length,
                                    itemBuilder: (context, idx) {
                                      final entry = _cart.entries.elementAt(idx);
                                      final partIdx = entry.key;
                                      final qty = entry.value;
                                      final part = _parts[partIdx];

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    part.name,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    part.partNo,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Minus Button
                                            GestureDetector(
                                              onTap: () => _removeFromCart(partIdx),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                child: const Icon(Icons.remove, size: 12, color: Colors.grey),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                '$qty',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            // Plus Button
                                            GestureDetector(
                                              onTap: part.currentStock <= 0 ? null : () => _addToCart(partIdx),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: part.currentStock <= 0
                                                        ? Colors.grey.shade200
                                                        : Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 12,
                                                  color: part.currentStock <= 0 ? Colors.grey.shade300 : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // Checkout button
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _cart.isEmpty ? null : _submitOrder,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text(
                                'Select Part',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007A5E), // Match PT Nusa Toyotetsu green tone
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade200,
                                disabledForegroundColor: Colors.grey.shade400,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
