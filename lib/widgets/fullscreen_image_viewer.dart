import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _goToPage(int index) {
    if (index < 0 || index >= widget.imageUrls.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _showPrevious() {
    if (_currentIndex > 0) {
      _goToPage(_currentIndex - 1);
    }
  }

  void _showNext() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _goToPage(_currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.of(context).pop(),
                    child: InteractiveViewer(
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {},
                          child: Image.network(
                            client.fileBase.from(widget.imageUrls[index]),
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopButton(Icons.share, 'Share'),
                  const SizedBox(width: 8),
                  _buildTopButton(Icons.info_outline, 'Info'),
                  const SizedBox(width: 8),
                  _buildTopButton(Icons.more_vert, 'More'),
                ],
              ),
            ),
            if (widget.imageUrls.length > 1) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    iconSize: 40,
                    color: Colors.white70,
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _showPrevious,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    iconSize: 40,
                    color: Colors.white70,
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _showNext,
                  ),
                ),
              ),
            ],
            if (widget.imageUrls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: SizedBox(
                  height: 96,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemCount = widget.imageUrls.length;
                      final contentWidth =
                          itemCount * 80 + (itemCount - 1) * 12 + 32;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                contentWidth < constraints.maxWidth
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                            children: List.generate(itemCount * 2 - 1, (i) {
                              if (i.isOdd) {
                                return const SizedBox(width: 12);
                              }
                              final index = i ~/ 2;
                              final isSelected = index == _currentIndex;
                              return GestureDetector(
                                onTap: () => _goToPage(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.white24,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      client.fileBase.from(
                                        widget.imageUrls[index],
                                        size: 64,
                                      ),
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.white54,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton(IconData icon, String tooltip) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        tooltip: tooltip,
        onPressed: () {},
      ),
    );
  }
}
