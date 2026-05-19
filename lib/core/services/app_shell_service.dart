import 'package:flutter/material.dart';

final appShellKey = GlobalKey<ScaffoldState>();

void openAppSidebar() => appShellKey.currentState?.openDrawer();
