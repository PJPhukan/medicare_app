// All fixed UI text lives here. Never hardcode strings in widgets.

abstract class AppStrings {
  // ─── App ────────────────────────────────────────────────────────────────────
  static const appName = 'MediForze';
  static const appTagline = 'Your complete healthcare companion';

  // ─── General ────────────────────────────────────────────────────────────────
  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const save = 'Save';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const remove = 'Remove';
  static const done = 'Done';
  static const next = 'Next';
  static const back = 'Back';
  static const close = 'Close';
  static const retry = 'Retry';
  static const refresh = 'Refresh';
  static const search = 'Search';
  static const filter = 'Filter';
  static const clear = 'Clear';
  static const clearAll = 'Clear All';
  static const viewAll = 'View All';
  static const seeMore = 'See More';
  static const loading = 'Loading…';
  static const pleaseWait = 'Please wait…';
  static const submitting = 'Submitting…';
  static const saving = 'Saving…';
  static const tryAgain = 'Try again';
  static const submit = 'Submit';
  static const apply = 'Apply';
  static const share = 'Share';
  static const download = 'Download';
  static const upload = 'Upload';
  static const select = 'Select';
  static const selectAll = 'Select All';
  static const optional = 'Optional';
  static const required = 'Required';
  static const yes = 'Yes';
  static const no = 'No';
  static const add = 'Add';
  static const update = 'Update';
  static const create = 'Create';
  static const send = 'Send';
  static const view = 'View';
  static const dismiss = 'Dismiss';
  static const snooze = 'Snooze';
  static const markAsTaken = 'Mark as Taken';
  static const skip = 'Skip';
  static const selectCountry = 'Select Country';
  static const selectOptions = 'Select options';
  static const noresults = 'No results';
  // ─── Onboarding ─────────────────────────────────────────────────────────────
  static const onboardingSkip = 'Skip';
  static const onboardingGetStarted = 'Get Started';
  static const onboardingNext = 'Next';

  static const onboarding1Title = 'Your Health,\nAll in One Place';
  static const onboarding1Body =
      'Medicines, vitals, appointments, and care — beautifully organised and always with you.';

  static const onboarding2Title = 'Never Miss\na Dose Again';
  static const onboarding2Body =
      'Smart reminders, adherence tracking, and personalised insights keep you on top of your health.';

  static const onboarding3Title = 'Private, Secure\n& Always Yours';
  static const onboarding3Body =
      'Your health data is encrypted and shared only with the people you trust — doctors, family, caregivers.';

  static const onboarding4Title = 'Built for\nProfessionals Too';
  static const onboarding4Body =
      'Doctors, nurses, and caregivers get a dedicated workspace — manage patients, consultations, and prescriptions with ease.';

  // ─── Auth ────────────────────────────────────────────────────────────────────
  static const signIn = 'Sign In';
  static const signUp = 'Sign Up';
  static const signOut = 'Sign Out';
  static const logIn = 'Log In';
  static const logOut = 'Log Out';
  static const createAccount = 'Create account';
  static const alreadyHaveAccount = 'Already have an account?';
  static const dontHaveAccount = "Don't have an account?";
  static const forgotPassword = 'Forgot password?';
  static const resetPassword = 'Reset Password';
  static const changePassword = 'Change Password';
  static const enterOtp = 'Enter OTP';
  static const otpSentTo = 'OTP sent to';
  static const resendOtp = 'Resend OTP';
  static const resendIn = 'Resend in';
  static const verifyPhone = 'Verify Phone Number';
  static const phoneNumber = 'Phone Number';
  static const enterPhoneNumber = 'Enter your phone number';
  static const enterOtpDesc = 'Enter the 6-digit code sent to your number';
  static const continueText = 'Continue';
  static const getStarted = 'Get Started';
  static const welcomeBack = 'Welcome back';
  static const welcomeTo = 'Welcome to';
  static const termsAndConditions = 'Terms & Conditions';
  static const privacyPolicy = 'Privacy Policy';
  static const agreeToTerms = 'I agree to the';
  static const and = 'and';
  static const google="Google";
  static const apple="Apple";

  // ─── Auth — Login screen ─────────────────────────────────────────────────────
  static const loginSubtitle        = 'Sign in to your MediForze account';
  static const emailOrMobile        = 'Email or Mobile Number';
  static const emailOrMobileHint    = 'Enter email or mobile number';
  static const password             = 'Password';
  static const passwordHint         = 'Enter your password';
  static const useOtpInstead        = 'Use OTP instead';
  static const usePasswordInstead   = 'Use password instead';
  static const sendOtp              = 'Send OTP';
  static const orContinueWith       = 'or continue with';

  // ─── Auth — Register screen ──────────────────────────────────────────────────
  static const registerSubtitle     = 'Start your health journey';
  static const fullName             = 'Full Name';
  static const fullNameHint         = 'Arjun Sharma';
  static const emailHint            = 'arjun@email.com';
  static const mobileNumber         = 'Mobile Number';
  static const mobileHint           = '98765 43210';
  static const passwordCreateHint   = 'Create a strong password';
  static const strengthVeryWeak     = 'Very weak';
  static const strengthWeak         = 'Weak';
  static const strengthFair         = 'Fair';
  static const strengthGood         = 'Good';
  static const strengthStrong       = 'Strong';

  // ─── Auth — Quiz screen ──────────────────────────────────────────────────────
  static const quizTitle            = 'Quick health setup';
  static const quizSubtitle         = 'Helps us personalise your experience. You can update anytime.';
  static const yourAge              = 'Enter Your age';
  static const ageHint              = '28';
  static const bloodGroup           = 'Blood group';

