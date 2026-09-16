class UserReferenceModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String refereeName;
  final String relationship; // Guarantor, Employer, Next of Kin, Colleague
  final String refereePhone;
  final String refereeEmail;
  final String status; // Verified, Pending, Declined
  final String submittedDate;

  const UserReferenceModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.refereeName,
    required this.relationship,
    required this.refereePhone,
    required this.refereeEmail,
    required this.status,
    required this.submittedDate,
  });
}

class KycDocumentModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String documentType; // Driver's License, National ID, Passport, Utility Bill
  final String documentNumber;
  final String submissionDate;
  final String expiryDate;
  final String status; // Approved, Pending Review, Rejected

  const KycDocumentModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.documentType,
    required this.documentNumber,
    required this.submissionDate,
    required this.expiryDate,
    required this.status,
  });
}

// --- MOCK DATA ---

final List<UserReferenceModel> mockReferencesList = [
  const UserReferenceModel(
    id: '#REF-801',
    userName: 'Sarah Johnson',
    userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Dr. Robert Sterling',
    relationship: 'Employer',
    refereePhone: '+1 (555) 234-5678',
    refereeEmail: 'r.sterling@apexcorp.com',
    status: 'Verified',
    submittedDate: 'Aug 02, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-802',
    userName: 'David Chen',
    userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Chief Inspector James',
    relationship: 'Guarantor',
    refereePhone: '+1 (555) 876-5432',
    refereeEmail: 'james.sec@gov.org',
    status: 'Pending',
    submittedDate: 'Aug 05, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-803',
    userName: 'Amara Okezie',
    userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Grace Okezie',
    relationship: 'Next of Kin',
    refereePhone: '+1 (555) 345-6789',
    refereeEmail: 'grace.o@gmail.com',
    status: 'Verified',
    submittedDate: 'Aug 08, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-804',
    userName: 'Marcus Vance',
    userAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Engr. Victor Hugo',
    relationship: 'Colleague',
    refereePhone: '+1 (555) 901-2345',
    refereeEmail: 'victor.hugo@techbuild.io',
    status: 'Declined',
    submittedDate: 'Aug 11, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-805',
    userName: 'Elena Rostova',
    userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Prof. Alistair Finch',
    relationship: 'Guarantor',
    refereePhone: '+1 (555) 678-9012',
    refereeEmail: 'a.finch@oxford.edu',
    status: 'Pending',
    submittedDate: 'Aug 14, 2025',
  ),
];

final List<KycDocumentModel> mockKycDocsList = [
  const KycDocumentModel(
    id: '#KYD-901',
    userName: 'Sarah Johnson',
    userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    documentType: "Driver's License",
    documentNumber: 'DL-99482710-X',
    submissionDate: 'Aug 01, 2025',
    expiryDate: 'Nov 14, 2028',
    status: 'Approved',
  ),
  const KycDocumentModel(
    id: '#KYD-902',
    userName: 'David Chen',
    userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    documentType: 'National ID (NIN)',
    documentNumber: 'NIN-4421890312',
    submissionDate: 'Aug 04, 2025',
    expiryDate: 'N/A',
    status: 'Pending Review',
  ),
  const KycDocumentModel(
    id: '#KYD-903',
    userName: 'Amara Okezie',
    userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    documentType: 'International Passport',
    documentNumber: 'PASS-A8839201',
    submissionDate: 'Aug 07, 2025',
    expiryDate: 'Jan 22, 2031',
    status: 'Approved',
  ),
  const KycDocumentModel(
    id: '#KYD-904',
    userName: 'Marcus Vance',
    userAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    documentType: 'Utility Bill',
    documentNumber: 'UTIL-2025-0811',
    submissionDate: 'Aug 10, 2025',
    expiryDate: 'Nov 10, 2025',
    status: 'Rejected',
  ),
  const KycDocumentModel(
    id: '#KYD-905',
    userName: 'Kofi Mensah',
    userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    documentType: "Driver's License",
    documentNumber: 'DL-77382019-B',
    submissionDate: 'Aug 13, 2025',
    expiryDate: 'May 18, 2027',
    status: 'Pending Review',
  ),
];
