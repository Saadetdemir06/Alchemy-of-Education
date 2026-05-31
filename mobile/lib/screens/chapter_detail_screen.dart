import 'package:flutter/material.dart';

import '../models/adventure_models.dart';
import '../models/quest_theme.dart';
import '../services/user_profile_service.dart';

class ChapterDetailScreen extends StatefulWidget {
  final AdventureChapter chapter;
  final AdventureProgress progress;
  final QuestTheme mode;

  final String field;
  final String topic;
  final String level;
  final String modeTitle;
  final String mapTitle;

  final VoidCallback onNewAdventureRequested;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.progress,
    required this.mode,
    required this.field,
    required this.topic,
    required this.level,
    required this.modeTitle,
    required this.mapTitle,
    required this.onNewAdventureRequested,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  final UserProfileService profileService = UserProfileService();

  int? selectedAnswer;

  int currentFinalQuestionIndex = 0;
  int finalCorrectCount = 0;
  int finalWrongCount = 0;
  int normalWrongCount = 0;

  bool showHint = false;
  bool showIdea = false;
  bool answered = false;
  bool quizFinished = false;
  bool rewardSaved = false;
  bool taskFailed = false;
  bool isProcessing = false;

  bool coinAnimVisible = false;
  int lastCoinChange = 0;

  int taskGold = 0;

  String feedbackText = '';
  String ideaText = '';

  late AdventureProgress currentProgress;

  bool get isBoss => widget.chapter.isBoss;

  QuizQuestion? get currentFinalQuestion {
    if (!isBoss) return null;
    if (widget.chapter.finalQuiz.isEmpty) return null;
    if (currentFinalQuestionIndex >= widget.chapter.finalQuiz.length) {
      return null;
    }

    return widget.chapter.finalQuiz[currentFinalQuestionIndex];
  }

  @override
  void initState() {
    super.initState();

    currentProgress = widget.progress;
    taskGold = 0;

    final alreadyCompleted =
        widget.progress.completedChapters.contains(widget.chapter.id);

    if (alreadyCompleted) {
      answered = true;
      quizFinished = true;
      rewardSaved = true;
      feedbackText = 'Bu görev daha önce tamamlandı.';
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A211B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  void showCoinAnimation(int amount) {
    setState(() {
      lastCoinChange = amount;
      coinAnimVisible = true;
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      setState(() {
        coinAnimVisible = false;
      });
    });
  }

  Future<bool> spendFiveGoldIfPossible() async {
    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 5) {
      showCoinAnimation(0);
      return false;
    }

    final spent = await profileService.spendProfileGold(5);

    if (!spent) {
      showCoinAnimation(0);
      return false;
    }

    setState(() {
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 5 ? currentProgress.gold - 5 : 0,
      );
    });

    showCoinAnimation(-5);
    return true;
  }

  String buildIdeaText() {
    if (isBoss) {
      return 'Bu final sorusunda önce sorunun senden tanım mı, amaç mı, kullanım mı istediğini ayır. Sonra seçenekleri tek tek ele.';
    }

    return 'Bu soruda bölümdeki ana açıklamaya odaklan. Cevabı ezberlemeye değil, kavramın ne işe yaradığını anlamaya çalış.';
  }

  Future<void> buyHint() async {
    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 5) {
      showMessage('İpucu almak için en az 5 altının olmalı.');
      return;
    }

    final spent = await profileService.spendProfileGold(5);

    if (!spent) {
      showMessage('Yeterli altının yok.');
      return;
    }