  // ─── Auth — Biometric screen ─────────────────────────────────────────────────
  static const enableBiometrics     = 'Enable biometrics';
  static const biometricSubtitle    = 'Use Face ID or Fingerprint for quick,\nsecure access every time.';
  static const touchSensor          = 'Touch the sensor to continue';
  static const enableBiometricsBtn      = 'Enable Biometrics';
  static const usePassword              = 'Use Password';
  static const useOtp                   = 'Use OTP';
  static const skipForNow               = 'Skip for now';
  static const biometricChecking        = 'Checking device capabilities…';
  static const biometricNotAvailable    = 'Biometric authentication is not available on this device.';
  static const biometricNotAvailableTag = 'Not available';
  static const biometricAuthReason      = 'Confirm your biometric to enable quick login';
  static const biometricAuthFailed      = 'Authentication failed. Please try again.';
  static const biometricFaceId         = 'Face ID';
  static const biometricIris           = 'Iris';
  static const biometricFingerprint    = 'Fingerprint';
  static const biometricVerifying      = 'Verifying…';

  // ─── Auth — Emergency screen ─────────────────────────────────────────────────
  static const emergencyBadge              = 'EMERGENCY';
  static const emergencyTitle              = 'Emergency info';
  static const emergencySubtitle          = 'Helps responders in critical situations.';
  static const emergencyInfoSection       = 'Emergency info';
  static const knownAllergies             = 'Allergies';
  static const selectAllergies            = 'Select allergies';
  static const searchAllergiesHint        = 'Search or add custom allergy…';
  static const chronicConditions          = 'Chronic medical conditions';
  static const selectConditions           = 'Select conditions';
  static const searchConditionsHint       = 'Search or add custom condition…';
  static const allergiesHint              = 'Type an allergy and press +';
  static const conditionsHint             = 'Type a condition and press +';
  static const emergencyContact           = 'Emergency contact';
  static const contactName               = 'Contact name';
  static const contactPhone              = 'Contact phone';
  static const addCustom                 = 'Add custom…';
  static const saveAndContinue           = 'Save & Continue';
  static const emergencyDataNote         = 'This data is stored securely and only used in emergencies.';

  // ─── Auth — Subscription screen ──────────────────────────────────────────────
  static const choosePlan           = 'Choose your plan';
  static const planSubtitle         = 'Upgrade or change anytime from settings.';
  static const planBasicName        = 'Basic';
  static const planPremiumName      = 'Premium';
  static const planFreeBadge        = 'FREE';
  static const planPremiumBadge     = 'PREMIUM';
  static const planFreePrice        = 'Free';
  static const planPremiumPrice     = '₹199';
  static const planPeriodMonth      = '/ month';
  static const startForFree         = 'Start for Free';
  static const getPremium           = 'Get Premium';
  static const noCreditCard         = 'No credit card required for free plan.';
  static const planBillingYearly    = 'Yearly';
  static const planPeriodYear       = '/ year';
  static const planUnlimited        = 'Unlimited';
  static const planSave             = 'Save';     // prefix: "Save 20%"
  static const planDayTrial         = '-day trial'; // suffix: "7-day trial"
  static const planEverythingIn     = 'Everything in'; // prefix: "Everything in Standard"
  static const planBasicFeature1    = 'Up to 3 medicines';
  static const planBasicFeature2    = 'Basic vitals tracking';
  static const planBasicFeature3    = 'Community access';
  static const planPremiumFeature1  = 'Unlimited medicines';
  static const planPremiumFeature2  = 'Advanced analytics';
  static const planPremiumFeature3  = 'Professional connect';
  static const planPremiumFeature4  = 'Priority support';
  static const planPremiumFeature5  = 'Offline mode';

  // ─── Coupon ───────────────────────────────────────────────────────────────────
  static const couponAdd            = 'Add coupon';
  static const couponHint           = 'SAVE20';
  static const couponApply          = 'Apply';
  static const couponRemove         = 'Remove';
  static const couponInvalid        = 'Invalid coupon';
  static const couponApplied        = 'Coupon applied';
  static const couponPctOff         = '% off applied';   // prefix with value: "20% off applied"
  static const couponFlatOff        = ' off applied';    // prefix with amount: "₹160 off applied"
  static const couponFreePrefix     = 'Free ';           // "Free Basic applied"
  static const couponFreeSuffix     = ' applied';

  // ─── Auth — OTP screen ───────────────────────────────────────────────────────
  static const verifyIdentity       = 'Verify your identity';
  static const otpSentMessage       = 'We sent a 6-digit code to';
  static const verify               = 'Verify';
  static const didntReceiveIt       = "Didn't receive it? ";
  static const resend               = 'Resend';
  static const codeSent             = 'Code sent! Check your messages.';

  // ─── Auth — Forgot password flow ─────────────────────────────────────────────
  static const forgotPasswordTitle   = 'Forgot password?';
  static const forgotPasswordSubtitle = "Enter your email and we'll send a reset code.";
  static const sendResetCode         = 'Send Reset Code';
  static const forgotOtpTitle        = 'Check your inbox';
  static const forgotOtpSubtitle     = 'Enter the reset code we sent to';
  static const verifyCode            = 'Verify Code';
  static const setNewPassword        = 'Set new password';
  static const setNewPasswordSubtitle = 'Choose a strong password for your account.';
  static const newPassword           = 'New Password';
  static const newPasswordHint       = 'Enter new password';
  static const confirmPassword       = 'Confirm Password';
  static const confirmPasswordHint   = 'Re-enter your password';
  static const resetPasswordBtn      = 'Reset Password';
  static const passwordsDoNotMatch2  = 'Passwords do not match';
  static const passwordResetSuccess  = 'Password reset! Please sign in.';
static const searchCountryHint    = 'Search country or code…';
static const noCountriesFound     = 'No countries found';
  // ─── Dashboard ──────────────────────────────────────────────────────────────
  static const dashboard = 'Dashboard';
  static const goodMorning = 'Good morning';
  static const goodAfternoon = 'Good afternoon';
  static const goodEvening = 'Good evening';
  static const goodNight = 'Good night';
  static const todayOverview = "Today's Overview";
  static const upcomingDoses = 'Upcoming Doses';
  static const todayMedicines = "Today's Medicines";
  static const recentVitals = 'Recent Vitals';
  static const quickActions = 'Quick Actions';
  static const noActivityToday = 'No activity today';

