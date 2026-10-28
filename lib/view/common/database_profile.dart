part of 'database_frame.dart';

extension _ProfileFrames on _DatabaseFrameState {
  List<Widget> profileBody() {
    final profile = UserProfileScope.maybeOf(context)?.profile;
    final preferences = data.find('settings', 'preferences');
    final notifications = data.find('settings', 'notifications');
    switch (screen) {
      case D.pr01:
        return [
          Center(child: avatar()),
          T(
            profile?.displayName ?? 'Tài khoản của bạn',
            size: 24,
            center: true,
            weight: FontWeight.w700,
          ),
          T(profile?.email ?? '', center: true, color: muted),
          if (profile?.bio != null) T(profile!.bio!, center: true),
          plannerStats([
            (Icons.local_fire_department, '${data.streak}', 'Chuỗi ngày'),
            (Icons.school, '${data.completedSessions.length}', 'Buổi đã học'),
            (
              Icons.flag,
              '${data.items('goals').where((g) => goalPercent(g) >= 100).length}',
              'Mục tiêu xong',
            ),
          ]),
          for (final a in [
            ('Chỉnh sửa hồ sơ', D.pr02, Icons.person_outline),
            ('Mục tiêu học tập', D.go01, Icons.track_changes),
            ('Huy hiệu thành tích', D.an08, Icons.military_tech_outlined),
            ('Cài đặt ứng dụng', D.pr03, Icons.settings_outlined),
          ])
            row(a.$1, '', a.$3, () => go(a.$2)),
        ];
      case D.pr04:
        return [
          const T(
            'Tùy chọn thông báo được lưu riêng theo tài khoản. Gửi thông báo đẩy cần triển khai thêm dịch vụ nhắc lịch.',
            color: muted,
          ),
          for (final entry in {
            'enabled': 'Bật thông báo',
            'studyReminders': 'Nhắc học tập',
            'goalUpdates': 'Cập nhật mục tiêu',
            'deadlineReminders': 'Nhắc thời hạn',
            'aiSuggestions': 'Gợi ý AI',
          }.entries)
            KCard([
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.notifications_outlined,
                    color: green,
                  ),
                  title: Text(entry.value),
                  value: notifications?.data[entry.key] != false,
                  onChanged: data.busy
                      ? null
                      : (v) => data.setting('notifications', {entry.key: v}),
                ),
              ),
            ]),
        ];
      case D.pr05:
        return [
          heading('Chế độ giao diện'),
          Wrap(
            spacing: 8,
            children: [
              for (final e in {
                'light': 'Sáng',
                'dark': 'Tối',
                'system': 'Tự động',
              }.entries)
                ChoiceChip(
                  avatar: Icon(
                    e.key == 'dark'
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  label: Text(e.value),
                  selected:
                      (preferences?.text('themeMode', 'system') ?? 'system') ==
                      e.key,
                  onSelected: data.busy
                      ? null
                      : (_) =>
                            data.setting('preferences', {'themeMode': e.key}),
                ),
            ],
          ),
          heading('Cỡ chữ'),
          Wrap(
            spacing: 8,
            children: [
              for (final e in {
                'small': 'Nhỏ',
                'medium': 'Vừa',
                'large': 'Lớn',
              }.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected:
                      (preferences?.text('fontSize', 'medium') ?? 'medium') ==
                      e.key,
                  onSelected: data.busy
                      ? null
                      : (_) => data.setting('preferences', {'fontSize': e.key}),
                ),
            ],
          ),
          const T(
            'Phông chữ, nền và màu chủ đạo tiếp tục dùng bộ giao diện Study Planner.',
            color: muted,
          ),
        ];
      default:
        return [];
    }
  }
}
