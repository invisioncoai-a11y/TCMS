export interface Category {
  categoryID: number;
  categoryName: string;
  description?: string;
  createdAt?: string;
}

export interface Course {
  courseID: number;
  categoryID: number;
  categoryName?: string;
  courseName: string;
  description?: string;
  learningObjectives?: string;
  prerequisites?: string;
  price: number;
  duration: number;
  deliveryMode: string;
  isFeatured: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface Trainer {
  trainerID: number;
  fullName: string;
  specialization: string;
  qualifications?: string;
  profileDetails?: string;
  email: string;
  phoneNumber?: string;
  createdAt?: string;
}

export interface TrainerAssignedCourse {
  offeringID: number;
  courseID: number;
  courseName: string;
  price: number;
  startDate: string;
  endDate: string;
  scheduleDetails?: string;
  maxCapacity: number;
  availableSeats: number;
}

export interface CourseOffering {
  offeringID: number;
  courseID: number;
  courseName?: string;
  price: number;
  duration: number;
  deliveryMode?: string;
  categoryID: number;
  categoryName?: string;
  trainerID: number;
  trainerName?: string;
  trainerSpecialization?: string;
  trainerEmail?: string;
  startDate: string;
  endDate: string;
  scheduleDetails: string;
  maxCapacity: number;
  availableSeats: number;
  enrolledCount: number;
  seatStatus?: string;
  isUpcoming: number;
  createdAt?: string;
}

export interface Trainee {
  traineeID: number;
  fullName: string;
  email: string;
  phoneNumber: string;
  educationalBackground: string;
  createdAt?: string;
}

export interface Registration {
  registrationID: number;
  traineeID: number;
  traineeName?: string;
  traineeEmail?: string;
  traineePhone?: string;
  educationalBackground?: string;
  offeringID: number;
  courseID: number;
  courseName?: string;
  price: number;
  deliveryMode?: string;
  trainerID: number;
  trainerName?: string;
  startDate: string;
  endDate: string;
  scheduleDetails?: string;
  registrationDate: string;
  status: string;
  cancellationReason?: string;
  cancellationDate?: string;
  isCancellable: number;
  createdAt?: string;
}

export interface EnrollRequest {
  fullName: string;
  email: string;
  phoneNumber: string;
  educationalBackground: string;
  offeringID: number;
}

export interface CancelRequest {
  registrationID: number;
  reason: string;
}

export interface LoginResponse {
  token: string;
  adminID: number;
  username: string;
  fullName: string;
  email: string;
  expiresAt: string;
}

export interface DashboardKpis {
  totalCourses: number;
  totalOfferings: number;
  totalTrainers: number;
  totalTrainees: number;
  totalRegistrations: number;
  activeOfferings: number;
  totalRevenue: number;
}

export interface CategoryChart {
  categoryID: number;
  categoryName: string;
  registrationCount: number;
  courseCount: number;
}

export interface PopularCourse {
  courseID: number;
  courseName: string;
  categoryName?: string;
  price: number;
  duration: number;
  deliveryMode?: string;
  totalEnrollments: number;
  totalOfferings: number;
}
