// diary_page.dart (FINAL CODE: LETTER OPEN BUTTON)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

// Color definitions (Assuming these are defined in main.dart)
class BirthdayDiaryApp {
  static const Color primaryLavender = Color(0xFFC7B1E4);
  static const Color accentRoseGold = Color(0xFFE4C7B1);
  static const Color creamBackground = Color(0xFFFFF8E1);
}

// Data for the Swiping Sticky Notes
// ***IMPORTANT: Ye assets aapke assets folder mein hone chahiye***
final List<Map<String, dynamic>> memoryStacks = [
  {
    'title': 'Birthday joy',
    'secret': 'Keep calm and eat more cake!',
    'color': const Color(0xFFFEE1E8), // Light Pink
    'imagePath': 'assets/ss.jpg', // Single main image path
  },
  {
    'title': 'Stay blessed',
    'secret': 'Wishing you more blessings, more money, and more reasons to smile this year.',
    'color': const Color(0xFFE1FEF6), // Mint Green
    'imagePath': 'assets/2.jpg', // Single main image path
  },
  {
    'title': 'Always be happy',
    'secret': 'May your birthday be as amazing as you are — cheers to another year of greatness!',
    'color': const Color(0xFFE8F2FE), // Light Blue
    'imagePath': 'assets/1.jpg', // Single main image path
  },
];


