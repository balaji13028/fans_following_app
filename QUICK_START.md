# 🚀 Quick Start Guide

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Generate Code (Required for Riverpod)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note**: This will generate the `.g.dart` files needed for Riverpod. The linter errors you see are normal until this step is completed.

## Step 3: Update API Base URL

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

## Step 4: Run the App

```bash
flutter run
```

---

## ✅ What's Included

### Storage Service (Hive)
- ✅ Logged in status tracking
- ✅ Auth token storage
- ✅ User data persistence
- ✅ Easy to use API

### API Service (Dio)
- ✅ Automatic auth token injection
- ✅ Request/response logging
- ✅ Error handling
- ✅ Timeout management

### Auth Provider (Riverpod)
- ✅ Sign in/Sign up
- ✅ Sign out
- ✅ User state management
- ✅ Auto-loads stored user data

---

## 📝 Usage Example

```dart
// In your widget
final authState = ref.watch(authNotifierProvider);
final authNotifier = ref.read(authNotifierProvider.notifier);

// Sign in
await authNotifier.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Check authentication
if (authState.isAuthenticated) {
  print('User: ${authState.user?.name}');
}
```

---

## 🐛 Troubleshooting

### "Target of URI hasn't been generated" Error
**Solution**: Run code generation (Step 2 above)

### "Undefined class" Errors
**Solution**: Run code generation (Step 2 above)

### Hive Errors
**Solution**: Make sure `StorageService.init()` is called in `main.dart` (already done)

---

## 📚 Next Steps

1. ✅ Dependencies installed
2. ✅ Code generated
3. ⏭️ Build authentication screens
4. ⏭️ Build dashboard
5. ⏭️ Build feed feature
6. ⏭️ Build notifications feature
7. ⏭️ Build profile feature

---

**Ready to build! 🎉**

