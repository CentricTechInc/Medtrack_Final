import 'package:fl_chart/fl_chart.dart';
import 'package:medtrac/models/document_model.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

const List<String> _doctorDrawerItemTiles = [
  'Profile',
  'My Reviews',
  'Set Availability',
  'Wellness Hub',
  'Account Info',
  'Change Password',
  'Privacy & Policy',
  'Support',
  'Delete Account',
  'Logout',
];

const List<String> _userDrawerItemsTitle = [
  'Profile',
  'My Purchases',
  'Wellness Hub',
  'Account Info',
  'Change Password',
  'Privacy & Policy',
  'Support',
  'Delete Account',
  'Logout',
];

List<String> get drawerItemsTitle {
  if (HelperFunctions.isUser()) {
    return _userDrawerItemsTitle;
  } else {
    return _doctorDrawerItemTiles;
  }
}

Map<String, String> _doctorDrawerdrawerRoutes = {
  'Profile': AppRoutes.personalInfoScreen,
  'My Reviews': AppRoutes.myReviewScreen,
  'Set Availability': AppRoutes.availabilityInfoScreen,
  'Wellness Hub': AppRoutes.wellnessHubScreen,
  'Account Info': AppRoutes.accountInfoScreen,
  'Change Password': AppRoutes.changePasswordScreen,
  'Privacy & Policy': AppRoutes.privacyPolicyScreen,
  'Support': AppRoutes.customerSupportScreen,
  'Delete Account': AppRoutes.personalInfoScreen,
  'Logout': AppRoutes.signupScreen,
};


Map<String, String> _userDrawerdrawerRoutes = {
  'Profile': AppRoutes.userProfileScreen,
  'My Purchases': AppRoutes.userMyPurchasesScreen,
  'Wellness Hub': AppRoutes.wellnessHubScreen,
  'Account Info': AppRoutes.userAccountInfoScreen,
  'Change Password': AppRoutes.changePasswordScreen,
  'Privacy & Policy': AppRoutes.privacyPolicyScreen,
  'Support': AppRoutes.customerSupportScreen,
  'Delete Account': AppRoutes.personalInfoScreen,
  'Logout': AppRoutes.signupScreen,
};

Map<String, String> get drawerRoutes {
  if (HelperFunctions.isUser()) {
    return _userDrawerdrawerRoutes;
  } else {
    return _doctorDrawerdrawerRoutes;
  }
}

const String privacyPolicyContent = '''
Last Update: 02/04/2025

Privacy Policy

1. Information We Collect
We collect personal information such as your name, contact details, delivery address, and payment information when you register or place an order. We may also collect non-personal information like your IP address and browsing activity to improve our services.

2. How We Use Your Information
Your information is used to process your appointments, deliver services, communicate with you, and enhance your app experience. We may also use your data to send promotional updates about new offers and services, but you can opt out at any time.

3. How We Protect Your Information
We use robust security measures to protect your personal information from unauthorized access or disclosure. Our secure payment processing partners also ensure safe transactions for your bookings and consultations.

4. Sharing Your Information
We do not sell or rent your personal information to third parties. However, we may share your data with trusted partners for appointment scheduling, consultations, or other necessary services.
''';

const String aboutUsContent = '''
At Medtrac, we are dedicated to transforming mental wellness into an accessible, everyday experience. Our mission is to empower individuals with the tools and support needed to manage stress, enhance mindfulness, and build emotional resilience.
''';


const List<FlSpot> dummySpots = [
  
    FlSpot(0, 600),
    FlSpot(1, 1100),
    FlSpot(2, 800),
    FlSpot(3, 700),
    FlSpot(4, 1700),
    FlSpot(5, 2100),
  ];
final List dummyWellnessContentList = [
  {
    "id": 1,
    "thumbnailUrl": Assets.article1,
    "title": "Morning Meditation Routine",
    "date": "01 Jul 2025",
    "readTime": 5
  },
  {
    "id": 2,
    "thumbnailUrl": Assets.article1,
    "title": "Top 5 Foods for Energy",
    "date": "28 Jun 2025",
    "readTime": 4
  },
  {
    "id": 3,
    "thumbnailUrl": Assets.article1,
    "title": "Simple Stretches for Flexibility",
    "date": "25 Jun 2025",
    "readTime": 3
  },
  {
    "id": 4,
    "thumbnailUrl": Assets.article1,
    "title": "Hydration Tips You Need to Know",
    "date": "20 Jun 2025",
    "readTime": 6
  },
  {
    "id": 5,
    "thumbnailUrl": Assets.article1,
    "title": "Breathing Techniques for Stress Relief",
    "date": "15 Jun 2025",
    "readTime": 7
  },
  {
    "id": 6,
    "thumbnailUrl": Assets.article1,
    "title": "Daily Walk Benefits",
    "date": "10 Jun 2025",
    "readTime": 4
  },
  {
    "id": 7,
    "thumbnailUrl": Assets.article1,
    "title": "Healthy Sleep Habits",
    "date": "05 Jun 2025",
    "readTime": 5
  }
];


const String querySendMessage = "Your query has been sent successfully. Our support team is reviewing it and will get back to you within 2–3 hours. Thank you for your patience.";

const String healthArticleDummyData =   "Mental health is a crucial aspect of our overall well-being, yet it is often overlooked or stigmatized. "
              "Therapy, also known as counseling or psychotherapy, plays a vital role in helping individuals navigate "
              "emotional, psychological, and behavioral challenges. Whether dealing with anxiety, depression, trauma, "
              "or relationship issues, therapy provides a structured and supportive environment to explore emotions, "
              "thoughts, and behaviors.\n\n"
              "Therapy involves speaking with a trained mental health professional, such as a psychologist, psychiatrist, "
              "or licensed counselor, to address mental health concerns. It can be done individually, in groups, or even "
              "with family members, depending on the nature of the issue. The goal is to help individuals understand their "
              "feelings, learn coping strategies, and develop healthier patterns of behavior.\n\n"
              "One of the biggest barriers to seeking therapy is the stigma associated with mental health. Many people hesitate "
              "to reach out for help because they fear being seen as weak. However, seeking therapy is a sign of strength, "
              "not weakness. It shows that you are taking control of your well-being and actively working toward better mental health.";

final List<Document> dummyDocuments = [
  Document(
    id: '1',
    name: 'Metformin Prescription.pdf',
    createdAt: DateTime(2025, 4, 18),
    type: 'pdf',
    isShared: false,
  ),
  Document(
    id: '2',
    name: 'Vitamin B12 Supplement.pdf',
    createdAt: DateTime(2025, 4, 20),
    type: 'pdf',
    isShared: false,
  ),
  Document(
    id: '3',
    name: 'Lab Report - April.pdf',
    createdAt: DateTime(2025, 4, 12),
    type: 'pdf',
    isShared: true,
  ),
  Document(
    id: '4',
    name: 'MRI Scan Image.jpg',
    createdAt: DateTime(2025, 4, 15),
    type: 'jpg',
    isShared: true,
  ),
  Document(
    id: '5',
    name: 'Invoice #245.pdf',
    createdAt: DateTime(2025, 4, 22),
    type: 'pdf',
    isShared: true,
  ),
];
