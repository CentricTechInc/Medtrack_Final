import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientReportScreen extends StatelessWidget {
  const PatientReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    "Patient Report",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Date of Prescription
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Date of Prescription: 04/18/2025",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Patient and Doctor Information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Patient Information",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          infoRow("Full Name:", "Arjun Sharma"),
                          infoRow("Age:", "25 Years"),
                          infoRow("Gender:", "Male"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Doctor Info
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor Information",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          infoRow("Full Name:", "Dr. Karan Verma"),
                          infoRow("Specialty:", "Psychologist"),
                          infoRow("Phone Number:", "001 834 567 80"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Prescription Details
              Text(
                "Prescription Details",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10.h),

              // First Prescription
              prescriptionCard(
                drugName: "Metformin / 500 mg / Twice a day with meals",
                recommendedTests: [
                  "Vitamin B12 & D Levels",
                  "Electrolyte Panel",
                  "Cortisol Level Test",
                  "Drug Screening Panel",
                  "MRI / CT Scan (if neurological symptoms)",
                ],
                instruction:
                    "Take with food to reduce stomach upset. Do not skip meds. Monitor blood sugar regularly. Avoid alcohol while taking this medication.",
              ),
              SizedBox(height: 10.h),

              // Second Prescription
              prescriptionCard(
                drugName: "Metformin / 500 mg / Twice a day with meals",
                recommendedTests: [],
                instruction:
                    "Take with food to reduce stomach upset. Do not skip meds. Monitor blood sugar regularly. Avoid alcohol while taking this medication.",
              ),
              SizedBox(height: 30.h),

              // Signature
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Dr. Karan Patel",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      width: 100.w,
                      height: 1.h,
                      color: Colors.grey,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                    ),
                    Text(
                      "E-Signature",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            "$label ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget prescriptionCard({
    required String drugName,
    required List<String> recommendedTests,
    required String instruction,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Drug Name / Strength / Frequency:  $drugName",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          if (recommendedTests.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              "Recommended Tests:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            ...recommendedTests
                .map((test) => Padding(
                      padding: EdgeInsets.only(left: 10.w, top: 2.h),
                      child: Text(
                        "• $test",
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ))
                .toList(),
          ],
          SizedBox(height: 8.h),
          Text(
            "Instruction:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          Text(
            instruction,
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
