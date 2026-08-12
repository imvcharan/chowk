import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';
import '../../../services/api_service.dart';

enum AdminSection { overview, users, articles, categories, media, liveUpdates, settings }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminSection _selectedSection = AdminSection.overview;
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _articles = [];
  List<dynamic> _categories = [];
  List<dynamic> _users = [];
  final List<String> _roleOptions = ['subscriber', 'reporter', 'editor', 'admin', 'super_admin', 'publisher', 'moderator'];
  bool _sidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newsResponse = await ApiService.getAllNews(limit: 50);
      final categoryResponse = await ApiService.getCategories();

      setState(() {
        _articles = List<dynamic>.from(newsResponse['data'] ?? []);
        _categories = List<dynamic>.from(categoryResponse);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usersResponse = await ApiService.getAdminUsers();
      setState(() {
        _users = List<dynamic>.from(usersResponse);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(int userId, String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.updateUserRole(userId, role);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createCategory(String name, String description) async {
    try {
      await ApiService.createCategory(name: name, description: description);
      await _refreshDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }

  Future<void> _updateCategory(int id, String name) async {
    try {
      await ApiService.updateCategory(categoryId: id, name: name);
      await _refreshDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      await ApiService.deleteCategory(id);
      await _refreshDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  Future<void> _deleteArticle(int id) async {
    try {
      await ApiService.deleteNews(id);
      await _refreshDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting article: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      await ApiService.deleteUser(id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _openCreateUserDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    String selectedRole = _roleOptions.first;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create user'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || !value.contains('@') ? 'Valid email is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) => value == null || value.length < 8 ? 'Password must be at least 8 characters' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: _roleOptions
                            .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(labelText: 'City (optional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stateController,
                        decoration: const InputDecoration(labelText: 'State (optional)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSubmitting = true);
                        try {
                          await ApiService.createAdminUser(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            role: selectedRole,
                            city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : null,
                            state: stateController.text.trim().isNotEmpty ? stateController.text.trim() : null,
                          );
                          if (mounted) {
                            await _loadUsers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User created successfully')),
                            );
                          }
                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error creating user: $e')),
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _confirmDeleteArticle(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete article?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteArticle(id);
    }
  }

  Future<void> _openArticleForm({Map<String, dynamic>? article}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: article?['title']?.toString() ?? '');
    final descriptionController = TextEditingController(text: article?['description']?.toString() ?? '');
    final contentController = TextEditingController(text: article?['content']?.toString() ?? '');
    final imageController = TextEditingController(text: article?['image_url']?.toString() ?? '');
    int? selectedCategoryId = article?['category_id'] as int?;
    bool isFeatured = article?['is_featured'] == true;
    bool isPublished = (article?['status']?.toString() ?? 'published') == 'published';
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(article == null ? 'Create Article' : 'Edit Article'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Short description'),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        items: _categories
                            .map((cat) => DropdownMenuItem<int>(
                                  value: cat['id'] as int,
                                  child: Text(cat['name'] ?? ''),
                                ))
                            .toList(),
                        onChanged: (value) => setDialogState(() => selectedCategoryId = value),
                        decoration: const InputDecoration(labelText: 'Category'),
                        validator: (value) => value == null ? 'Category is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(labelText: 'Content'),
                        minLines: 5,
                        maxLines: 8,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Content is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: imageController,
                        decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Featured article'),
                        value: isFeatured,
                        onChanged: (value) => setDialogState(() => isFeatured = value),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Publish immediately'),
                        value: isPublished,
                        onChanged: (value) => setDialogState(() => isPublished = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedCategoryId == null) return;
                        setDialogState(() => isSubmitting = true);
                        try {
                          if (article == null) {
                            await ApiService.createNews(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              content: contentController.text.trim(),
                              categoryId: selectedCategoryId!,
                              imageUrl: imageController.text.trim().isNotEmpty ? imageController.text.trim() : null,
                              featured: isFeatured,
                              isPublished: isPublished,
                            );
                          } else {
                            await ApiService.updateNews(
                              article['id'] as int,
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              content: contentController.text.trim(),
                              categoryId: selectedCategoryId!,
                              imageUrl: imageController.text.trim().isNotEmpty ? imageController.text.trim() : null,
                              featured: isFeatured,
                              isPublished: isPublished,
                            );
                          }
                          if (mounted) {
                            await _refreshDashboard();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(article == null ? 'Article created successfully' : 'Article updated successfully')),
                            );
                          }
                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving article: $e')),
                            );
                          }
                        }
                      },
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(article == null ? 'Create article' : 'Save changes'),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _selectSection(AdminSection section) {
    setState(() {
      _selectedSection = section;
      _sidebarOpen = false; // Close sidebar on mobile after selection
    });
    if (section == AdminSection.users) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.username ?? 'Admin';
    final userEmail = authProvider.email ?? 'admin@chowk.com';
    final showSidebar = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.chowkBlack,
        elevation: 1,
        leading: !showSidebar
            ? IconButton(
                icon: Icon(_sidebarOpen ? Icons.close : Icons.menu, color: AppTheme.chowkBlack),
                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
                tooltip: _sidebarOpen ? 'Close menu' : 'Open menu',
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.chowkBlack),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (showSidebar)
                  Container(
                    width: 280,
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                      ),
                    ),
                    child: _buildSidebar(context, userName, userEmail),
                  ),
                Expanded(
                  child: Container(
                    color: AppTheme.softWhite,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(child: Text('Error: $_errorMessage'))
                            : _buildMainContent(context),
                  ),
                ),
              ],
            ),
            if (!showSidebar && _sidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _sidebarOpen = false),
                  child: Container(color: Colors.black26),
                ),
              ),
            if (!showSidebar && _sidebarOpen)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 280,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    boxShadow: [
                      BoxShadow(color: Color(0xFF00000015), blurRadius: 16, offset: Offset(4, 0)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildSidebar(context, userName, userEmail),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, String userName, String userEmail) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.chowkOrange.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard, color: AppTheme.chowkOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('CHOWK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Admin console', style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSidebarItem(context, AdminSection.overview, Icons.insights, 'Overview'),
            _buildSidebarItem(context, AdminSection.articles, Icons.article_outlined, 'Articles'),
            _buildSidebarItem(context, AdminSection.users, Icons.people_outline, 'Users'),
            _buildSidebarItem(context, AdminSection.categories, Icons.category_outlined, 'Categories'),
            _buildSidebarItem(context, AdminSection.media, Icons.cloud_upload_outlined, 'Media'),
            _buildSidebarItem(context, AdminSection.liveUpdates, Icons.flash_on_outlined, 'Live Updates'),
            _buildSidebarItem(context, AdminSection.settings, Icons.settings_outlined, 'Settings'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.chowkOrange,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, AdminSection section, IconData icon, String title) {
    final selected = _selectedSection == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppTheme.lightGray : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: selected ? AppTheme.chowkOrange : AppTheme.mutedText),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppTheme.chowkBlack : AppTheme.mutedText,
            ),
          ),
          trailing: selected ? const Icon(Icons.chevron_right, color: AppTheme.chowkOrange) : null,
          onTap: () => _selectSection(section),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildSectionContent(context),
    );
  }

  Widget _buildSectionContent(BuildContext context) {
    switch (_selectedSection) {
      case AdminSection.overview:
        return _buildOverviewSection(context);
      case AdminSection.articles:
        return _buildArticlesSection(context);
      case AdminSection.categories:
        return _buildCategoriesSection(context);
      case AdminSection.media:
        return _buildMediaSection(context);
      case AdminSection.liveUpdates:
        return _buildLiveUpdatesSection(context);
      case AdminSection.settings:
        return _buildSettingsSection(context);
      case AdminSection.users:
        return _buildUsersSection(context);
    }
  }

  Widget _buildOverviewSection(BuildContext context) {
    final totalArticles = _articles.length;
    final totalCategories = _categories.length;
    final publishedCount = _articles.where((item) => (item['status'] ?? 'published') == 'published').length;
    final draftCount = _articles.where((item) => (item['status'] ?? 'published') != 'published').length;
    
    final avgArticlesPerCategory = totalCategories > 0 ? (totalArticles / totalCategories).toStringAsFixed(1) : '0';
    final engagementRate = ((totalArticles * 2.5).clamp(0, 100)).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text('Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          const Text('A modern SaaS admin experience for managing news, categories, analytics and settings.'),
          const SizedBox(height: 32),
          
          // Key Metrics Row 1
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: [
              _buildStatCard(
                'Total Articles',
                totalArticles.toString(),
                '+12%',
                Icons.article_outlined,
                AppTheme.chowkOrange,
              ),
              _buildStatCard(
                'Published',
                publishedCount.toString(),
                '+8%',
                Icons.check_circle_outlined,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                'Drafts',
                draftCount.toString(),
                '+4%',
                Icons.edit_outlined,
                const Color(0xFF3B82F6),
              ),
              _buildStatCard(
                'Categories',
                totalCategories.toString(),
                '+15%',
                Icons.category_outlined,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Analytics Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.smallList,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Content Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsBox(
                        'Avg Articles/Category',
                        avgArticlesPerCategory,
                        'articles',
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsBox(
                        'Engagement Rate',
                        '$engagementRate%',
                        'rate',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsBox(
                        'Content Health',
                        '${(publishedCount > 0 ? ((publishedCount / totalArticles) * 100).toStringAsFixed(0) : '0')}%',
                        'published',
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Activity Chart
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.smallList,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Content Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                _buildSimpleChart(),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Latest Articles
          _buildSectionHeader('Latest Articles', 'Manage published content and drafts.'),
          const SizedBox(height: 12),
          _buildArticleListPreview(),
          const SizedBox(height: 32),
        ],
      );
  }

  Widget _buildAnalyticsBox(String label, String value, String type, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Mon', 45, const Color(0xFF3B82F6)),
              _buildChartBar('Tue', 62, const Color(0xFF3B82F6)),
              _buildChartBar('Wed', 38, const Color(0xFF3B82F6)),
              _buildChartBar('Thu', 71, const Color(0xFF3B82F6)),
              _buildChartBar('Fri', 54, const Color(0xFF10B981)),
              _buildChartBar('Sat', 28, const Color(0xFF10B981)),
              _buildChartBar('Sun', 42, const Color(0xFFF59E0B)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend('Published', const Color(0xFF3B82F6)),
            const SizedBox(width: 24),
            _buildChartLegend('Active', const Color(0xFF10B981)),
            const SizedBox(width: 24),
            _buildChartLegend('Pending', const Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height * 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.mutedText)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String trend, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.smallList,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.mutedText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.chowkBlack)),
          const SizedBox(height: 8),
          Text(trend, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildArticleListPreview() {
    if (_articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No articles found yet.'),
      );
    }

    return Column(
      children: _articles.take(5).map((article) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.smallList,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article['title'] ?? 'Untitled', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(article['description'] ?? '', style: const TextStyle(color: AppTheme.mutedText)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag(article['category_name'] ?? 'Uncategorized'),
                        _buildTag((article['status'] ?? 'published').toString()),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.chowkOrange),
                onPressed: () {
                  final id = article['id'] as int?;
                  if (id != null) {
                    _confirmDeleteArticle(id);
                  }
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.chowkBlack)),
    );
  }

  Widget _buildArticlesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Articles', 'Manage published stories, drafts, and content operations.'),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _openArticleForm(),
              icon: const Icon(Icons.add),
              label: const Text('Create article'),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _articles.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('No articles available.'),
              ))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  final id = article['id'] as int?;
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.smallList,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(article['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(article['description'] ?? '', style: const TextStyle(color: AppTheme.mutedText)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildTag(article['category_name'] ?? 'Unknown'),
                                  _buildTag((article['status'] ?? 'published').toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.chowkOrange),
                              onPressed: () => _openArticleForm(article: article),
                            ),
                            if (id != null)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteArticle(id),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildUsersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Users', 'Manage user roles and access control.'),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _openCreateUserDialog,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Create user'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Change the role dropdown for a user to update their permissions.',
                style: TextStyle(color: AppTheme.mutedText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _users.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No users found. Refresh to load users.'),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final userId = user['id'] as int?;
                  final userRole = user['role'] as String? ?? 'subscriber';

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.smallList,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.mutedText)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildTag('Joined ${user['createdAt']?.toString().split('T').first ?? ''}'),
                                  _buildTag(user['isActive'] == true ? 'Active' : 'Inactive'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            value: userRole,
                            decoration: const InputDecoration(labelText: 'Role'),
                            items: _roleOptions
                                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null && userId != null && value != userRole) {
                                _updateUserRole(userId, value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Delete user',
                          onPressed: userId == null
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Delete user?'),
                                        content: const Text('This will permanently remove the user.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(dialogContext).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmed == true) {
                                    _deleteUser(userId);
                                  }
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Future<void> _openCategoryDialog({Map<String, dynamic>? category}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?['name']?.toString() ?? '');
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(category == null ? 'Create category' : 'Edit category'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category name'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Category name is required' : null,
              ),
            ),
            actions: [
              TextButton(onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSubmitting = true);
                        try {
                          if (category == null) {
                            await _createCategory(nameController.text.trim(), '');
                          } else {
                            await _updateCategory(category['id'] as int, nameController.text.trim());
                          }
                          Navigator.of(dialogContext).pop();
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving category: $e')));
                          }
                        }
                      },
                child: Text(category == null ? 'Create' : 'Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Categories', 'Create and organize your news sections.'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Add, rename, or remove categories that power article organization.',
                style: const TextStyle(color: AppTheme.mutedText),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _categories.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('No categories yet.'),
              ))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final categoryId = category['id'] as int?;
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.smallList,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(category['slug'] ?? '', style: const TextStyle(color: AppTheme.mutedText)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: categoryId == null ? null : () => _openCategoryDialog(category: category),
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.chowkOrange),
                        ),
                        IconButton(
                          onPressed: categoryId == null
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Delete category?'),
                                        content: const Text('This will remove the category from the system.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                                          ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Delete')),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmed == true) {
                                    await _deleteCategory(categoryId);
                                  }
                                },
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Media', 'Manage and attach image/video assets to your articles.'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.smallList,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Web file upload is not enabled in this demo build.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              Text('Use externally-hosted image URLs when creating articles. Full media upload support can be added with platform-specific file picker integration.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveUpdatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Live Updates', 'Publish quick live report posts to the app.'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.adminLive);
          },
          icon: const Icon(Icons.flash_on),
          label: const Text('Publish live update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.chowkOrange,
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Use this section to publish live updates that appear in the frontend live feed. Each published update is broadcast in real time through Pusher.',
          style: const TextStyle(color: AppTheme.mutedText),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Settings', 'Manage account settings and sign out.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.smallList,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(authProvider.username ?? 'Admin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text('Email', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(authProvider.email ?? 'admin@chowk.com', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
