import 'package:flutter/material.dart';
import 'package:study_planner_flutter/model/study_destination.dart';
import 'package:study_planner_flutter/view/common/study_theme.dart';
import 'package:study_planner_flutter/view/common/study_widgets.dart';

enum ScreenLayout {
  dashboard,
  list,
  timeline,
  calendar,
  form,
  detail,
  chart,
  settings,
  celebration,
  profile,
  search,
  badgeGrid,
}

class PrototypeItem {
  const PrototypeItem(
    this.title,
    this.subtitle,
    this.icon, {
    this.value,
    this.target,
    this.progress,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String? value;
  final StudyDestination? target;
  final int? progress;
}

class PrototypeStat {
  const PrototypeStat(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

class PrototypeScreen extends StatefulWidget {
  const PrototypeScreen({
    super.key,
    required this.destination,
    required this.title,
    required this.layout,
    required this.onNavigate,
    required this.onBack,
    this.subtitle,
    this.imageAsset,
    this.items = const [],
    this.stats = const [],
    this.primaryLabel,
    this.primaryTarget,
    this.showBack = true,
    this.showBottomBar = true,
  });
  final StudyDestination destination;
  final String title;
  final String? subtitle;
  final ScreenLayout layout;
  final String? imageAsset;
  final List<PrototypeItem> items;
  final List<PrototypeStat> stats;
  final String? primaryLabel;
  final StudyDestination? primaryTarget;
  final bool showBack;
  final bool showBottomBar;
  final DestinationCallback onNavigate;
  final VoidCallback onBack;

  @override
  State<PrototypeScreen> createState() => _PrototypeScreenState();
}

class _PrototypeScreenState extends State<PrototypeScreen> {
  int selectedTab = 0;
  int rating = 5;
  final Set<int> selectedItems = <int>{0, 1};
  final TextEditingController inputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/study_planner_bg.png', fit: BoxFit.cover),
        Scaffold(
          backgroundColor: Colors.white.withAlpha(32),
          bottomNavigationBar: widget.showBottomBar
              ? StudyBottomBar(
                  current: widget.destination,
                  onNavigate: widget.onNavigate,
                )
              : null,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.list(
                    children: [
                      _header(context),
                      if (widget.subtitle != null) ...[
                        Text(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: StudyColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ..._layout(context),
                      if (widget.primaryLabel != null) ...[
                        const SizedBox(height: 16),
                        PrimaryStudyButton(
                          label: widget.primaryLabel!,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            if (widget.primaryTarget != null) {
                              widget.onNavigate(widget.primaryTarget!);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) => SizedBox(
    height: 64,
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (widget.showBack)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54),
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    ),
  );

  List<Widget> _layout(BuildContext context) => switch (widget.layout) {
    ScreenLayout.dashboard => _dashboard(context),
    ScreenLayout.list => _list(context),
    ScreenLayout.timeline => _timeline(context),
    ScreenLayout.calendar => _calendar(context),
    ScreenLayout.form => _form(context),
    ScreenLayout.detail => _detail(context),
    ScreenLayout.chart => _chart(context),
    ScreenLayout.settings => _settings(context),
    ScreenLayout.celebration => _celebration(context),
    ScreenLayout.profile => _profile(context),
    ScreenLayout.search => _search(context),
    ScreenLayout.badgeGrid => _badgeGrid(context),
  };

  List<Widget> _dashboard(BuildContext context) => [
    _hero(context),
    if (widget.stats.isNotEmpty) ...[const SizedBox(height: 14), _stats()],
    const SizedBox(height: 18),
    const SectionHeading('Nội dung nổi bật'),
    const SizedBox(height: 9),
    ..._itemCards(),
  ];

  List<Widget> _list(BuildContext context) => [
    _tabs(),
    const SizedBox(height: 14),
    ..._itemCards(),
  ];

  List<Widget> _timeline(BuildContext context) => [
    _dayStrip(),
    const SizedBox(height: 16),
    for (int index = 0; index < widget.items.length; index++)
      _timelineItem(index, widget.items[index]),
  ];

  List<Widget> _calendar(BuildContext context) => [
    _tabs(labels: const ['Ngày', 'Tuần', 'Tháng']),
    const SizedBox(height: 14),
    StudyCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 36) / 7;
          return Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              for (int i = 1; i <= 35; i++)
                HoverAction(
                  onTap: () {},
                  radius: 14,
                  child: Container(
                    width: width,
                    height: width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == 24
                          ? StudyColors.green500
                          : (i % 5 == 0
                                ? StudyColors.green50
                                : Colors.transparent),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$i',
                      style: TextStyle(
                        color: i == 24 ? Colors.white : StudyColors.textPrimary,
                        fontWeight: i == 24 ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
    const SizedBox(height: 16),
    ..._itemCards(),
  ];

  List<Widget> _form(BuildContext context) => [
    ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: const LinearProgressIndicator(
        value: .58,
        minHeight: 8,
        backgroundColor: StudyColors.green100,
        color: StudyColors.green500,
      ),
    ),
    const SizedBox(height: 14),
    TextField(
      controller: inputController,
      minLines: 2,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: widget.items.isEmpty
            ? 'Thông tin'
            : widget.items.first.title,
        hintText: widget.items.isEmpty
            ? 'Nhập nội dung...'
            : widget.items.first.subtitle,
        prefixIcon: const Icon(Icons.edit_note_outlined),
      ),
    ),
    const SizedBox(height: 14),
    for (int i = widget.items.isEmpty ? 0 : 1; i < widget.items.length; i++)
      _selectableItem(i, widget.items[i]),
  ];

  List<Widget> _detail(BuildContext context) => [
    _hero(context),
    if (widget.stats.isNotEmpty) ...[const SizedBox(height: 14), _stats()],
    const SizedBox(height: 16),
    StudyCard(
      child: Column(
        children: [for (final item in widget.items) _detailRow(item)],
      ),
    ),
  ];

  List<Widget> _chart(BuildContext context) => [
    if (widget.stats.isNotEmpty) _stats(),
    const SizedBox(height: 16),
    StudyCard(
      child: SizedBox(
        height: 190,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final value in <double>[.28, .48, .38, .72, .9, .64, .44])
              Container(
                width: 24,
                height: 155 * value,
                decoration: BoxDecoration(
                  color: StudyColors.green500.withAlpha(210),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 16),
    ..._itemCards(),
  ];

  List<Widget> _settings(BuildContext context) => [
    for (int i = 0; i < widget.items.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: StudyCard(
          onTap: widget.items[i].target == null
              ? null
              : () => widget.onNavigate(widget.items[i].target!),
          child: Row(
            children: [
              _iconTile(widget.items[i].icon),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.items[i].title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.items[i].subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (widget.items[i].value == 'switch')
                Switch(
                  value: selectedItems.contains(i),
                  onChanged: (value) => setState(
                    () =>
                        value ? selectedItems.add(i) : selectedItems.remove(i),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
  ];

  List<Widget> _celebration(BuildContext context) => [
    const SizedBox(height: 10),
    Center(
      child: widget.imageAsset == null
          ? const Icon(
              Icons.celebration_outlined,
              size: 100,
              color: StudyColors.green500,
            )
          : Image.asset(widget.imageAsset!, height: 130, fit: BoxFit.contain),
    ),
    const SizedBox(height: 12),
    Text(
      widget.subtitle ?? 'Hoàn thành xuất sắc!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 14),
    if (widget.stats.isNotEmpty) _stats(),
    const SizedBox(height: 18),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= 5; i++)
          HoverAction(
            onTap: () => setState(() => rating = i),
            child: Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 42,
              color: const Color(0xFFFFB300),
            ),
          ),
      ],
    ),
    const SizedBox(height: 18),
    ..._itemCards(),
  ];

  List<Widget> _profile(BuildContext context) => [
    Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: StudyColors.green100,
            child: widget.imageAsset == null
                ? const Icon(
                    Icons.person,
                    size: 52,
                    color: StudyColors.green800,
                  )
                : ClipOval(
                    child: Image.asset(widget.imageAsset!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle ?? 'Minh Anh',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Sinh viên năm 2 · IT',
            style: TextStyle(color: StudyColors.textSecondary),
          ),
        ],
      ),
    ),
    if (widget.stats.isNotEmpty) ...[const SizedBox(height: 16), _stats()],
    const SizedBox(height: 16),
    ..._itemCards(),
  ];

  List<Widget> _search(BuildContext context) => [
    TextField(
      autofocus: true,
      controller: inputController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        final target = widget.primaryTarget;
        if (target != null) widget.onNavigate(target);
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Nhập môn AI, toán, lịch học...',
      ),
    ),
    const SizedBox(height: 18),
    const SectionHeading('Gợi ý nhanh'),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in [
          'Toán cao cấp',
          'Python',
          'Tiếng Anh',
          'Việc cần làm',
          'Ghi chú',
          'Tài liệu',
          'AI',
          'Video',
        ])
          ActionChip(
            label: Text(label),
            onPressed: () => inputController.text = label,
          ),
      ],
    ),
    const SizedBox(height: 18),
    const SectionHeading('Tìm kiếm gần đây'),
    const SizedBox(height: 8),
    ..._itemCards(),
  ];

  List<Widget> _badgeGrid(BuildContext context) => [
    _tabs(labels: const ['Tất cả', 'Đã đạt', 'Chưa đạt']),
    const SizedBox(height: 14),
    GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return StudyCard(
          onTap: item.target == null
              ? null
              : () => widget.onNavigate(item.target!),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: StudyColors.green800, size: 39),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    ),
  ];

  Widget _hero(BuildContext context) => StudyCard(
    child: Row(
      children: [
        if (widget.imageAsset != null)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Image.asset(
              widget.imageAsset!,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _iconTile(
              widget.items.isEmpty
                  ? Icons.auto_awesome_outlined
                  : widget.items.first.icon,
              size: 56,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subtitle ?? widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Học thông minh hơn mỗi ngày',
                style: TextStyle(
                  fontSize: 12,
                  color: StudyColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.stats.isNotEmpty)
          ProgressRing(
            int.tryParse(widget.stats.first.value.replaceAll('%', '')) ?? 60,
          ),
      ],
    ),
  );

  Widget _stats() => Row(
    children: [
      for (int i = 0; i < widget.stats.length; i++) ...[
        if (i > 0) const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: StudyColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  widget.stats[i].icon,
                  color: StudyColors.green800,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.stats[i].value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.stats[i].label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: StudyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );

  Iterable<Widget> _itemCards() sync* {
    for (final item in widget.items) {
      yield Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: StudyCard(
          onTap: item.target == null
              ? null
              : () => widget.onNavigate(item.target!),
          child: Row(
            children: [
              _iconTile(item.icon),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StudyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.progress != null)
                ProgressRing(item.progress!, size: 48)
              else if (item.value != null)
                Text(
                  item.value!,
                  style: const TextStyle(
                    color: StudyColors.green800,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (item.target != null)
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
    }
  }

  Widget _selectableItem(int index, PrototypeItem item) {
    final selected = selectedItems.contains(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StudyCard(
        onTap: () => setState(
          () =>
              selected ? selectedItems.remove(index) : selectedItems.add(index),
        ),
        child: Row(
          children: [
            _iconTile(item.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: StudyColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? StudyColors.green500
                  : StudyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs({
    List<String> labels = const ['Tất cả', 'Đang thực hiện', 'Hoàn thành'],
  }) => Row(
    children: [
      for (int i = 0; i < labels.length; i++)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(labels[i], textAlign: TextAlign.center),
              ),
              selected: selectedTab == i,
              onSelected: (_) => setState(() => selectedTab = i),
              selectedColor: StudyColors.green500,
              labelStyle: TextStyle(
                color: selectedTab == i
                    ? Colors.white
                    : StudyColors.textSecondary,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _dayStrip() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (int i = 0; i < 7; i++)
        Container(
          width: 43,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: i == 2 ? StudyColors.green500 : Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i],
                style: TextStyle(
                  fontSize: 11,
                  color: i == 2 ? Colors.white : StudyColors.textSecondary,
                ),
              ),
              Text(
                '${22 + i}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: i == 2 ? Colors.white : StudyColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _timelineItem(int index, PrototypeItem item) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 36,
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: StudyColors.green500,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (index < widget.items.length - 1)
              Container(width: 2, height: 62, color: StudyColors.green100),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StudyCard(
            onTap: item.target == null
                ? null
                : () => widget.onNavigate(item.target!),
            child: Row(
              children: [
                _iconTile(item.icon),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: StudyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _detailRow(PrototypeItem item) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(item.icon, color: StudyColors.green800, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(color: StudyColors.textSecondary),
          ),
        ),
        Text(
          item.value ?? item.subtitle,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _iconTile(IconData icon, {double size = 44}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: StudyColors.green100,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: StudyColors.green800, size: size * .52),
  );
}
