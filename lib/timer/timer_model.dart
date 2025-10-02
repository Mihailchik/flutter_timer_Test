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
}