  // ─── Medicines ──────────────────────────────────────────────────────────────
  static const medicines = 'Medicines';
  static const myMedicines = 'My Medicines';
  static const addMedicine = 'Add Medicine';
  static const editMedicine = 'Edit Medicine';
  static const medicineName = 'Medicine Name';
  static const dosage = 'Dosage';
  static const frequency = 'Frequency';
  static const startDate = 'Start Date';
  static const endDate = 'End Date';
  static const reminderTime = 'Reminder Time';
  static const addReminderTime = 'Add Reminder Time';
  static const instructions = 'Instructions';
  static const beforeFood = 'Before Food';
  static const afterFood = 'After Food';
  static const withFood = 'With Food';
  static const addDose = 'Add Dose';
  static const doseNameHint = 'e.g. Metformin 500mg';
  static const doseUnit = 'Dosage';
  static const doseUnitHint = 'e.g. 1 tablet, 2 capsules';
  static const doseTime = 'Time';
  static const foodTiming = 'When to take';
  static const repeatOptions = 'Repeat';
  static const repeatDaily = 'Daily';
  static const repeatWeekdays = 'Weekdays';
  static const repeatWeekends = 'Weekends';
  static const repeatCustom = 'Custom';
  static const saveDose = 'Save Dose';
  static const doseAdded = 'Dose added to schedule';
  static const noMedicinesYet = 'No medicines added yet';
  static const addFirstMedicine = 'Add your first medicine to get started';
  static const medicineDeleted = 'Medicine deleted';
  static const doseTaken = 'Dose marked as taken';
  static const doseSkipped = 'Dose skipped';
  static const doseSchedule = 'Dose Schedule';
  static const doseHistory = 'Dose History';
  static const taken = 'Taken';
  static const missed = 'Missed';
  static const upcoming = 'Upcoming';
  static const adherenceRate = 'Adherence Rate';
  static const streak = 'Streak';
  static const days = 'days';
  static const day = 'day';
  static const daily = 'Daily';
  static const weekly = 'Weekly';
  static const monthly = 'Monthly';
  static const custom = 'Custom';
  static const tablet = 'Tablet';
  static const capsule = 'Capsule';
  static const liquid = 'Liquid';
  static const injection = 'Injection';
  static const drops = 'Drops';
  static const patch = 'Patch';
  static const inhaler = 'Inhaler';
  static const powder = 'Powder';

  // Medicines — filter chips
  static const filterAll           = 'All';
  static const filterActive        = 'Active';
  static const filterLowStock      = 'Low Stock';
  static const filterPrn           = 'PRN';
  static const scopeAll            = 'All medicines';
  static const scopeMine           = 'Just mine';
  static const scopeShared         = 'Shared (I manage)';
  static const scopeAssigned       = 'Added by caretaker';

  // Medicines — status / labels
  static const activeStatus        = 'Active';
  static const lowStockStatus      = '⚠ Low Stock';
  static const prnLabel            = 'PRN';
  static const prnNote             = 'Take as needed';
  static const noScheduleSet       = 'No schedule set yet';
  static const noMedicinesInView   = 'No medicines in this view';

  // Medicines — detail drawer
  static const overviewTab         = 'Overview';
  static const scheduleTab         = 'Schedule';
  static const stockTab            = 'Stock';
  static const infoTab             = 'Info';
  static const primaryUseLabel     = 'PRIMARY USE';
  static const scheduleLabel       = 'SCHEDULE';
  static const adherenceLabel      = 'ADHERENCE';
  static const instructionsLabel   = 'INSTRUCTIONS';
  static const fullScheduleLabel   = 'FULL SCHEDULE';
  static const stockHistoryLabel   = 'STOCK HISTORY';
  static const addStock            = 'Add Stock';
  static const unitsRemaining      = 'units remaining';
  static const removeMedicineTitle = 'Remove Medicine';
  static const removeMedicineDesc  = 'This will remove the medicine and all its schedules. This cannot be undone.';

  // Medicines — add flow
  static const addMedicineStep1   = 'Find';
  static const addMedicineStep2   = 'Who for?';
  static const addMedicineStep3   = 'Schedule';
  static const addMedicineStep4   = 'Stock';
  static const searchMedicines    = 'Search medicines…';
  static const resultsLabel       = 'RESULTS';
  static const popularLabel       = 'POPULAR MEDICINES';
  static const noMatchesLabel     = 'NO MATCHES';
  static const cantFindIt         = "Can't find it? Request to add →";
  static const requestMedicine    = 'Request a medicine';
  static const requestDesc        = 'Tell us the medicine name and any details. Our team will review and add it within 24 hours.';
  static const medicineNameLabel  = 'Medicine name';
  static const detailsLabel       = 'Details (optional)';
  static const submitRequest      = 'Submit Request';
  static const requestSubmitted   = 'Request submitted! We\'ll review and add it within 24 hours.';

  // Medicines — who for
  static const whoForYou          = 'For yourself';
  static const whoForYouDesc      = 'Track this medicine in your personal log.';
  static const whoForPatient      = 'For a patient';
  static const whoForPatientDesc  = 'Add to a linked patient\'s profile.';
  static const whoShared          = 'Shared bottle';
  static const whoSharedDesc      = 'One bottle, deducted for multiple people.';

  // Medicines — schedule
  static const onceDaily          = 'Once daily';
  static const twiceDaily         = 'Twice daily';
  static const threeDaily         = '3× daily';
  static const fourDaily          = '4× daily';
  static const asNeeded           = 'As needed (PRN)';
  static const doseAmount         = 'Dose amount';
  static const doseAmountHint     = 'e.g. 1 tablet';
  static const foodRelation       = 'Food relation';
  static const scheduleOptional   = 'You can set up a schedule later from the medicine detail.';

  // Medicines — stock
  static const initialStockQty    = 'Initial quantity';
  static const stockQtyHint       = 'e.g. 30';
  static const purchaseDate       = 'Purchase date';
  static const expiryDate         = 'Expiry date';
  static const stockOptional      = 'Stock tracking is optional. You can add it later.';
  static const quantityLabel      = 'Quantity';
  static const expiryLabel        = 'Expiry';
  static const addStockTitle      = 'Add Stock';

