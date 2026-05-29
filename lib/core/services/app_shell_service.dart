import 'package:flutter/material.dart';

final appShellKey = GlobalKey<ScaffoldState>();

void openAppSidebar() => appShellKey.currentState?.openDrawer();

// ── Tab switching ─────────────────────────────────────────────────────────────
void Function(String slug)? _tabSwitcher;

void registerTabSwitcher(void Function(String slug) fn) => _tabSwitcher = fn;
void unregisterTabSwitcher() => _tabSwitcher = null;
void switchToTab(String slug) => _tabSwitcher?.call(slug);
