import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/database_service_factory.dart';
import '../models/bill_model.dart';
import '../models/category_model.dart';
import 'settings_screen.dart';
import 'bill_scan_capture_screen.dart';

class BillsListDashboardScreen extends StatefulWidget {
  final String userId;
  
  BillsListDashboardScreen({super.key, required this.userId});

  @override
  State<BillsListDashboardScreen> createState() => _BillsListDashboardScreenState();
}

class _BillsListDashboardScreenState extends State<BillsListDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _db = DatabaseServiceFactory.getService();
  
  String _selectedCategory = 'All';
  List<Category> _categories = [];
  List<Bill> _bills = [];
  bool _isLoading = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      final categories = await _db.getCategories(userId: widget.userId);
      setState(() {
        _categories = categories;
      });

      // Load bills
      await _loadBills();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBills() async {
    try {
      final bills = await _db.getUserBills(
        widget.userId,
        categoryId: _selectedCategoryId,
        vendorName: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      setState(() {
        _bills = bills;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bills: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      if (categoryName == 'All') {
        _selectedCategoryId = null;
      } else {
        final category = _categories.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => _categories.first,
        );
        _selectedCategoryId = category.categoryId;
      }
    });
    _loadBills();
  }


  List<String> get _categoryNames {
    final names = ['All'];
    names.addAll(_categories.map((c) => c.name));
    return names;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _loadBills();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search and Filter
                      _buildSearchAndFilter(isDark),

                      const SizedBox(height: 12),

                      // Category Chips
                      _buildCategoryChips(isDark),

                      const SizedBox(height: 16),

                      // Bills List
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildBillsList(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BillScanCaptureScreen(userId: widget.userId),
            ),
          ).then((_) => _loadBills()); // Reload bills after returning
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.photo_camera, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Bills',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(userId: widget.userId),
                ),
              );
            },
            color: isDark ? AppTheme.textDark : AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Row(
      children: [
        // Search Field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.zinc800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search bills...',
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            style: GoogleFonts.manrope(
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
            ),
            onChanged: _onSearchChanged,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.zinc800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // TODO: Show filter dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter options - Coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categoryNames.map((categoryName) {
                final isSelected = _selectedCategory == categoryName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(categoryName),
                    selected: isSelected,
                    onSelected: (selected) {
                      _onCategorySelected(categoryName);
                    },
                    backgroundColor: isDark ? AppTheme.zinc800 : Colors.white,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppTheme.textDark : AppTheme.textLight),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Sort Button
        TextButton.icon(
          onPressed: () {
            // TODO: Show sort options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sort options - Coming soon')),
            );
          },
          icon: Icon(
            Icons.swap_vert,
            size: 18,
            color: isDark ? AppTheme.textDark : AppTheme.textLight,
          ),
          label: Text(
            'Sort',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillsList(bool isDark) {
    if (_bills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
              ),
              const SizedBox(height: 16),
              Text(
                'No bills found',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textDark : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the camera button to scan your first bill',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _bills.map((bill) => _buildBillCard(bill, isDark)).toList(),
    );
  }

  Widget _buildBillCard(Bill bill, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(bill.categoryColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(bill.categoryName ?? 'Uncategorized'),
              color: _getCategoryColor(bill.categoryColor),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Bill Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill.vendorName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      '${bill.currency} ${bill.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(bill.billDate),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppTheme.subtleDark : AppTheme.subtleLight,
                      ),
                    ),
                    if (bill.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(bill.categoryColor).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bill.categoryName!,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(bill.categoryColor),
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
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.local_gas_station;
      case 'Utilities':
        return Icons.home;
      case 'Groceries':
        return Icons.shopping_bag;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getCategoryColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}