  // Medicines — info tab
  static const infoDisclaimer     = 'This information is for educational purposes only. Always follow your doctor\'s instructions.';
  static const markTaken          = '✓ Mark Taken';
  static const restock            = '+ Restock';

  // ─── Vitals ─────────────────────────────────────────────────────────────────
  static const vitals = 'Vitals';
  static const myVitals = 'My Vitals';
  static const vitalsSubtitle = 'Track your health readings over time';
  static const rangeToday = 'Today';
  static const range7Days = '7 days';
  static const range30Days = '30 days';
  static const addVital = 'Add Vital';
  static const logReading        = 'Log Reading';
  static const recentReadings    = 'Recent Readings';
  static const noReadingsYet     = 'No readings yet';
  static const noReadingsInRange = 'No readings in this range';
  static const last7Days         = 'Last 7 days';
  static const last30Days        = 'Last 30 days';
  static const trends            = 'Trends';
  static const highRisk          = 'High Risk';
  static const warningStatus     = 'Warning';
  static const latestReading     = 'Latest Reading';
  static const normalRange       = 'Normal range';
  static const measuredAt        = 'Measured at';
  static const noVitalsConfigured = 'No vital types configured yet. The admin will set these up.';
  static const noVitalsConfiguredTitle = 'No vitals to track yet';
  static const severityCritical = 'Critical';
  static const severityHigh = 'High';
  static const severityLow = 'Low';
  static const bloodPressure = 'Blood Pressure';
  static const heartRate = 'Heart Rate';
  static const bloodSugar = 'Blood Sugar';
  static const oxygenLevel = 'Oxygen Level';
  static const temperature = 'Temperature';
  static const weight = 'Weight';
  static const height = 'Height';
  static const bmi = 'BMI';
  static const noVitalsYet = 'No vitals recorded yet';
  static const recordFirstVital = 'Record your first vital sign';
  static const systolic = 'Systolic';
  static const diastolic = 'Diastolic';
  static const bpm = 'BPM';
  static const mmHg = 'mmHg';
  static const mgDl = 'mg/dL';
  static const percent = '%';
  static const celsius = '°C';
  static const fahrenheit = '°F';
  static const kg = 'kg';
  static const lbs = 'lbs';
  static const cm = 'cm';
  static const normal = 'Normal';
  static const high = 'High';
  static const low = 'Low';
  static const critical = 'Critical';
  static const vitalHistory = 'Vital History';
  static const vitalTrend = 'Vital Trend';

  // ─── Schedule ───────────────────────────────────────────────────────────────
  static const schedule = 'Schedule';
  static const mySchedule = 'My Schedule';
  static const addAppointment = 'Add Appointment';
  static const editAppointment = 'Edit Appointment';
  static const appointmentWith = 'Appointment with';
  static const appointmentDate = 'Appointment Date';
  static const appointmentTime = 'Appointment Time';
  static const notes = 'Notes';
  static const location = 'Location';
  static const doctor = 'Doctor';
  static const noAppointmentsYet = 'No appointments scheduled';
  static const scheduleFirstAppointment = 'Schedule your first appointment';
  static const today = 'Today';
  static const tomorrow = 'Tomorrow';
  static const yesterday = 'Yesterday';
  static const thisWeek = 'This Week';
  static const thisMonth = 'This Month';
  static const upcoming2 = 'Upcoming';
  static const past = 'Past';
  static const cancelled = 'Cancelled';
  static const confirmed = 'Confirmed';
  static const pending = 'Pending';

  // ─── Professionals ──────────────────────────────────────────────────────────
  static const professionals = 'Professionals';
  static const browseProfessionals = 'Browse Professionals';
  static const myConnections = 'My Connections';
  static const incomingRequests = 'Incoming Requests';
  static const sentRequests = 'Sent Requests';
  static const connect = 'Connect';
  static const connected = 'Connected';
  static const disconnect = 'Disconnect';
  static const message = 'Message';
  static const viewProfile = 'View Profile';
  static const sendRequest = 'Send Request';
  static const acceptRequest = 'Accept';
  static const declineRequest = 'Decline';
  static const cancelRequest = 'Cancel Request';
  static const requestSent = 'Request sent';
  static const requestAccepted = 'Request accepted';
  static const requestDeclined = 'Request declined';
  static const noProfessionalsFound = 'No professionals found';
  static const tryDifferentSearch = 'Try a different category or search term';
  static const noConnectionsYet = 'No connections yet';
  static const noRequestsYet = 'No requests yet';
  static const perHour = 'Per Hour';
  static const perDay = 'Per Day';
  static const perMonth = 'Per Month';
  static const from = 'from';
  static const verified = 'Verified';
  static const pendingVerification = 'Pending Verification';
  static const experience = 'experience';
  static const certifications = 'Certifications';
  static const serviceAreas = 'Service Areas';
  static const ratings = 'Ratings';
  static const reviews = 'Reviews';
  static const writeReview = 'Write a Review';

  // ─── Professional Profile ───────────────────────────────────────────────────
  static const myProfessionalProfile = 'My Professional Profile';
  static const becomeProfessional = 'Become a Professional';
  static const editProfessionalProfile = 'Edit Professional Profile';
  static const saveChanges = 'Save Changes';
  static const earnMoney = 'Earn money doing what you love';
  static const createProfessionalProfile = 'Create Professional Profile';
  static const editProfile = 'Edit Profile';
  static const displayName = 'Display Name';
  static const bio = 'Bio';
  static const category = 'Category';
  static const hourlyRate = 'Hourly Rate';
  static const dailyRate = 'Daily Rate';
  static const monthlyRate = 'Monthly Rate';
  static const connectionRates = 'Connection Rates';
  static const connectionRatesSubtitle = 'Set rates for different connection durations';
  static const currency = 'Currency';
  static const address = 'Address';
  static const profileSaved = 'Profile saved';
  static const becomePro = 'Become a Pro';
  static const myProProfile = 'My Pro Profile';

