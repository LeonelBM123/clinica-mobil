import 'package:flutter/material.dart';
import 'drawer_menu_item.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class CustomDrawer extends StatelessWidget {
  final String userRole;
  final String? userEmail;
  final List<DrawerMenuItem> menuItems;
  final VoidCallback onLogout;
  final IconData userIcon;

  const CustomDrawer({
    super.key,
    required this.userRole,
    this.userEmail,
    required this.menuItems,
    required this.onLogout,
    this.userIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header del drawer
            _buildDrawerHeader(),
            
            // Elementos del menú
            ...menuItems.map((item) => _buildMenuItem(item)),
            
            // Separador
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            
            SizedBox(height: 8),
            
            // Botón Cerrar Sesión
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: DrawerHeader(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                userIcon,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              userRole,
              style: AppTextStyles.drawerHeader,
            ),
            Text(
              userEmail ?? "Sin correo",
              style: AppTextStyles.withOpacity(AppTextStyles.drawerSubheader, 0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item) {
    if (item.subItems != null && item.subItems!.isNotEmpty) {
      // Item con sub-elementos (ExpansionTile)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta de sección
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              item.title.toUpperCase(),
              style: AppTextStyles.sectionLabel,
            ),
          ),
          
          ExpansionTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              item.title,
              style: AppTextStyles.menuItem,
            ),
            children: item.subItems!
                .map((subItem) => _buildSubMenuItem(subItem))
                .toList(),
          ),
          SizedBox(height: 8),
        ],
      );
    } else {
      // Item simple
      return ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: AppTextStyles.menuItem,
        ),
        onTap: item.onTap,
      );
    }
  }

  Widget _buildSubMenuItem(DrawerSubItem subItem) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          subItem.icon,
          color: AppColors.primary,
          size: 20,
        ),
        title: Text(
          subItem.title,
          style: AppTextStyles.subMenuItem,
        ),
        onTap: subItem.onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Cerrar Sesión',
          style: AppTextStyles.withColor(AppTextStyles.menuItem, AppColors.error),
        ),
        onTap: onLogout,
      ),
    );
  }
}