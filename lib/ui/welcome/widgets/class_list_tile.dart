import 'package:flutter/material.dart';

enum ClassListTileType {
  REGULAR,
  UPGRADE,
}

class ClassListTile extends StatelessWidget {
  final Color surfaceColor;
  final String classTitle;
  final String classDescription;
  final String? badge;
  final VoidCallback? onTap;
  final ClassListTileType type;
  final IconData icon;

  const ClassListTile({
    super.key,
    required this.surfaceColor,
    required this.classTitle,
    required this.classDescription,
    required this.icon,
    this.badge,
    this.type = ClassListTileType.REGULAR,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trailingIcon = Icon(Icons.arrow_forward_ios_rounded);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: Border(
          left: BorderSide(width: 8.0, color: surfaceColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(
              size: 32,
              icon,
              color: surfaceColor,
            ),
            title: Text(
              classTitle,
              style: type == ClassListTileType.REGULAR
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(classDescription),
            trailing: badge != null
                ? Badge(
                    label: Text(badge!),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: trailingIcon,
                  )
                : trailingIcon,
          ),
        ),
      ),
    );
  }
}