  // ─── Messages / Chat ────────────────────────────────────────────────────────
  static const messages = 'Messages';
  static const typeMessage = 'Type a message…';
  static const send2 = 'Send';
  static const noMessages = 'No messages yet';
  static const startConversation = 'Start the conversation';
  static const online = 'Online';
  static const offline = 'Offline';
  static const seen = 'Seen';
  static const delivered = 'Delivered';
  static const attachFile = 'Attach File';
  static const noConversations = 'No conversations yet';

  // ─── Notifications ──────────────────────────────────────────────────────────
  static const notifications = 'Notifications';
  static const noNotifications = 'No notifications yet';
  static const markAllRead = 'Mark all as read';
  static const medicineReminder = 'Medicine Reminder';
  static const timeToTake = 'Time to take';
  static const alarmTitle = 'Medicine Alarm';

  // ─── Profile ────────────────────────────────────────────────────────────────
  static const profile = 'Profile';
  static const myProfile = 'My Profile';
  static const personalInfo = 'Personal Information';
  static const name = 'Name';
  static const email = 'Email';
  static const phone = 'Phone';
  static const dateOfBirth = 'Date of Birth';
  static const gender = 'Gender';
  static const male = 'Male';
  static const female = 'Female';
  static const other = 'Other';
  static const profileUpdated = 'Profile updated';
  static const profileUpdatedDesc = 'Your professional profile has been updated successfully.';
  static const changePhoto = 'Change Photo';
  static const takePhoto = 'Take Photo';
  static const chooseFromGallery = 'Choose from Gallery';
  static const settings = 'Settings';
  static const helpSupport = 'Help & Support';
  static const aboutApp = 'About App';
  static const version = 'Version';

  // ─── Patients / Caretakers ──────────────────────────────────────────────────
  static const patients = 'Patients';
  static const myPatients = 'My Patients';
  static const addPatient = 'Add Patient';
  static const caretakers = 'Caretakers';
  static const myCaretakers = 'My Caretakers';
  static const addCaretaker = 'Add Caretaker';
  static const noPatients = 'No patients yet';
  static const noCaretakers = 'No caretakers yet';
  static const relationship = 'Relationship';
  static const addRelationship = 'Add Relationship';

  // ─── Community ──────────────────────────────────────────────────────────────
  static const community = 'Community';
  static const posts = 'Posts';
  static const createPost = 'Create Post';
  static const noPosts = 'No posts yet';
  static const like = 'Like';
  static const likes = 'Likes';
  static const comment = 'Comment';
  static const comments = 'Comments';
  static const reply = 'Reply';
  static const reportPost = 'Report Post';
  static const whatsOnYourMind = "What's on your mind?";

  // ─── Alerts ─────────────────────────────────────────────────────────────────
  static const alerts = 'Alerts';
  static const myAlerts = 'My Alerts';
  static const addAlert = 'Add Alert';
  static const noAlerts = 'No alerts configured';
  static const alertType = 'Alert Type';
  static const threshold = 'Threshold';
  static const alertEnabled = 'Alert enabled';
  static const alertDisabled = 'Alert disabled';

  // ─── Insights ───────────────────────────────────────────────────────────────
  static const insights = 'Insights';
  static const healthInsights = 'Health Insights';
  static const noInsights = 'No insights yet';
  static const weeklyReport = 'Weekly Report';
  static const monthlyReport = 'Monthly Report';

  // ─── Reports ────────────────────────────────────────────────────────────────
  static const reports = 'Reports';
  static const generateReport = 'Generate Report';
  static const downloadReport = 'Download Report';
  static const noReports = 'No reports yet';
  static const noReportsUploaded = 'No reports yet — upload your first one.';
  static const noReportsFilter = 'No reports match your filter.';
  static const reportGenerated = 'Report generated';
  static const uploadReport = 'Upload Report';
  static const deleteReport = 'Delete Report';
  static const deleteReportConfirm = 'Delete this report? This cannot be undone.';
  static const reportDeleted = 'Report deleted';
  static const reportUploaded = 'Report uploaded';
  static const searchReports = 'Search reports…';
  static const reportTitle = 'Title';
  static const reportDate = 'Report Date';
  static const reportTags = 'Tags';
  static const reportTagsHint = 'Lab, Blood, Routine';
  static const reportDescription = 'Description';
  static const reportDescHint = 'Optional notes about this report';
  static const reportTitleRequired = 'Title is required';
  static const uploading = 'Uploading…';
  static const myReports = 'My Reports';
  static const selectReportToPreview = 'Tap a report to view details';

  // ─── Notes ──────────────────────────────────────────────────────────────────
  static const myNotes = 'My Notes';
  static const addNote = 'Add Note';
  static const editNote = 'Edit Note';
  static const noteTitle = 'Title';
  static const noteContent = 'Content';
  static const noNotes = 'No notes yet';
  static const noteDeleted = 'Note deleted';
  static const noteSaved = 'Note saved';

  // ─── Emergency ──────────────────────────────────────────────────────────────
  static const emergency = 'Emergency';
  static const callEmergency = 'Call Emergency';
  static const emergencyContacts = 'Emergency Contacts';
  static const addEmergencyContact = 'Add Emergency Contact';
  static const sos = 'SOS';
  static const callNow = 'Call Now';

  // ─── Support ────────────────────────────────────────────────────────────────
  static const support = 'Support';
  static const helpCenter = 'Help Center';
  static const contactUs = 'Contact Us';
  static const faq = 'FAQ';
  static const reportBug = 'Report a Bug';
  static const feedbackTitle = 'Send Feedback';

  // ─── Errors & States ────────────────────────────────────────────────────────
  static const somethingWentWrong = 'Something went wrong';
  static const tryAgainLater = 'Please try again later';
  static const noInternetConnection = 'No internet connection';
  static const offlineMode = 'Offline Mode';
  static const offlineDesc = "You're offline. Changes will sync when you reconnect.";
  static const networkError = 'Network error';
  static const serverError = 'Server error';
  static const unauthorised = 'Session expired. Please log in again.';
  static const notFound = 'Not found';
  static const emptyState = 'Nothing here yet';
  static const pullToRefresh = 'Pull to refresh';
  static const nothingFound = 'Nothing found';

