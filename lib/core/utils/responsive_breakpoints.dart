abstract final class ResponsiveBreakpoints {
  static const double compact = 600;
  static const double medium = 840;

  static bool useNavigationRail(double width) => width >= medium;
}
