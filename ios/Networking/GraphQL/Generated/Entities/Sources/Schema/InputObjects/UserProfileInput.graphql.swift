// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// All the fields are optional, if you dont pass the field it is not updated
public struct UserProfileInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    gender: GraphQLNullable<GraphQLEnum<Gender>> = nil,
    firstName: GraphQLNullable<String> = nil,
    lastName: GraphQLNullable<String> = nil,
    email: GraphQLNullable<String> = nil,
    phoneNumber: GraphQLNullable<String> = nil,
    profession: GraphQLNullable<GraphQLEnum<Profession>> = nil,
    country: GraphQLNullable<ID> = nil,
    currentClerkship: GraphQLNullable<EncodedId> = nil,
    university: GraphQLNullable<UniversityInput> = nil,
    clinic: GraphQLNullable<ClinicInput> = nil,
    occupation: GraphQLNullable<OccupationInput> = nil,
    specialityId: GraphQLNullable<ID> = nil,
    graduationYear: GraphQLNullable<Int> = nil,
    mode: GraphQLNullable<GraphQLEnum<Stage>> = nil,
    semester: GraphQLNullable<Int> = nil,
    profileUseCase: GraphQLNullable<ProfileUseCaseInput> = nil,
    nextExam: GraphQLNullable<ID> = nil,
    nextExamDate: GraphQLNullable<Date> = nil,
    targetScore: GraphQLNullable<Int> = nil,
    studyObjectiveId: GraphQLNullable<EncodedId> = nil,
    sendNewsletter: GraphQLNullable<Bool> = nil,
    timeAccommodation: GraphQLNullable<GraphQLEnum<TimeAccommodationMultiplier>> = nil,
    isLecturer: GraphQLNullable<Bool> = nil,
    isBetaTester: GraphQLNullable<Bool> = nil,
    canSeeBrandNames: GraphQLNullable<Bool> = nil,
    hasConfirmedHealthCareProfession: GraphQLNullable<Bool> = nil,
    marketingSource: GraphQLNullable<MarketingSourceInput> = nil,
    doesEquivalenceAssessment: GraphQLNullable<Bool> = nil,
    isInSpecialityTraining: GraphQLNullable<Bool> = nil,
    isSpecialistNurse: GraphQLNullable<Bool> = nil,
    hasLeadingPosition: GraphQLNullable<Bool> = nil,
    nurseWorkplaceType: GraphQLNullable<String> = nil,
    workplaceText: GraphQLNullable<String> = nil,
    hasConfirmedPhysicianDisclaimer: GraphQLNullable<Bool> = nil,
    cmeUserNumber: GraphQLNullable<CmeUserNumberInput> = nil,
    residencyProgram: GraphQLNullable<ResidencyProgramInput> = nil,
    termsAndConditionsId: GraphQLNullable<EncodedId> = nil
  ) {
    __data = InputDict([
      "gender": gender,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
      "profession": profession,
      "country": country,
      "currentClerkship": currentClerkship,
      "university": university,
      "clinic": clinic,
      "occupation": occupation,
      "specialityId": specialityId,
      "graduationYear": graduationYear,
      "mode": mode,
      "semester": semester,
      "profileUseCase": profileUseCase,
      "nextExam": nextExam,
      "nextExamDate": nextExamDate,
      "targetScore": targetScore,
      "studyObjectiveId": studyObjectiveId,
      "sendNewsletter": sendNewsletter,
      "timeAccommodation": timeAccommodation,
      "isLecturer": isLecturer,
      "isBetaTester": isBetaTester,
      "canSeeBrandNames": canSeeBrandNames,
      "hasConfirmedHealthCareProfession": hasConfirmedHealthCareProfession,
      "marketingSource": marketingSource,
      "doesEquivalenceAssessment": doesEquivalenceAssessment,
      "isInSpecialityTraining": isInSpecialityTraining,
      "isSpecialistNurse": isSpecialistNurse,
      "hasLeadingPosition": hasLeadingPosition,
      "nurseWorkplaceType": nurseWorkplaceType,
      "workplaceText": workplaceText,
      "hasConfirmedPhysicianDisclaimer": hasConfirmedPhysicianDisclaimer,
      "cmeUserNumber": cmeUserNumber,
      "residencyProgram": residencyProgram,
      "termsAndConditionsId": termsAndConditionsId
    ])
  }

  /// Displayed as salutation
  public var gender: GraphQLNullable<GraphQLEnum<Gender>> {
    get { __data["gender"] }
    set { __data["gender"] = newValue }
  }

  public var firstName: GraphQLNullable<String> {
    get { __data["firstName"] }
    set { __data["firstName"] = newValue }
  }

  public var lastName: GraphQLNullable<String> {
    get { __data["lastName"] }
    set { __data["lastName"] = newValue }
  }

  public var email: GraphQLNullable<String> {
    get { __data["email"] }
    set { __data["email"] = newValue }
  }

  public var phoneNumber: GraphQLNullable<String> {
    get { __data["phoneNumber"] }
    set { __data["phoneNumber"] = newValue }
  }

  public var profession: GraphQLNullable<GraphQLEnum<Profession>> {
    get { __data["profession"] }
    set { __data["profession"] = newValue }
  }

  /// Country ID from countries endpoint
  public var country: GraphQLNullable<ID> {
    get { __data["country"] }
    set { __data["country"] = newValue }
  }

  /// the current clerkship of the user
  public var currentClerkship: GraphQLNullable<EncodedId> {
    get { __data["currentClerkship"] }
    set { __data["currentClerkship"] = newValue }
  }

  /// University - for students
  public var university: GraphQLNullable<UniversityInput> {
    get { __data["university"] }
    set { __data["university"] = newValue }
  }

  /// Clinic - for doctors
  public var clinic: GraphQLNullable<ClinicInput> {
    get { __data["clinic"] }
    set { __data["clinic"] = newValue }
  }

  /// Occupation - for doctors and others
  public var occupation: GraphQLNullable<OccupationInput> {
    get { __data["occupation"] }
    set { __data["occupation"] = newValue }
  }

  /// From speciality endpoint
  public var specialityId: GraphQLNullable<ID> {
    get { __data["specialityId"] }
    set { __data["specialityId"] = newValue }
  }

  /// The year you graduated or will graduate
  public var graduationYear: GraphQLNullable<Int> {
    get { __data["graduationYear"] }
    set { __data["graduationYear"] = newValue }
  }

  /// AMBOSS modus
  public var mode: GraphQLNullable<GraphQLEnum<Stage>> {
    get { __data["mode"] }
    set { __data["mode"] = newValue }
  }

  /// Semester number (depends on locale see query.semesters)
  public var semester: GraphQLNullable<Int> {
    get { __data["semester"] }
    set { __data["semester"] = newValue }
  }

  /// Use Case for using the platform (depends on locale and profession see query.profileUseCases)
  public var profileUseCase: GraphQLNullable<ProfileUseCaseInput> {
    get { __data["profileUseCase"] }
    set { __data["profileUseCase"] = newValue }
  }

  /// Id of userExam taxonomy
  public var nextExam: GraphQLNullable<ID> {
    get { __data["nextExam"] }
    set { __data["nextExam"] = newValue }
  }

  /// Next exam date in ISO format e.g. 2022-02-15T00:00:00+0000
  public var nextExamDate: GraphQLNullable<Date> {
    get { __data["nextExamDate"] }
    set { __data["nextExamDate"] = newValue }
  }

  /// Next exam target score
  public var targetScore: GraphQLNullable<Int> {
    get { __data["targetScore"] }
    set { __data["targetScore"] = newValue }
  }

  /// The selected study objective encoded id. Only available for US
  public var studyObjectiveId: GraphQLNullable<EncodedId> {
    get { __data["studyObjectiveId"] }
    set { __data["studyObjectiveId"] = newValue }
  }

  /// Agree to receive newsletter
  public var sendNewsletter: GraphQLNullable<Bool> {
    get { __data["sendNewsletter"] }
    set { __data["sendNewsletter"] = newValue }
  }

  /// Time Accommodation for qbank sessions
  public var timeAccommodation: GraphQLNullable<GraphQLEnum<TimeAccommodationMultiplier>> {
    get { __data["timeAccommodation"] }
    set { __data["timeAccommodation"] = newValue }
  }

  /// Set true if user is also a lecturer
  public var isLecturer: GraphQLNullable<Bool> {
    get { __data["isLecturer"] }
    set { __data["isLecturer"] = newValue }
  }

  /// Set true if user wants to access new beta features
  public var isBetaTester: GraphQLNullable<Bool> {
    get { __data["isBetaTester"] }
    set { __data["isBetaTester"] = newValue }
  }

  /// User confirms that they have legal permission to see brand names
  public var canSeeBrandNames: GraphQLNullable<Bool> {
    get { __data["canSeeBrandNames"] }
    set { __data["canSeeBrandNames"] = newValue }
  }

  /// User confirms to have a health care profession. This grants e.g. to see brand names
  public var hasConfirmedHealthCareProfession: GraphQLNullable<Bool> {
    get { __data["hasConfirmedHealthCareProfession"] }
    set { __data["hasConfirmedHealthCareProfession"] = newValue }
  }

  /// Specify where user knows amboss from
  public var marketingSource: GraphQLNullable<MarketingSourceInput> {
    get { __data["marketingSource"] }
    set { __data["marketingSource"] = newValue }
  }

  /// is this doctor currently doing a "Gleichwertigkeitsprüfung". defaults to false
  public var doesEquivalenceAssessment: GraphQLNullable<Bool> {
    get { __data["doesEquivalenceAssessment"] }
    set { __data["doesEquivalenceAssessment"] = newValue }
  }

  /// user (Nurse specific for now) is still in training. Used in DE only for now
  public var isInSpecialityTraining: GraphQLNullable<Bool> {
    get { __data["isInSpecialityTraining"] }
    set { __data["isInSpecialityTraining"] = newValue }
  }

  /// user (Nurse specific for now) is a Specialist nurse. Used in DE only for now
  public var isSpecialistNurse: GraphQLNullable<Bool> {
    get { __data["isSpecialistNurse"] }
    set { __data["isSpecialistNurse"] = newValue }
  }

  /// user (Nurse specific for now) has a leading position. Used in DE only for now
  public var hasLeadingPosition: GraphQLNullable<Bool> {
    get { __data["hasLeadingPosition"] }
    set { __data["hasLeadingPosition"] = newValue }
  }

  /// Practising nurse Work place type. Used in DE only for now
  public var nurseWorkplaceType: GraphQLNullable<String> {
    get { __data["nurseWorkplaceType"] }
    set { __data["nurseWorkplaceType"] = newValue }
  }

  /// Free text for users workplace (practice most of the time)
  public var workplaceText: GraphQLNullable<String> {
    get { __data["workplaceText"] }
    set { __data["workplaceText"] = newValue }
  }

  /// Does the Physician want to see advanced contents
  public var hasConfirmedPhysicianDisclaimer: GraphQLNullable<Bool> {
    get { __data["hasConfirmedPhysicianDisclaimer"] }
    set { __data["hasConfirmedPhysicianDisclaimer"] = newValue }
  }

  /// A user CME number for gaining CME credits
  public var cmeUserNumber: GraphQLNullable<CmeUserNumberInput> {
    get { __data["cmeUserNumber"] }
    set { __data["cmeUserNumber"] = newValue }
  }

  /// The user residency program
  public var residencyProgram: GraphQLNullable<ResidencyProgramInput> {
    get { __data["residencyProgram"] }
    set { __data["residencyProgram"] = newValue }
  }

  /// Terms and conditions version the user has accepted
  public var termsAndConditionsId: GraphQLNullable<EncodedId> {
    get { __data["termsAndConditionsId"] }
    set { __data["termsAndConditionsId"] = newValue }
  }
}