  // ─── Validation ─────────────────────────────────────────────────────────────
  static const fieldRequired = 'This field is required';
  static const invalidEmail = 'Please enter a valid email address';
  static const invalidPhone = 'Please enter a valid phone number';
  static const invalidOtp = 'Please enter a valid 6-digit OTP';
  static const passwordTooShort = 'Password must be at least 8 characters';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const nameTooShort = 'Name must be at least 2 characters';
  static const valueTooLow = 'Value is too low';
  static const valueTooHigh = 'Value is too high';
  static const invalidDate = 'Please enter a valid date';
  static const selectAtLeastOne = 'Please select at least one option';

  // ─── Notifications ──────────────────────────────────────────────────────────
  static const notifNew             = 'New';
  static const notifEarlier         = 'Earlier';
  static const allCaughtUp          = 'All caught up';
  static const justNow              = 'just now';

  // ─── Messages ───────────────────────────────────────────────────────────────
  static const searchConversations  = 'Search conversations…';
  static const noMessagesYetSayHi   = 'No messages yet. Say hello!';
  static const selectConversation   = 'Select a conversation';
  static const yesterdayLabel       = 'Yesterday';

  // ─── Emergency ──────────────────────────────────────────────────────────────
  static const sosTitle             = 'Emergency SOS';
  static const healthProfileTitle   = 'Health Profile';
  static const allergiesLabel       = 'Allergies';
  static const conditionsLabel      = 'Conditions';
  static const criticalMedsLabel    = 'Critical Medications';
  static const sosIdleHint          = 'Press and hold to send SOS to your emergency contacts';
  static const sosSendingIn         = 'Sending SOS in';
  static const sosActivated         = 'SOS Activated';
  static const sosContactsNotified  = 'Your emergency contacts have been notified.';
  static const noEmergencyProfile   = 'No profile set up. Add your medical info in Settings.';
  static const noEmergencyContacts  = 'No emergency contacts set up yet.';
  static const sosHoldHint          = 'Hold for 2 seconds to trigger SOS';
  static const sosSent              = 'SOS Sent — help is on the way';
  static const sosStopAlarm         = 'STOP ALARM';
  static const sosCancelFalseAlarm  = 'Cancel SOS · False alarm';
  static const sosCancelled         = 'SOS cancelled — contacts informed';
  static const sosWhoWasNotified    = 'Who was notified';
  static const sosSmsSent           = 'SMS sent';
  static const sosSmsFailed         = 'SMS failed';
  static const sosPushSent          = 'App alert sent';
  static const sosNeedContact       = 'Add at least one emergency contact to arm SOS.';
  static const editEmergencyContact = 'Edit emergency contact';
  static const relationshipLabel    = 'Relationship';
  static const priorityLabel        = 'Priority (lower = contacted first)';
  static const deleteContactTitle   = 'Delete contact?';
  static const deleteContactBody    = 'They will no longer be notified when you trigger SOS.';
  static const emergencySubtitle2   = 'SOS · Critical health info · Emergency contacts';
  static const callDirect           = 'Call emergency services directly if needed.';

  // ─── Professionals — connect / connections flow ─────────────────────────────
  static const selectPlanTitle         = 'Choose a Plan';
  static const connectNow              = 'Connect Now';
  static const hourlyPlan              = 'Hourly';
  static const dailyPlan               = 'Daily';
  static const monthlyPlan             = 'Monthly';
  static const asPatient               = 'As Patient';
  static const asProfessionalTab       = 'As Professional';
  static const openChat                = 'Open Chat';
  static const leaveRating             = 'Leave a rating';
  static const connectionCancelledMsg  = 'Connection cancelled';
  static const connectionRequestSent   = 'Connection request sent!';
  static const cancelConnectionConfirm = 'Cancel this connection?';
  static const searchProfessionals     = 'Search professionals…';
  static const activeConnections       = 'Active';
  static const pastConnections         = 'Past';
  static const overallRatingLabel      = 'Overall';
  static const communicationRating     = 'Communication';
  static const expertiseRating         = 'Expertise';
  static const availabilityRating      = 'Availability';
  static const kmRadius                = 'km radius';
  static const expiresOn               = 'Expires';
  static const nextBillingOn           = 'Next billing';
  static const connectionStarted       = 'Started';
  static const noProfessionalsInCategory = 'No professionals in this category';
  static const ratedLabel              = 'rated';
  static const rateProfessional        = 'Rate Professional';
  static const reportMessage           = 'Report Message';
  static const shareExperienceHint     = 'Share your experience (optional)…';
  static const reportReasonHint        = 'e.g. Inappropriate content, harassment…';
  static const reasonOptional          = 'Reason (optional)';
  static const submitRating            = 'Submit Rating';
  static const submitReport            = 'Submit Report';
  static const ratingSubmitted         = 'Rating submitted!';
  static const messageReported         = 'Message reported. We will review it.';
  static const connectionAccepted      = 'Connection accepted!';
  static const connectionDeclined      = 'Declined';
  static const searchConnections       = 'Search connections…';

  // ─── Notes ──────────────────────────────────────────────────────────────────
  static const searchNotes         = 'Search notes…';
  static const untitledNote        = 'Untitled Note';
  static const noteColourLabel     = 'Note colour';
  static const tapToEdit           = 'Tap to edit…';
  static const deleteNoteConfirm   = 'Delete this note? This cannot be undone.';

