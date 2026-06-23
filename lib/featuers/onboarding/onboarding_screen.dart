import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../route/app_pages.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Direct Farm Sourcing',
      'description': 'We bridge the gap by sourcing premium artisan produce directly from sustainable orchards and farms.',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop',
    },
    {
      'title': 'Zero Pesticides Choice',
      'description': 'Enjoy 100% natural, certified pesticide-free fruits and vegetables picked daily at peak ripeness.',
      'imageUrl': 'https://images.unsplash.com/photo-1610832958506-ee563361f155?w=600&auto=format&fit=crop',
    },
    {
      'title': 'Wholesale & Shop Portals',
      'description': 'Specialized access channels for bulk commercial purchases, internal staff, and employee self-services.',
      'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBrandColor = Color(0xFF00694C);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextButton(
                  onPressed: () {
                    Get.offAllNamed(Routes.ROLE_SELECTION);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: primaryBrandColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page View for slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  final slide = onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image wrapper
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: CachedNetworkImage(
                            imageUrl: slide['imageUrl']!,
                            height: 280.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 280.h,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(color: primaryBrandColor),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 280.h,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.eco, size: 80, color: primaryBrandColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Title
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF151E13),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Description text
                        Text(
                          slide['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF6D7A73),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation Area with dots & button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(right: 6.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? primaryBrandColor : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),

                  // Next or Get Started Button
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Get.offAllNamed(Routes.ROLE_SELECTION);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrandColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
