import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import {
  Category,
  Course,
  Trainer,
  TrainerAssignedCourse,
  CourseOffering,
  Trainee,
  Registration,
  EnrollRequest,
  CancelRequest,
  DashboardKpis,
  CategoryChart,
  PopularCourse
} from '../models/models';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly baseUrl = 'http://localhost:5000/api';

  constructor(
    private http: HttpClient,
    private auth: AuthService
  ) {}

  private getAuthHeaders(): HttpHeaders {
    const token = this.auth.getToken();
    return new HttpHeaders({
      Authorization: token ? `Bearer ${token}` : ''
    });
  }

  // --- Categories ---
  getCategories(): Observable<Category[]> {
    return this.http.get<Category[]>(`${this.baseUrl}/categories`);
  }

  getCategory(id: number): Observable<Category> {
    return this.http.get<Category>(`${this.baseUrl}/categories/${id}`);
  }

  createCategory(category: Partial<Category>): Observable<any> {
    return this.http.post(`${this.baseUrl}/categories`, category, { headers: this.getAuthHeaders() });
  }

  updateCategory(id: number, category: Partial<Category>): Observable<any> {
    return this.http.put(`${this.baseUrl}/categories/${id}`, category, { headers: this.getAuthHeaders() });
  }

  deleteCategory(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/categories/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Courses ---
  getCourses(): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.baseUrl}/courses`);
  }

  getCourse(id: number): Observable<Course> {
    return this.http.get<Course>(`${this.baseUrl}/courses/${id}`);
  }

  getFeaturedCourses(): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.baseUrl}/courses/featured`);
  }

  searchCourses(params: {
    search?: string;
    categoryID?: number;
    minPrice?: number;
    maxPrice?: number;
    deliveryMode?: string;
    sortBy?: string;
  }): Observable<Course[]> {
    let httpParams = new HttpParams();
    if (params.search) httpParams = httpParams.set('search', params.search);
    if (params.categoryID) httpParams = httpParams.set('categoryID', params.categoryID.toString());
    if (params.minPrice != null) httpParams = httpParams.set('minPrice', params.minPrice.toString());
    if (params.maxPrice != null) httpParams = httpParams.set('maxPrice', params.maxPrice.toString());
    if (params.deliveryMode) httpParams = httpParams.set('deliveryMode', params.deliveryMode);
    if (params.sortBy) httpParams = httpParams.set('sortBy', params.sortBy);

    return this.http.get<Course[]>(`${this.baseUrl}/courses/search`, { params: httpParams });
  }

  createCourse(course: Partial<Course>): Observable<any> {
    return this.http.post(`${this.baseUrl}/courses`, course, { headers: this.getAuthHeaders() });
  }

  updateCourse(id: number, course: Partial<Course>): Observable<any> {
    return this.http.put(`${this.baseUrl}/courses/${id}`, course, { headers: this.getAuthHeaders() });
  }

  deleteCourse(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/courses/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Trainers ---
  getTrainers(): Observable<Trainer[]> {
    return this.http.get<Trainer[]>(`${this.baseUrl}/trainers`);
  }

  getTrainer(id: number): Observable<Trainer> {
    return this.http.get<Trainer>(`${this.baseUrl}/trainers/${id}`);
  }

  searchTrainers(search?: string, specialization?: string): Observable<Trainer[]> {
    let httpParams = new HttpParams();
    if (search) httpParams = httpParams.set('search', search);
    if (specialization) httpParams = httpParams.set('specialization', specialization);
    return this.http.get<Trainer[]>(`${this.baseUrl}/trainers/search`, { params: httpParams });
  }

  getTrainerCourses(trainerId: number): Observable<TrainerAssignedCourse[]> {
    return this.http.get<TrainerAssignedCourse[]>(`${this.baseUrl}/trainers/${trainerId}/courses`);
  }

  createTrainer(trainer: Partial<Trainer>): Observable<any> {
    return this.http.post(`${this.baseUrl}/trainers`, trainer, { headers: this.getAuthHeaders() });
  }

  updateTrainer(id: number, trainer: Partial<Trainer>): Observable<any> {
    return this.http.put(`${this.baseUrl}/trainers/${id}`, trainer, { headers: this.getAuthHeaders() });
  }

  deleteTrainer(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/trainers/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Offerings ---
  getOfferings(): Observable<CourseOffering[]> {
    return this.http.get<CourseOffering[]>(`${this.baseUrl}/courseofferings`);
  }

  getOffering(id: number): Observable<CourseOffering> {
    return this.http.get<CourseOffering>(`${this.baseUrl}/courseofferings/${id}`);
  }

  getOfferingsByCourse(courseId: number): Observable<CourseOffering[]> {
    return this.http.get<CourseOffering[]>(`${this.baseUrl}/courseofferings/course/${courseId}`);
  }

  getUpcomingOfferings(): Observable<CourseOffering[]> {
    return this.http.get<CourseOffering[]>(`${this.baseUrl}/courseofferings/upcoming`);
  }

  createOffering(offering: Partial<CourseOffering>): Observable<any> {
    return this.http.post(`${this.baseUrl}/courseofferings`, offering, { headers: this.getAuthHeaders() });
  }

  updateOffering(id: number, offering: Partial<CourseOffering>): Observable<any> {
    return this.http.put(`${this.baseUrl}/courseofferings/${id}`, offering, { headers: this.getAuthHeaders() });
  }

  deleteOffering(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/courseofferings/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Trainees ---
  getTrainees(): Observable<Trainee[]> {
    return this.http.get<Trainee[]>(`${this.baseUrl}/trainees`, { headers: this.getAuthHeaders() });
  }

  getTrainee(id: number): Observable<Trainee> {
    return this.http.get<Trainee>(`${this.baseUrl}/trainees/${id}`, { headers: this.getAuthHeaders() });
  }

  getTraineeByEmail(email: string): Observable<Trainee> {
    return this.http.get<Trainee>(`${this.baseUrl}/trainees/by-email`, { params: { email } });
  }

  createTrainee(trainee: Partial<Trainee>): Observable<any> {
    return this.http.post(`${this.baseUrl}/trainees`, trainee, { headers: this.getAuthHeaders() });
  }

  updateTrainee(id: number, trainee: Partial<Trainee>): Observable<any> {
    return this.http.put(`${this.baseUrl}/trainees/${id}`, trainee, { headers: this.getAuthHeaders() });
  }

  deleteTrainee(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/trainees/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Registrations ---
  getRegistrations(): Observable<Registration[]> {
    return this.http.get<Registration[]>(`${this.baseUrl}/registrations`, { headers: this.getAuthHeaders() });
  }

  getMyRegistrations(email: string): Observable<Registration[]> {
    return this.http.get<Registration[]>(`${this.baseUrl}/registrations/my-registrations`, { params: { email } });
  }

  enroll(request: EnrollRequest): Observable<any> {
    return this.http.post(`${this.baseUrl}/registrations/enroll`, request);
  }

  cancelRegistration(request: CancelRequest): Observable<any> {
    return this.http.post(`${this.baseUrl}/registrations/cancel`, request);
  }

  updateRegistrationStatus(id: number, status: string): Observable<any> {
    return this.http.put(`${this.baseUrl}/registrations/${id}/status`, { status }, { headers: this.getAuthHeaders() });
  }

  deleteRegistration(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/registrations/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- Dashboard ---
  getDashboardKpis(): Observable<DashboardKpis> {
    return this.http.get<DashboardKpis>(`${this.baseUrl}/dashboard/kpis`);
  }

  getCategoryChart(): Observable<CategoryChart[]> {
    return this.http.get<CategoryChart[]>(`${this.baseUrl}/dashboard/charts/categories`);
  }

  getPopularCourses(limit = 5): Observable<PopularCourse[]> {
    return this.http.get<PopularCourse[]>(`${this.baseUrl}/dashboard/popular-courses`, { params: { limit: limit.toString() } });
  }
}