  // ─── Insights ───────────────────────────────────────────────────────────────
  static const todaysAdherence     = "Today's Adherence";
  static const activeMedicinesLabel = 'Active Medicines';
  static const dosesTakenToday     = 'Doses Taken Today';
  static const adherenceCalendar   = 'Adherence Calendar';
  static const perMedicineToday    = 'Per-Medicine (Today)';
  static const missPatternToday    = 'Miss Pattern (Today)';
  static const onTrack             = 'On track ✓';
  static const needsAttention      = 'Needs attention';
  static const noScheduledDoses    = 'No doses scheduled today';
  static const perfectLabel        = 'Perfect (≥90%)';
  static const goodLabel           = 'Good (≥60%)';
  static const partialLabel        = 'Partial';
  static const noDataYet           = 'No data yet';
  static const ofScheduled         = 'of scheduled';
  static const allWellStocked      = 'All well stocked';
  static const reorderNeeded       = 'Reorder needed';
  static const totalPrescribed     = 'Total prescribed';

  // ─── Alerts ─────────────────────────────────────────────────────────────────
  static const criticalSeverity    = 'Critical';
  static const warningSeverity     = 'Warning';
  static const infoSeverity        = 'Info';
  static const viewDetails         = 'View Details';
  static const noActiveAlerts      = 'No active alerts';

  // ─── Settings ───────────────────────────────────────────────────────────────
  static const account              = 'Account';
  static const accountTitle          = 'ACCOUNT';
  static const preferencesTitle      = 'PREFERENCES';
  static const securityTitle         = 'SECURITY';
  static const supportTitle          = 'SUPPORT';
  static const settingsSubtitle      = 'Manage your account and app preferences';
  static const healthProfile         = 'Health Profile';
  static const subscription          = 'Subscription';
  static const appearance            = 'Appearance';
  static const professionalDashboard = 'Professional Dashboard';
  static const manageProfessionalProfile = 'Manage Professional Profile';
  static const reminderNotifications = 'Reminder & Notifications';
  static const passwordLogin         = 'Password & Login';
  static const aboutCareDose         = 'About CareDose';
  static const security             = 'Security';
  static const signOutConfirm       = 'Are you sure you want to sign out?';
  static const deleteAccount        = 'Delete Account';
  static const deleteAccountDesc    = 'Permanently delete your account and all data';
  static const deleteAccountConfirm = 'This is permanent and cannot be undone. All your data will be erased.';
  static const darkMode             = 'Dark Mode';
  static const medicineRemindersSetting = 'Medicine Reminders';
  static const vitalAlerts          = 'Vital Alerts';
  static const connectionAlerts     = 'Connection Alerts';
  static const biometricAuth        = 'Biometric Authentication';
  static const autoLock             = 'Auto-lock';
  static const dataExport           = 'Export My Data';
  static const clearCache           = 'Clear Cache';
  static const language             = 'Language';
  static const cacheCleared         = 'Cache cleared';
  static const comingSoon           = 'Coming soon';
  static const subscriptionPlan     = 'Subscription Plan';
  static const freePlan             = 'Free Plan';
  static const premiumPlan          = 'Premium Plan';

  // ─── Navigation tabs ────────────────────────────────────────────────────────
  static const tabHome = 'Home';
  static const tabMedicines = 'Medicines';
  static const tabVitals = 'Vitals';
  static const tabProfessionals = 'Pros';
  static const tabSettings = 'Settings';
  static const tabProfile = 'Profile';
  static const tabCommunity = 'Community';
  static const tabSchedule = 'Schedule';
  static const tabInsights = 'Insights';
  static const tabMessages = 'Messages';
  static const tabAlerts = 'Alerts';

  // ─── Voice search ────────────────────────────────────────────────────────────
  static const listeningHint       = 'Listening…';
  static const voiceSearchTooltip  = 'Voice search';
  static const micPermissionDenied = 'Microphone permission is required for voice search.';

  // ─── Reminders ───────────────────────────────────────────────────────────────
  static const reminders            = 'Reminders';
  static const addReminder          = 'Add Reminder';
  static const reminderTitle        = 'Reminder Title';
  static const reminderTitleHint    = 'e.g. Take insulin';
  static const reminderRepeat       = 'Repeat';
  static const reminderType         = 'Type';
  static const reminderTypeMed      = 'Medicine';
  static const reminderTypeAppt     = 'Appointment';
  static const reminderTypeVital    = 'Vital Check';
  static const reminderTypeOther    = 'Other';
  static const reminderEnabled      = 'Reminder active';
  static const noReminders          = 'No reminders set';
  static const noRemindersDesc      = 'Tap + to schedule a reminder';
  static const reminderSaved        = 'Reminder saved';
  static const reminderDeleted      = 'Reminder deleted';
  static const deleteReminder       = 'Delete Reminder';
  static const deleteReminderConfirm = 'Delete this reminder?';

  // ─── Prescriptions ───────────────────────────────────────────────────────────
  static const prescriptions        = 'Prescriptions';
  static const addPrescription      = 'Add Prescription';
  static const noPrescriptions      = 'No prescriptions saved';
  static const noPrescriptionsDesc  = 'Add prescriptions issued by your doctor';
  static const prescribedBy        = 'Prescribed by';
  static const prescribedOn        = 'Prescribed on';
  static const prescriptionExpiry  = 'Valid until';
  static const prescriptionMeds    = 'Medicines';
  static const prescriptionNotes   = 'Notes';
  static const activePrescription  = 'Active';
  static const expiredPrescription = 'Expired';
  static const prescriptionDeleted = 'Prescription deleted';
  static const deletePrescription  = 'Delete Prescription';
  static const deletePrescriptionConfirm = 'Delete this prescription?';

  // ─── Patients ────────────────────────────────────────────────────────────────
  static const noPatientsDesc       = 'Patients who grant you access will appear here';
  static const patientSince         = 'Patient since';
  static const viewPatientHistory   = 'View History';
  static const accessLevel          = 'Access Level';
  static const fullAccess           = 'Full Access';
  static const readOnly             = 'Read Only';
  static const removePatient        = 'Remove Patient';
  static const removePatientConfirm = 'Remove this patient? They can re-invite you later.';
  static const patientRemoved       = 'Patient removed';

