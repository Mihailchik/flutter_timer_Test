import 'package:flutter/material.dart';
import 'timer_model.dart';
import 'timer_block_widget.dart';

class TimerSetupWidget extends StatefulWidget {
  final TimerSequence sequence;
  final Function(TimerSequence) onSequenceUpdate;

  const TimerSetupWidget({
    super.key,
    required this.sequence,
    required this.onSequenceUpdate,
  });

  @override
  State<TimerSetupWidget> createState() => _TimerSetupWidgetState();
}

class _TimerSetupWidgetState extends State<TimerSetupWidget> {
  late TimerSequence _sequence;

  @override
  void initState() {
    super.initState();
    _sequence = widget.sequence;
  }

  void _updateSequence() {
    widget.onSequenceUpdate(_sequence);
  }

  void _addBlock() {
    setState(() {
      _sequence = _sequence.copyWith(
        blocks: [
          ..._sequence.blocks,
          TimerBlock(
            name: 'Блок ${_sequence.blocks.length + 1}',
            items: [
              TimerItem(name: 'Упражнение', duration: 30, isPause: false),
              TimerItem(name: 'Пауза', duration: 15, isPause: true),
            ],
            repeats: 1,
          ),
        ],
      );
    });
    _updateSequence();
  }

  void _deleteBlock(int index) {
    if (_sequence.blocks.length <= 1) {
      return;
    }

    setState(() {
      final newBlocks = List<TimerBlock>.from(_sequence.blocks);
      newBlocks.removeAt(index);
      _sequence = _sequence.copyWith(blocks: newBlocks);
    });
    _updateSequence();
  }

  void _updateBlock(int index, TimerBlock updatedBlock) {
    setState(() {
      final newBlocks = List<TimerBlock>.from(_sequence.blocks);
      newBlocks[index] = updatedBlock;
      _sequence = _sequence.copyWith(blocks: newBlocks);
    });
    _updateSequence();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 360;
    final isVeryNarrow = size.width < 320;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Настройка таймера',
                style: TextStyle(
                  fontSize: isNarrow ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            isVeryNarrow
                ? IconButton(
                    onPressed: _addBlock,
                    icon: const Icon(Icons.timer),
                    tooltip: 'Добавить блок',
                  )
                : ElevatedButton.icon(
                    onPressed: _addBlock,
                    icon: Icon(isNarrow ? Icons.timer : Icons.add, size: 18),
                    label: Text(
                      isNarrow ? 'Добавить' : 'Добавить блок',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 10 : 12,
                        vertical: isNarrow ? 6 : 8,
                      ),
                    ),
                  ),
          ],
        ),
        SizedBox(height: isNarrow ? 12 : 20),
        const Text(
          'Блоки таймера:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: isNarrow ? 8 : 10),
        if (_sequence.blocks.isEmpty)
          const Center(child: Text('Нет блоков. Добавьте блок для начала.'))
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(_sequence.blocks.length, (index) {
                    return TimerBlockWidget(
                      block: _sequence.blocks[index],
                      onDelete: () => _deleteBlock(index),
                      onUpdate: (updatedBlock) =>
                          _updateBlock(index, updatedBlock),
                      showDeleteButton: _sequence.blocks.length >
                          1, // Hide delete button for last block
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
