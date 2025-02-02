import 'package:flutter/material.dart';

class CustomBottomToolbar extends StatefulWidget {
  final bool isRecording;
  final bool isUploading;
  final VoidCallback onRecordPressed;
  final VoidCallback onMediaPressed;

  const CustomBottomToolbar({
    super.key,
    required this.isRecording,
    required this.isUploading,
    required this.onRecordPressed,
    required this.onMediaPressed,
  });

  @override
  State<CustomBottomToolbar> createState() => _CustomBottomToolbarState();
}

class _CustomBottomToolbarState extends State<CustomBottomToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHoveringMic = false;
  bool _isHoveringMedia = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMicButton(),
          _buildMediaButton(),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringMic = true),
      onExit: (_) => setState(() => _isHoveringMic = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 70,
        width: 70,
        transform: Matrix4.identity()
          ..scale(_isHoveringMic ? 1.1 : 1.0)
          ..translate(0.0, _isHoveringMic ? -2.0 : 0.0),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(70, 70),
              painter: MicrophonePainter(
                color: widget.isRecording ? Colors.red : Colors.tealAccent,
                isHovering: _isHoveringMic,
              ),
            ),
            if (widget.isUploading)
              Center(
                child: RotationTransition(
                  turns: _controller,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onRecordPressed,
                borderRadius: BorderRadius.circular(35),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Icon(
                    widget.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringMedia = true),
      onExit: (_) => setState(() => _isHoveringMedia = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        width: 60,
        transform: Matrix4.identity()
          ..scale(_isHoveringMedia ? 1.1 : 1.0)
          ..translate(0.0, _isHoveringMedia ? -2.0 : 0.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.tealAccent,
              Colors.teal,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: _isHoveringMedia ? 2 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onMediaPressed,
            borderRadius: BorderRadius.circular(30),
            child: const Icon(
              Icons.library_music,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class MicrophonePainter extends CustomPainter {
  final Color color;
  final bool isHovering;

  const MicrophonePainter({
    required this.color,
    required this.isHovering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        isHovering ? 8 : 4,
      );

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw microphone body
    path.moveTo(width * 0.3, height * 0.3);
    path.lineTo(width * 0.3, height * 0.6);
    path.quadraticBezierTo(
      width * 0.3,
      height * 0.7,
      width * 0.5,
      height * 0.7,
    );
    path.quadraticBezierTo(
      width * 0.7,
      height * 0.7,
      width * 0.7,
      height * 0.6,
    );
    path.lineTo(width * 0.7, height * 0.3);
    path.quadraticBezierTo(
      width * 0.7,
      height * 0.2,
      width * 0.5,
      height * 0.2,
    );
    path.quadraticBezierTo(
      width * 0.3,
      height * 0.2,
      width * 0.3,
      height * 0.3,
    );

    // Draw stand
    path.moveTo(width * 0.5, height * 0.7);
    path.lineTo(width * 0.5, height * 0.8);
    path.quadraticBezierTo(
      width * 0.5,
      height * 0.85,
      width * 0.4,
      height * 0.85,
    );
    path.lineTo(width * 0.6, height * 0.85);
    path.quadraticBezierTo(
      width * 0.5,
      height * 0.85,
      width * 0.5,
      height * 0.8,
    );

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    // Draw microphone
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