  // ─── Caretakers ──────────────────────────────────────────────────────────────
  static const noCaretakersDesc     = 'Invite someone to help monitor your health';
  static const caretakerSince       = 'Caretaker since';
  static const removeCaretaker      = 'Remove Caretaker';
  static const removeCaretakerConfirm = 'Remove this caretaker? They will lose access to your data.';
  static const caretakerRemoved     = 'Caretaker removed';
  static const inviteByEmail        = 'Invite by email';
  static const emailAddress         = 'Email Address';
  static const sendInvite           = 'Send Invite';
  static const inviteSent           = 'Invite sent!';
  static const permissionsLabel     = 'Permissions';
  static const permViewVitals       = 'View Vitals';
  static const permViewMeds         = 'View Medicines';
  static const permViewReports      = 'View Reports';
  static const permViewSchedule     = 'View Schedule';

  // ─── Support ─────────────────────────────────────────────────────────────────
  static const contactSupport       = 'Contact Support';
  static const submitTicket         = 'Submit a Ticket';
  static const ticketSubject        = 'Subject';
  static const ticketSubjectHint    = 'Briefly describe your issue';
  static const ticketMessage        = 'Message';
  static const ticketMessageHint    = 'Describe the issue in detail…';
  static const ticketCategory       = 'Category';
  static const ticketSubmitted      = 'Ticket submitted! We\'ll respond within 24h.';
  static const submitTicketBtn      = 'Send Message';
  static const feedbackHint         = 'Tell us what you think…';
  static const feedbackSubmitted    = 'Thanks for your feedback!';
  static const termsOfService       = 'Terms of Service';
  static const appVersion           = 'App Version';
  static const rateApp              = 'Rate MediForze';
  static const followUs             = 'Follow Us';
  static const catBug               = 'Bug Report';
  static const catFeature           = 'Feature Request';
  static const catAccount           = 'Account Issue';
  static const catOtherTicket       = 'Other';

  // ─── Professional Profile ─────────────────────────────────────────────────────
  static const professionalProfile  = 'Professional Profile';
  static const proHubTitle          = 'My Professional Hub';
  static const proStatus            = 'Status';
  static const proVerified          = 'Verified';
  static const proPending           = 'Pending Review';
  static const proNotApplied        = 'Not Applied';
  static const proSpecialty         = 'Specialty';
  static const proLicense           = 'License Number';
  static const proClinic            = 'Clinic / Hospital';
  static const proExperience        = 'Years of Experience';
  static const proClients           = 'Active Clients';
  static const proRating            = 'Rating';
  static const proEditProfile       = 'Edit Professional Profile';
  static const proAvailability      = 'Availability';
  static const proConsultationFee   = 'Consultation Fee';
  static const proApplyNow          = 'Apply Now';
  static const proApplyDesc         = 'Get verified and start helping patients';

  // ─── Settings — extras ───────────────────────────────────────────────────────
  static const upgradeNow           = 'Upgrade Now';
  static const currentPlan          = 'Current Plan';
  static const exportMyData         = 'Export My Data';
  static const exportConfirmTitle   = 'Export Health Data';
  static const exportConfirmDesc    = 'We\'ll prepare a downloadable archive of all your health records and send it to your registered email.';
  static const exportStarted        = 'Export started — check your email shortly.';
  static const exportAsPdf          = 'Export as PDF';
  static const exportAsJson         = 'Export as JSON (raw)';
  static const selectLanguage       = 'Select Language';
  static const languageSaved        = 'Language updated';
  static const autoLockDuration     = 'Auto-lock after';
  static const biometricDesc        = 'Use Face ID or fingerprint to unlock the app';
  static const doseCelebration      = 'Great job! Keep it up!';

  // ─── Celebration ─────────────────────────────────────────────────────────────
  static const doseMarkedTaken      = 'Dose taken';

  // ─── Become Professional Wizard ──────────────────────────────────────────────
  static const stepProfile          = 'Profile';
  static const stepDocuments        = 'Documents';
  static const stepAgreement        = 'Agreement';
  static const basePrice            = 'Base Price';
  static const displayNameHint      = 'Your professional display name';
  static const bioHint              = 'Tell patients about your expertise…';
  static const addressHint          = 'Your clinic or practice address';
  static const basePriceHint        = 'e.g. 500';
  static const experienceHint       = 'e.g. 5';
  static const selectCategories     = 'Select Specialties';
  static const tapToSelect          = 'Tap to select';
  static const addCertification     = 'Add Certification';
  static const certificationHint    = 'e.g. MD, MBBS, PhD';
  static const aadhaarNumber        = 'Aadhaar Number';
  static const aadhaarHint          = 'XXXX XXXX XXXX';
  static const panNumber            = 'PAN Number';
  static const panHint              = 'ABCDE1234F';
  static const panFront             = 'PAN Front';
  static const panBack              = 'PAN Back';
  static const aadhaarFront         = 'Aadhaar Front';
  static const aadhaarBack          = 'Aadhaar Back';
  static const secureDataBanner     = 'Your documents are encrypted and used for verification only';
  static const agreementTitle       = 'Professional Service Agreement';
  static const agreementCheckbox    = 'I have read and agree to the Professional Service Agreement. I understand that I am solely responsible for all services I provide to patients.';
  static const agreementPreamble    = 'By registering as a professional on our platform, you agree to the following terms and conditions:';
  static const agreementFooter      = 'This agreement becomes effective on the date of your approval and remains in effect until terminated by either party.';
  static const applicationSubmitted = 'Application Submitted';
  static const applicationPendingDesc =
      'Your application is under review. We\'ll notify you within 2–3 business days.';
  static const noCertificationsYet      = 'No certifications added yet';
  static const maxCertificationsReached = 'Maximum 10 certifications allowed';
  static const categoryRequired     = 'Please select at least one specialty';
  static const invalidAadhaar       = 'Please enter a valid 12-digit Aadhaar number';
  static const invalidPan           = 'PAN must be in format ABCDE1234F';
  static const allImagesRequired    = 'Please upload all 4 identity documents';
  static const pleaseAgreeToTerms   = 'Please agree to the Professional Service Agreement';
}