class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late ConfettiController _confettiController;
  late PageController _pageController;
  int _currentPage = 0;

  // FIX 1: Isko sirf declare kiya hai, value didChangeDependencies mein aayegi.
  late double _viewportFraction;

  // *** NEW STATE: Letter visibility control ***
  bool _isLetterVisible = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // FIX 2: PageController ko ek default/dummy value se initialize kiya.
    _pageController = PageController(
      viewportFraction: 0.8, // Default value, will be corrected in didChangeDependencies
      initialPage: 0,
    )..addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // --- Performance: Pre-cache Images for smooth scrolling ---
    for (var memory in memoryStacks) {
      if (memory.containsKey('imagePath') && memory['imagePath'] is String) {
        precacheImage(AssetImage(memory['imagePath']), context);
      }
    }
    // ---------------------------------------------------------

    // FIX 3: Context ko safely yahan use kiya hai.
    double newViewportFraction = MediaQuery.of(context).size.width > 800 ? 0.45 : 0.8;

    // Check agar viewport change hua hai (responsive design ke liye)
    if (_pageController.viewportFraction != newViewportFraction) {
      _viewportFraction = newViewportFraction;

      double currentPage = _pageController.hasClients && _pageController.page != null ? _pageController.page! : 0.0;

      // Purane controller ko dispose aur naye ko correct value ke saath initialize kiya
      // Existing listener will be moved to the new controller
      _pageController.removeListener(() {}); // Remove old listener before disposing
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: _viewportFraction,
        initialPage: currentPage.round(),
      )..addListener(() { // Adding listener back
        if (_pageController.page!.round() != _currentPage) {
          setState(() {
            _currentPage = _pageController.page!.round();
          });
        }
      });
    } else {
      _viewportFraction = newViewportFraction;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: BirthdayDiaryApp.creamBackground,
          body: Stack(
            children: [
              // Main Scrollable Content
              SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 60.0 : 20.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- SECTION 1: HEADER (With Gradient) ---
                        _buildDiaryHeader(context, isLargeScreen),
                        const SizedBox(height: 50),

                        // --- NEW: Letter Open Button ---
                        if (!_isLetterVisible) _buildOpenLetterButton(),
                        const SizedBox(height: 50),

                        // --- SECTION 2: THE MAIN LETTER (Responsive Font + Animated) ---
                        _buildHeartfeltLetter(context, isLargeScreen),
                        // The SizedBox below is now inside the AnimatedOpacity wrapper
                        // const SizedBox(height: 50),

                        // The rest of the content will appear only after the letter is visible
                        if (_isLetterVisible) ...[
                          const SizedBox(height: 50),
                          // --- SECTION 3: BEST ANIMATION (Local Asset Lottie File) ---
                          _buildMidScrollAnimation(context),
                          const SizedBox(height: 50),

                          // --- SECTION 4: SCROLLABLE STICKY NOTES GALLERY (Page Change Effect) ---
                          _buildScrollableMemoryGallery(context, isLargeScreen),
                          const SizedBox(height: 20), // Space for dots

                          // --- DOT INDICATOR ---
                          _buildDotIndicator(),
                          const SizedBox(height: 60),

                          // --- FINAL FOOTER ---
                          Text(
                            'AGAIN HBD😊',
                            style: GoogleFonts.pacifico(fontSize: 20, color: BirthdayDiaryApp.accentRoseGold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // CONFETTI WIDGET
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.1,
                  colors: const [Colors.pink, Colors.yellow, Colors.purple, Colors.white],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW WIDGET: Open Letter Button ---
  Widget _buildOpenLetterButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isLetterVisible = true;
        });
      },
      icon: const Icon(Icons.mail_outline, color: Colors.white),
      label: Text(
        'Open The Birthday Letter',
        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: BirthdayDiaryApp.primaryLavender,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
      ),
    );
  }

  // --- DOT INDICATOR ---
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(memoryStacks.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPage == index ? BirthdayDiaryApp.primaryLavender : BirthdayDiaryApp.accentRoseGold.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  // --- SECTION 1: HEADER WIDGET (With Gradient) ---
  Widget _buildDiaryHeader(BuildContext context, bool isLargeScreen) {
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: BirthdayDiaryApp.accentRoseGold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
              ]
          ),
        ),
        const SizedBox(height: 15),
        // **GRADIENT TITLE**
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [BirthdayDiaryApp.accentRoseGold, BirthdayDiaryApp.primaryLavender],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            'HAPPY BIRTHDAY\nISHA',
            style: GoogleFonts.merienda(
                fontSize: isLargeScreen ? 40 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Color set to white for gradient to show best
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.1), offset: const Offset(1, 1), blurRadius: 3)
                ]
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(color: BirthdayDiaryApp.primaryLavender, thickness: 1.5, indent: 50, endIndent: 50, height: 30,),
      ],
    );
  }

  // --- SECTION 2: THE MAIN LETTER WIDGET (Responsive Font + ANIMATED) ---
  Widget _buildHeartfeltLetter(BuildContext context, bool isLargeScreen) {
    return AnimatedOpacity(
      opacity: _isLetterVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800), // Fade-in duration
      child: Visibility(
        visible: _isLetterVisible, // Only render when visible is true to save resources
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 40.0 : 25.0),
            child: Text(
              "My Dear C-O-U-S-I-N,\n\n"
                  "Today is the special day you came into this world. Over the years, you have become more than just my cousin — you are truly one of my closest friends.\n\n"
                  "I hope this year brings you endless happiness, laughter, and success.Keep smiling and shining, always. Happy Birthday to my sweetest!\n\n"
                  "US",
              style: GoogleFonts.pacifico(
                fontSize: isLargeScreen ? 20 : 16,
                height: 1.8,
                color: Colors.brown.shade700,
              ),
              textAlign: isLargeScreen ? TextAlign.justify : TextAlign.start,
            ),
          ),
        ),
      ),
    );
  }


  // --- SECTION 3: BEST ANIMATION WIDGET (Local Asset Lottie File) ---
  Widget _buildMidScrollAnimation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      height: 300,
      width: 300,
      child: Lottie.asset(
        'assets/HappyBirthday.json',
        repeat: true,
        reverse: true,
        animate: true,
        frameBuilder: (context, child, composition) {
          if (composition != null) {
            return child;
          } else {
            return Center(
              child: Text(
                'Lottie Loading...',
                style: GoogleFonts.lato(color: BirthdayDiaryApp.primaryLavender),
              ),
            );
          }
        },
      ),
    );
  }

  // --- SECTION 4: SCROLLABLE STICKY NOTES GALLERY (Page Change Effect) ---
  Widget _buildScrollableMemoryGallery(BuildContext context, bool isLargeScreen) {
    return Column(
      children: [
        Text(
          "(👈 Swipe 👉)",
          style: GoogleFonts.merienda(fontSize: isLargeScreen ? 28 : 22, fontWeight: FontWeight.bold, color: BirthdayDiaryApp.primaryLavender),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: isLargeScreen ? 450 : 380,
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return PageView.builder(
                itemCount: memoryStacks.length,
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final memory = memoryStacks[index];

                  // Animation Logic (Scale effect for center note)
                  double scale = 1.0;
                  // HasClients check is implicitly safe now due to PageView.builder structure
                  if (_pageController.page != null) {
                    double page = _pageController.page!;
                    double distance = (page - index).abs();
                    scale = (1 - (distance * 0.4)).clamp(0.8, 1.0);
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      child: Transform.scale(
                        scale: scale,
                        child: _buildStickyNote(
                          context,
                          memory,
                          index,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Sticky Note Widget - Ab yeh sirf ek image dikhayega (no inner swiping)
  Widget _buildStickyNote(BuildContext context, Map<String, dynamic> memory, int index) {
    Color color = memory['color'];
    String title = memory['title'];
    String secret = memory['secret'];
    String imagePath = memory['imagePath']; // Single image path access

    // Rotation for the sticky note effect
    double angle = (index % 2 == 0) ? -0.05 : 0.05;

    return GestureDetector(
      onTap: () {
        // Tap karne par Memory details show honge
        showDialog(
          context: context,
          builder: (context) => _buildMemoryDialog(context, {'title': title, 'desc': secret}, color),
        );
      },
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 300,
          height: 380,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(5, 5)),
            ],
            border: Border.all(color: Colors.brown.shade200, width: 2),
          ),
          child: Column(
            children: [
              // ***SINGLE IMAGE AREA (Local Asset with Polaroid Border)***
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // NEW: Background color white for border
                    borderRadius: BorderRadius.circular(5),

                    // NEW: BORDER AND SHADOW for a photo/Polaroid look
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                    // ********************************

                    image: DecorationImage( // Local Asset use kiya
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      imagePath.contains('main') ? '' : "", // Agar image na mili toh text dikhega
                      style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ),
              // Title Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  title,
                  style: GoogleFonts.merienda(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Read Me",
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.redAccent.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryDialog(BuildContext context, Map<String, String> memory, Color color) {
    return AlertDialog(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        memory['title']!,
        style: GoogleFonts.merienda(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Text(
          memory['desc']!,
          style: GoogleFonts.pacifico(fontSize: 18, color: Colors.brown.shade800),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close Diary', style: GoogleFonts.lato(color: Colors.black)),
        ),
      ],
    );
  }
}