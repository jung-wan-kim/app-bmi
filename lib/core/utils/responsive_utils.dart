import 'package:flutter/material.dart';

/// 반응형 디자인을 위한 유틸리티 클래스
class ResponsiveUtils {
  // 브레이크포인트 정의
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // 디바이스 타입
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  // 화면 방향
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // 태블릿 여부
  static bool isTablet(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
  }
  
  // 대화면 여부 (태블릿 가로모드 또는 데스크톱)
  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint || 
           (isTablet(context) && isLandscape(context));
  }
  
  // 반응형 값 계산
  static double getResponsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  // 반응형 패딩
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return\1const EdgeInsets.all(
      getResponsiveValue(
        context: context,
        mobile: 16,
        tablet: 24,
        desktop: 32,
      ),
    );
  }
  
  // 반응형 그리드 열 수
  static int getResponsiveGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return isLandscape ? 2 : 1;
      case DeviceType.tablet:
        return isLandscape ? 3 : 2;
      case DeviceType.desktop:
        return 4;
    }
  }
  
  // 반응형 폰트 크기
  static double getResponsiveFontSize({
    required BuildContext context,
    required double baseSize,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize;
      case DeviceType.tablet:
        return baseSize * 1.1;
      case DeviceType.desktop:
        return baseSize * 1.2;
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// 반응형 빌더 위젯
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final Widget? mobileBuilder;
  final Widget? tabletBuilder;
  final Widget? desktopBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    // 특정 빌더가 제공된 경우 사용
    if (mobileBuilder != null && deviceType == DeviceType.mobile) {
      return mobileBuilder!;
    }
    if (tabletBuilder != null && deviceType == DeviceType.tablet) {
      return tabletBuilder!;
    }
    if (desktopBuilder != null && deviceType == DeviceType.desktop) {
      return desktopBuilder!;
    }
    
    // 기본 빌더 사용
    return builder(context, deviceType);
  }
}

/// 반응형 그리드 위젯
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: (mobileColumns ?? 1).toDouble(),
      tablet: (tabletColumns ?? 2).toDouble(),
      desktop: (desktopColumns ?? 3).toDouble(),
    ).toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return\1const SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}