import 'package:flutter/material.dart';

enum ClassListTileType {
  REGULAR,
  UPGRADE,
}

class ClassListTile extends StatelessWidget {
  final Color surfaceColor;
  final String classTitle;
  final String classDescription;
  final List<Widget> badges;
  final VoidCallback? onTap;
  final ClassListTileType type;

  const ClassListTile({
    super.key,
    required this.surfaceColor,
    required this.classTitle,
    required this.classDescription,
    this.badges = const [],
    this.type = ClassListTileType.REGULAR,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classTitle,
                      style: TextStyle(
                        fontSize: type == ClassListTileType.REGULAR ? 36 : 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ...badges,
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        classDescription,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClassListTileBadge extends StatelessWidget {
  final Color surfaceColor;
  final String text;

  const ClassListTileBadge({
    super.key,
    required this.surfaceColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