    setState(() {
      showHint = true;
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 5 ? currentProgress.gold - 5 : 0,
      );
    });

    showCoinAnimation(-5);
    showMessage('5 altın harcandı. İpucu açıldı.');
  }

  Future<void> buyIdea() async {
    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 10) {
      showMessage('Fikir almak için en az 10 altının olmalı.');
      return;
    }

    final spent = await profileService.spendProfileGold(10);

    if (!spent) {
      showMessage('Yeterli altının yok.');
      return;
    }

    setState(() {
      showIdea = true;
      ideaText = buildIdeaText();
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 10 ? currentProgress.gold - 10 : 0,
      );
    });

    showCoinAnimation(-10);
    showMessage('10 altın harcandı. Fikir açıldı.');
  }

  Future<void> answerNormalQuestion(int index) async {
    if (answered || isProcessing || rewardSaved || taskFailed) return;

    final isCorrect = index == widget.chapter.correctIndex;
    final isFirstChapter = widget.chapter.id == 1;

    setState(() {
      selectedAnswer = index;
      answered = true;
      isProcessing = true;
    });

    if (isCorrect) {
      setState(() {
        taskGold = 15;
        quizFinished = true;
        isProcessing = false;
        feedbackText =
            'Doğru cevap! Görevi tamamlayınca 15 altın kazanacaksın.';
      });

      showCoinAnimation(15);
      return;
    }

    normalWrongCount++;

    if (isFirstChapter && normalWrongCount == 1) {
      setState(() {
        quizFinished = false;
        isProcessing = false;
        feedbackText = 'Yanlış cevap. Tekrar dene.';
      });

      return;
    }

    final spentGold = await spendFiveGoldIfPossible();

    setState(() {
      isProcessing = false;
      taskFailed = true;
      quizFinished = false;

      if (spentGold) {
        feedbackText =
            'Görev tamamlanamadı. Bu görev kaydedilmedi. 5 altın kaybettin. Yeni görev üretebilirsin.';
      } else {
        feedbackText =
            'Görev tamamlanamadı. Bu görev kaydedilmedi. Altının olmadığı için altın düşmedi. Yeni görev üretebilirsin.';
      }
    });
  }

  Future<void> retryNormalQuestion() async {
    if (widget.chapter.id != 1) return;
    if (normalWrongCount != 1 || taskFailed || quizFinished) return;

    setState(() {
      selectedAnswer = null;
      answered = false;
      feedbackText = 'Tekrar dene. Doğru cevabı bulmadan görev tamamlanmaz.';
    });
  }

  Future<void> answerFinalQuestion(int index) async {
    if (isProcessing || currentFinalQuestion == null || quizFinished) return;
    if (selectedAnswer != null) return;

    final question = currentFinalQuestion!;
    final isCorrect = index == question.correctIndex;
    final isLastQuestion =
        currentFinalQuestionIndex >= widget.chapter.finalQuiz.length - 1;

    setState(() {
      selectedAnswer = index;
      isProcessing = true;
    });

    if (isCorrect) {
      setState(() {
        finalCorrectCount++;
        taskGold += 15;
        feedbackText = 'Doğru cevap! +15 altın.';
      });

      showCoinAnimation(15);

      Future.delayed(const Duration(milliseconds: 850), () {
        if (!mounted) return;

        if (isLastQuestion) {
          setState(() {
            quizFinished = true;
            selectedAnswer = null;
            isProcessing = false;
            feedbackText =
                'Final mini quiz bitti. Doğru: $finalCorrectCount / Yanlış: $finalWrongCount. Görevi tamamlayabilirsin.';
          });
        } else {
          setState(() {
            currentFinalQuestionIndex++;
            selectedAnswer = null;
            isProcessing = false;
            feedbackText = '';
          });
        }
      });

      return;
    }

    finalWrongCount++;

    final spentGold = await spendFiveGoldIfPossible();

    if (!spentGold) {
      setState(() {
        isProcessing = false;
        taskFailed = true;
        quizFinished = false;
        feedbackText =
            'Final görev başarısız oldu. Altının olmadığı için bu soruda devam edemedin. Yeni görev üretebilirsin.';
      });

      return;
    }

    setState(() {
      isProcessing = false;
      feedbackText =
          'Yanlış cevap. 5 altın kaybettin. Aynı soruyu tekrar dene.';
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      setState(() {
        selectedAnswer = null;
        feedbackText = 'Aynı soruyu tekrar çöz. Doğru cevap vermeden ilerleyemezsin.';
      });
    });
  }

  Future<void> completeTask() async {
    if (taskFailed) {
      showMessage('Başarısız görev kaydedilemez.');
      return;
    }

    if (!quizFinished || isProcessing || rewardSaved) return;

    setState(() {
      isProcessing = true;
    });

    final updatedCompleted = Set<int>.from(currentProgress.completedChapters)
      ..add(widget.chapter.id);

    final nextUnlock = widget.chapter.id >= currentProgress.unlockedChapter
        ? widget.chapter.id + 1
        : currentProgress.unlockedChapter;

    try {
      await profileService.addReward(
        gold: taskGold,
        xp: 0,
      );

      if (isBoss) {
        await profileService.addBadge();

        await profileService.saveAdventureHistory(
          field: widget.field,
          topic: widget.topic,
          level: widget.level,
          mode: widget.modeTitle,
          mapTitle: widget.mapTitle,
          earnedGold: taskGold,
          earnedXp: 0,
        );
      }

      setState(() {
        rewardSaved = true;
        isProcessing = false;

        currentProgress = currentProgress.copyWith(
          gold: currentProgress.gold + taskGold,
          unlockedChapter: nextUnlock > 6 ? 6 : nextUnlock,
          completedChapters: updatedCompleted,
        );

        feedbackText = isBoss
            ? 'Final boss tamamlandı! $taskGold altın ve 1 rozet kazandın.'
            : 'Görev tamamlandı! $taskGold altın kazandın.';
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      showMessage('Ödül kaydedilemedi. İnternet bağlantını kontrol et.');
    }
  }

  void finishChapter() {
    Navigator.pop(context, currentProgress);
  }

  void requestNewAdventure() {
    widget.onNewAdventureRequested();
  }

  Color normalOptionBorderColor(int index) {
    if (selectedAnswer == null) {
      return Colors.white.withOpacity(0.14);
    }

    if (selectedAnswer == index) {
      if (index == widget.chapter.correctIndex) {
        return const Color(0xFF60D394);
      }

      return const Color(0xFFFF4F6D);
    }

    return Colors.white.withOpacity(0.14);
  }

  Color finalOptionBorderColor(int index) {
    final question = currentFinalQuestion;

    if (question == null || selectedAnswer == null) {
      return Colors.white.withOpacity(0.14);
    }

    if (selectedAnswer == index) {
      if (index == question.correctIndex) {
        return const Color(0xFF60D394);
      }

      return const Color(0xFFFF4F6D);
    }

    return Colors.white.withOpacity(0.14);
  }

  @override
  Widget build(BuildContext context) {
    final finalQuestion = currentFinalQuestion;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.mode.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.34),
                        Colors.black.withOpacity(0.76),
                        Colors.black.withOpacity(0.97),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
                  children: [
                    _TopBar(
                      title: widget.chapter.title,
                      subtitle: widget.chapter.subtitle,
                      onBack: finishChapter,
                    ),
                    const SizedBox(height: 14),
                    _TaskRewardBar(
                      rewardGold: taskGold,
                      profileGold: currentProgress.gold,
                      isBoss: isBoss,
                      finalCorrect: finalCorrectCount,
                      finalTotal: widget.chapter.finalQuiz.length,
                    ),
                    const SizedBox(height: 16),
                    _TextPanel(
                      title: 'Hikâye',
                      text: widget.chapter.story,
                      mode: widget.mode,
                    ),
                    const SizedBox(height: 12),
                    _TextPanel(
                      title: 'Konu Anlatımı',
                      text: widget.chapter.explanation,
                      mode: widget.mode,
                    ),
                    const SizedBox(height: 12),
                    _HelpPanel(
                      showHint: showHint,
                      showIdea: showIdea,
                      hint: widget.chapter.memoryTip,
                      idea: ideaText,
                      onBuyHint: buyHint,
                      onBuyIdea: buyIdea,
                    ),
                    const SizedBox(height: 16),
                    if (!isBoss)
                      _NormalQuizPanel(
                        chapter: widget.chapter,
                        selectedAnswer: selectedAnswer,
                        answered: answered,
                        borderColorBuilder: normalOptionBorderColor,
                        onAnswer: answerNormalQuestion,
                      )
                    else
                      _FinalQuizPanel(
                        question: finalQuestion,
                        questionIndex: currentFinalQuestionIndex,
                        totalQuestions: widget.chapter.finalQuiz.length,
                        selectedAnswer: selectedAnswer,
                        quizFinished: quizFinished,
                        borderColorBuilder: finalOptionBorderColor,
                        onAnswer: answerFinalQuestion,
                      ),
                    if (feedbackText.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _FeedbackPanel(
                        text: feedbackText,
                        success: !feedbackText.contains('Yanlış') &&
                            !feedbackText.contains('başarısız') &&
                            !feedbackText.contains('tamamlanamadı') &&
                            !feedbackText.contains('kaydedilmedi'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (!isBoss &&
                        widget.chapter.id == 1 &&
                        normalWrongCount == 1 &&
                        !taskFailed &&
                        !quizFinished)
                      _RetryButton(
                        mode: widget.mode,
                        onTap: retryNormalQuestion,
                      ),
                    if (taskFailed) ...[
                      const SizedBox(height: 12),
                      _NewAdventureButton(
                        mode: widget.mode,
                        onTap: requestNewAdventure,
                      ),
                    ],
                    if (!taskFailed && quizFinished)
                      _CompleteTaskButton(
                        enabled: !rewardSaved && !isProcessing,
                        rewardSaved: rewardSaved,
                        mode: widget.mode,
                        onTap: completeTask,
                      ),
                    if (rewardSaved) ...[
                      const SizedBox(height: 12),
                      _FinishButton(
                        mode: widget.mode,
                        onTap: finishChapter,
                      ),
                    ],
                  ],
                ),
              ),
              if (coinAnimVisible)
                Positioned(
                  top: 94,
                  right: 34,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 850),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -34 * value),
                        child: Opacity(
                          opacity: 1 - value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: lastCoinChange > 0
                                  ? const Color(0xFF163B2C)
                                  : lastCoinChange < 0
                                      ? const Color(0xFF3B161D)
                                      : const Color(0xFF2A211B),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: lastCoinChange > 0
                                    ? const Color(0xFF60D394)
                                    : lastCoinChange < 0
                                        ? const Color(0xFFFF4F6D)
                                        : const Color(0xFFFFD58A),
                              ),
                            ),
                            child: Text(
                              lastCoinChange == 0
                                  ? 'Altın düşmedi'
                                  : '${lastCoinChange > 0 ? '+' : ''}$lastCoinChange 🪙',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.38),
              border: Border.all(
                color: const Color(0xFFFFD58A).withOpacity(0.45),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFE7B2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Görev Bölümü',
                style: TextStyle(
                  color: Color(0xFFFFE7B2),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskRewardBar extends StatelessWidget {
  final int rewardGold;
  final int profileGold;
  final bool isBoss;
  final int finalCorrect;
  final int finalTotal;

  const _TaskRewardBar({
    required this.rewardGold,
    required this.profileGold,
    required this.isBoss,
    required this.finalCorrect,
    required this.finalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniReward(label: 'Ödül', value: '$rewardGold', icon: '🪙'),
        const SizedBox(width: 8),
        _MiniReward(label: 'Altın', value: '$profileGold', icon: '💰'),
        if (isBoss) ...[
          const SizedBox(width: 8),
          _MiniReward(
            label: 'Quiz',
            value: '$finalCorrect/$finalTotal',
            icon: '🏆',
          ),
        ],
      ],
    );
  }
}

class _MiniReward extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _MiniReward({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF241A18).withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFD58A).withOpacity(0.20),
          ),
        ),
        child: Row(
          children: [
            Text(icon),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 9.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFE7B2),
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPanel extends StatelessWidget {
  final String title;
  final String text;
  final QuestTheme mode;

  const _TextPanel({
    required this.title,
    required this.text,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF201817).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 13,
              height: 1.48,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpPanel extends StatelessWidget {
  final bool showHint;
  final bool showIdea;
  final String hint;
  final String idea;
  final VoidCallback onBuyHint;
  final VoidCallback onBuyIdea;

  const _HelpPanel({
    required this.showHint,
    required this.showIdea,
    required this.hint,
    required this.idea,
    required this.onBuyHint,
    required this.onBuyIdea,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yardım Sandığı',
            style: TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HelpButton(
                  title: 'İpucu',
                  cost: '5 altın',
                  onTap: onBuyHint,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HelpButton(
                  title: 'Fikir ver',
                  cost: '10 altın',
                  onTap: onBuyIdea,
                ),
              ),
            ],
          ),
          if (showHint) ...[
            const SizedBox(height: 12),
            _UnlockedHelpText(title: 'İpucu', text: hint),
          ],
          if (showIdea) ...[
            const SizedBox(height: 12),
            _UnlockedHelpText(title: 'Fikir', text: idea),
          ],
        ],
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final String title;
  final String cost;
  final VoidCallback onTap;

  const _HelpButton({
    required this.title,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD58A),
          foregroundColor: const Color(0xFF231309),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          '$title • $cost',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.6,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _UnlockedHelpText extends StatelessWidget {
  final String title;
  final String text;

  const _UnlockedHelpText({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12.2,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NormalQuizPanel extends StatelessWidget {
  final AdventureChapter chapter;
  final int? selectedAnswer;
  final bool answered;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index) onAnswer;

  const _NormalQuizPanel({
    required this.chapter,
    required this.selectedAnswer,
    required this.answered,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return _QuizBox(
      title: 'Kontrol Sorusu',
      question: chapter.question,
      options: chapter.options,
      borderColorBuilder: borderColorBuilder,
      onAnswer: answered ? null : onAnswer,
    );
  }
}

class _FinalQuizPanel extends StatelessWidget {
  final QuizQuestion? question;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool quizFinished;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index) onAnswer;

  const _FinalQuizPanel({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.quizFinished,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF201817).withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD58A).withOpacity(0.24),
          ),
        ),
        child: const Column(
          children: [
            Text(
              'Mini Quiz Tamamlandı',
              style: TextStyle(
                color: Color(0xFFFFE7B2),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Artık final görevini tamamlayıp ödülünü profile ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (question == null) {
      return const SizedBox.shrink();
    }

    return _QuizBox(
      title: 'Final Mini Quiz • ${questionIndex + 1}/$totalQuestions',
      question: question!.question,
      options: question!.options,
      borderColorBuilder: borderColorBuilder,
      onAnswer: selectedAnswer == null ? onAnswer : null,
    );
  }
}

class _QuizBox extends StatelessWidget {
  final String title;
  final String question;
  final List<String> options;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index)? onAnswer;

  const _QuizBox({
    required this.title,
    required this.question,
    required this.options,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF201817).withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAnswer == null ? null : () => onAnswer!(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColorBuilder(index),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          color: Color(0xFFFFD58A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final String text;
  final bool success;

  const _FeedbackPanel({
    required this.text,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: success
            ? const Color(0xFF163B2C).withOpacity(0.92)
            : const Color(0xFF3B161D).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: success ? const Color(0xFF60D394) : const Color(0xFFFF4F6D),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _RetryButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.75),
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1514),
          foregroundColor: const Color(0xFFFFE7B2),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Tekrar Dene',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NewAdventureButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _NewAdventureButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF4F6D),
            mode.glowColor,
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Yeni Görev Üret',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CompleteTaskButton extends StatelessWidget {
  final bool enabled;
  final bool rewardSaved;
  final QuestTheme mode;
  final VoidCallback onTap;

  const _CompleteTaskButton({
    required this.enabled,
    required this.rewardSaved,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              mode.glowColor,
              const Color(0xFFFFD58A),
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF231309),
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            rewardSaved ? 'Ödül Kaydedildi' : 'Görevi Tamamla',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _FinishButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.8),
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1514),
          foregroundColor: const Color(0xFFFFE7B2),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Haritaya Dön',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}