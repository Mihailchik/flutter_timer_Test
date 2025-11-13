class TimerItem {
  final String name;
  final int duration; // in seconds
  final bool isPause; // true for pause, false for exercise

  TimerItem({required this.name, required this.duration, this.isPause = false});

  TimerItem copyWith({String? name, int? duration, bool? isPause}) {
    return TimerItem(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isPause: isPause ?? this.isPause,
    );
  }

  @override
  String toString() {
    return 'TimerItem(name: $name, duration: $duration, isPause: $isPause)';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration': duration,
        'isPause': isPause,
      };

  static TimerItem fromJson(Map<String, dynamic> json) {
    return TimerItem(
      name: json['name'] as String,
      duration: json['duration'] as int,
      isPause: (json['isPause'] as bool?) ?? false,
    );
  }
}

class TimerBlock {
  final String name;
  final List<TimerItem> items; // List of timers within the block
  final int repeats; // Number of repeats for this block

  TimerBlock({required this.name, required this.items, this.repeats = 1});

  TimerBlock copyWith({String? name, List<TimerItem>? items, int? repeats}) {
    return TimerBlock(
      name: name ?? this.name,
      items: items ?? this.items,
      repeats: repeats ?? this.repeats,
    );
  }

  // Get total duration including all items and repeats
  int get totalDuration {
    final blockDuration = items.fold(0, (sum, item) => sum + item.duration);
    return blockDuration * repeats;
  }

  @override
  String toString() {
    return 'TimerBlock(name: $name, items: $items, repeats: $repeats)';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'repeats': repeats,
        'items': items.map((e) => e.toJson()).toList(),
      };

  static TimerBlock fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return TimerBlock(
      name: json['name'] as String,
      repeats: (json['repeats'] as int?) ?? 1,
      items: itemsJson.map((e) => TimerItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class TimerSequence {
  final List<TimerBlock> blocks;

  TimerSequence({required this.blocks});

  TimerSequence copyWith({List<TimerBlock>? blocks}) {
    return TimerSequence(blocks: blocks ?? this.blocks);
  }

  // Get total duration including all repeats
  int get totalDuration {
    return blocks.fold(0, (sum, block) => sum + block.totalDuration);
  }

  @override
  String toString() {
    return 'TimerSequence(blocks: $blocks)';
  }

  Map<String, dynamic> toJson() => {
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };

  static TimerSequence fromJson(Map<String, dynamic> json) {
    final blocksJson = json['blocks'] as List<dynamic>? ?? const [];
    return TimerSequence(
      blocks: blocksJson.map((e) => TimerBlock.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
