# Release only. Remove native Android logging, including dependency log calls.
# Dart logging is controlled in Dart; R8 does not process libapp.so.
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
    public static int wtf(...);
    public static int println(...);
}
