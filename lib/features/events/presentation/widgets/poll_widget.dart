import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/poll_model.dart';

class PollWidget extends StatefulWidget {
  final PollModel poll;
  final Function(String, String) onVote;
  final bool canVote;

  const PollWidget({
    super.key,
    required this.poll,
    required this.onVote,
    this.canVote = true,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.poll.options.fold(
      0,
      (sum, option) => sum + option.voterIds.length,
    );
    final hasVoted = widget.poll.options.any(
      (option) => option.voterIds.contains('current_user_id'),
    );
    final isExpired = widget.poll.expiresAt.isBefore(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll Header
            Row(
              children: [
                const Icon(Icons.poll, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.poll.question,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Closed',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Poll Options
            ...widget.poll.options.map(
              (option) => _buildOptionItem(
                option,
                totalVotes,
                hasVoted || !widget.canVote || isExpired,
              ),
            ),
            const SizedBox(height: 12),
            // Poll Footer
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
                    style: AppTextStyles.caption,
                  ),
                ),
                if (isExpired)
                  Text(
                    'Ended ${_formatDate(widget.poll.expiresAt)}',
                    style: AppTextStyles.caption,
                  )
                else
                  Text(
                    'Ends ${_formatDate(widget.poll.expiresAt)}',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
            // Vote Button
            if (widget.canVote && !hasVoted && !isExpired) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOption != null ? _submitVote : null,
                  child: const Text('Submit Vote'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(PollOption option, int totalVotes, bool showResults) {
    final percentage = totalVotes > 0
        ? (option.voterIds.length / totalVotes) * 100
        : 0;
    final isSelected = _selectedOption == option.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: showResults ? null : () => _selectOption(option.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.primary.withValues()
                : Colors.transparent,
          ),
          child: Row(
            children: [
              if (!showResults) ...[
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.text, style: AppTextStyles.bodyMedium),
                    if (showResults) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${option.voterIds.length} votes (${percentage.toStringAsFixed(1)}%)',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectOption(String optionId) {
    setState(() {
      _selectedOption = optionId;
    });
  }

  void _submitVote() {
    if (_selectedOption != null) {
      widget.onVote(widget.poll.id, _selectedOption!);
      setState(() {
        _selectedOption = null;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} days';
    } else if (difference.inDays < 30) {
      return 'in ${(difference.inDays / 7).floor()} weeks';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }
}
