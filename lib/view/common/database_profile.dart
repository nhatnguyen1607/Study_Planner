part of 'database_frame.dart';

extension _ProfileFrames on _DatabaseFrameState {
  List<Widget> profileBody() {
    final profile = UserProfileScope.maybeOf(context)?.profile,
        preferences = data.find('settings', 'preferences'),
        notifications = data.find('settings', 'notifications');
    switch (screen) {
      case D.pr01:
        return [
          Center(
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pale,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: const StudyMascot(size: 104),
            ),
          ),
          T(
            profile?.displayName ?? 'Tài khoản của bạn',
            size: 23,
            center: true,
            weight: FontWeight.w700,
          ),
          T(
            [
              profile?.studyRole,
              profile?.major,
            ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
            center: true,
            color: muted,
            size: 12,
          ),
          KCard([
            KRow([
              Expanded(
                child: T(
                  profile?.bio?.isNotEmpty == true
                      ? profile!.bio!
                      : 'Học hôm nay, để trở thành phiên bản tốt hơn ngày mai.',
                  size: 13,
                  color: muted,
                ),
              ),
              IconButton(
                tooltip: 'Chỉnh sửa hồ sơ',
                onPressed: () => go(D.pr02),
                icon: const Icon(Icons.edit_outlined, size: 19, color: dark),
              ),
            ], gap: 8),
          ], padding: 12),
          KRow([
            Expanded(
              child: profileStat(
                Icons.local_fire_department_outlined,
                '${data.streak}',
                'Ngày học liên tục',
              ),
            ),
            Expanded(
              child: profileStat(
                Icons.school_outlined,
                '${data.completedSessions.length}',
                'Buổi đã học',
              ),
            ),
            Expanded(
              child: profileStat(
                Icons.emoji_events_outlined,
                '${data.items('goals').where((g) => goalPercent(g) >= 100).length}',
                'Mục tiêu hoàn thành',
              ),
            ),
          ], gap: 9),
          heading(
            'Thành tựu gần đây',
            action: 'Xem tất cả ›',
            tap: () => go(D.an08),
          ),
          KCard([
            KRow([
              const Icon(
                Icons.workspace_premium_outlined,
                size: 36,
                color: green,
              ),
              Expanded(
                child: KColumn([
                  bold('Kiên trì mỗi ngày', 14),
                  T(
                    '${data.streak} ngày duy trì việc học',
                    size: 12,
                    color: muted,
                  ),
                ]),
              ),
              const Icon(Icons.chevron_right, color: muted),
            ], gap: 14),
          ], onTap: () => go(D.an07)),
          KCard([
            settingsRow(
              Icons.person_outline,
              'Hồ sơ cá nhân',
              tap: () => go(D.pr02),
            ),
            settingsRow(
              Icons.track_changes,
              'Mục tiêu học tập',
              tap: () => go(D.go01),
            ),
            settingsRow(
              Icons.settings_outlined,
              'Cài đặt ứng dụng',
              tap: () => go(D.pr03),
            ),
          ], padding: 5),
        ];
      case D.pr04:
        return [
          KCard([
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(
                  Icons.notifications_active_outlined,
                  color: green,
                ),
                title: const Text(
                  'Nhận thông báo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Lưu lựa chọn cho tài khoản của bạn',
                  style: TextStyle(fontSize: 12),
                ),
                value: notifications?.data['enabled'] != false,
                onChanged: data.busy
                    ? null
                    : (v) => data.setting('notifications', {'enabled': v}),
              ),
            ),
          ]),
          heading('Thông báo học tập'),
          KCard([
            for (final entry in {
              'studyReminders': (
                'Nhắc nhở học tập',
                'Nhắc theo kế hoạch đã đặt',
                Icons.notifications_outlined,
              ),
              'goalUpdates': (
                'Thông báo mục tiêu',
                'Theo dõi các bước tiến của bạn',
                Icons.track_changes,
              ),
              'deadlineReminders': (
                'Nhắc thời hạn',
                'Ghi nhớ những mốc quan trọng',
                Icons.calendar_month_outlined,
              ),
            }.entries)
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(entry.value.$3, color: muted, size: 22),
                  title: Text(
                    entry.value.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    entry.value.$2,
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: notifications?.data[entry.key] != false,
                  onChanged: data.busy
                      ? null
                      : (v) => data.setting('notifications', {entry.key: v}),
                ),
              ),
          ]),
          heading('Thông báo khác'),
          KCard([
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const StudyMascot(pose: 'sprout_pencil', size: 40),
                title: const Text(
                  'Gợi ý học tập',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Lựa chọn gợi ý phù hợp với bạn',
                  style: TextStyle(fontSize: 11),
                ),
                value: notifications?.data['aiSuggestions'] != false,
                onChanged: data.busy
                    ? null
                    : (v) =>
                          data.setting('notifications', {'aiSuggestions': v}),
              ),
            ),
          ]),
        ];
      case D.pr05:
        return [
          heading('Chế độ giao diện'),
          KRow([
            for (final item in [
              ('light', 'Sáng', Icons.light_mode_outlined),
              ('dark', 'Tối', Icons.dark_mode_outlined),
              ('system', 'Tự động', Icons.brightness_auto_outlined),
            ])
              Expanded(
                child: HoverAction(
                  onTap: data.busy
                      ? null
                      : () =>
                            data.setting('preferences', {'themeMode': item.$1}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          (preferences?.text('themeMode', 'system') ??
                                  'system') ==
                              item.$1
                          ? light
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            (preferences?.text('themeMode', 'system') ??
                                    'system') ==
                                item.$1
                            ? green
                            : StudyColors.border,
                      ),
                    ),
                    child: KColumn([
                      Icon(item.$3, size: 26, color: dark),
                      gap(8),
                      T(item.$2, center: true, size: 12),
                    ], center: true),
                  ),
                ),
              ),
          ], gap: 10),
          heading('Màu chủ đạo'),
          KCard([
            KRow([
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                  border: Border.all(color: pale, width: 4),
                ),
              ),
              const Expanded(child: T('Xanh lá', weight: FontWeight.w600)),
              const Icon(Icons.check_circle, color: green),
            ], gap: 12),
          ]),
          heading('Kiểu hiển thị'),
          KCard([
            const T('Cỡ chữ', size: 13, weight: FontWeight.w600),
            gap(12),
            segments(
              ['Nhỏ', 'Trung bình', 'Lớn'],
              [
                'small',
                'medium',
                'large',
              ].indexOf(preferences?.text('fontSize', 'medium') ?? 'medium'),
              (i) => data.setting('preferences', {
                'fontSize': ['small', 'medium', 'large'][i],
              }),
            ),
          ]),
          heading('Hình nền ứng dụng'),
          Container(
            height: 156,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: green),
              image: const DecorationImage(
                image: AssetImage('assets/images/study_planner_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.check_circle, color: green, size: 27),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: StudyMascot(pose: 'sprout_watering', size: 86),
          ),
        ];
      default:
        return [];
    }
  }
}
