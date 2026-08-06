// Barrel export — import this single file to get all shared widgets.
export 'brand/app_brand.dart';
export 'layout/adaptive_layout.dart';
export 'layout/app_container.dart';
export 'utils/animated_tap.dart';
export 'navigation/app_app_bar.dart' show AppBarConfig, AppBarLeading, AppAppBar, AppSliverAppBar;
export 'buttons/app_fab.dart';
export '../../features/auth/presentation/widgets/app_auth_widgets.dart';
export 'avatars/app_avatar.dart';
export 'avatars/app_avatar_group.dart';
export 'badges/app_badge.dart';
export 'bottom_sheets/app_bottom_sheet.dart';
export 'buttons/app_button.dart';
export 'cards/app_card.dart';
export 'graphs/app_chart.dart';
export 'chat/app_chat_bubble.dart';
export 'chips/app_chip.dart';
export 'chips/category_chip.dart';
export 'dialogs/app_dialog.dart';
export 'feedback/app_error_widget.dart';
export 'inputs/app_form_field.dart';
export 'inputs/dropdown_input.dart';
export 'inputs/image_picker_input.dart';
export 'inputs/multi_select_dropdown_input.dart';
export 'lists/app_list_tile.dart';
export 'feedback/app_loading.dart';
export 'health/app_medicine_widgets.dart';
export 'navigation/app_navigation.dart';
export 'media/app_network_image.dart';
export 'inputs/app_otp_field.dart';
export 'navigation/app_permission_nav.dart';
export 'cards/app_professional_card.dart';
export 'feedback/app_snackbar.dart';
export 'navigation/app_tab_bar.dart';
export 'inputs/app_text_field.dart';
export 'inputs/phone_input.dart';
export 'inputs/dob_picker.dart';
export 'inputs/time_picker_input.dart';
export 'texts/app_text.dart';
export 'health/app_vitals_widgets.dart';
export 'cards/app_gradient_card.dart';
export 'feedback/offline_banner.dart';
export 'feedback/offline_page.dart';
export 'feedback/network_required.dart';
export 'navigation/page_transition.dart';
export 'layout/section_header.dart';
export 'texts/section_header_text.dart';
export 'texts/empty_state_text.dart';
export 'texts/page_header_text.dart';
export 'texts/highlighted_text.dart';

// Four names are defined twice across the library. Rather than delete anyone's
// implementation, the barrel picks one canonical export per name so callers can
// `import widgets.dart` and use them unambiguously — which is the whole point
// of the shared library. Canonical: AppStatRow + AppAdherenceRing from graphs/,
// AppStatCard + AppInfoCard from cards/.
export 'texts/stat_text.dart' hide AppStatRow;
export 'texts/info_label_text.dart' hide AppInfoCard;
export 'skeleton/shimmer_widget.dart';
export 'feedback/sync_indicator.dart';
export 'tables/app_table.dart';
export 'search_inputs/search_text_input.dart';
export 'search_inputs/search_text_voice_input.dart';
export 'voice_search/voice_search_modal.dart';
