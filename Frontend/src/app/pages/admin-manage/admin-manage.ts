import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { ApiService } from '../../services/api.service';
import {
  Category,
  Course,
  Trainer,
  CourseOffering,
  Trainee,
  Registration
} from '../../models/models';

@Component({
  selector: 'app-admin-manage',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-manage.html',
  styleUrl: './admin-manage.css'
})
export class AdminManageComponent implements OnInit {
  activeTab: 'courses' | 'offerings' | 'categories' | 'trainers' | 'registrations' | 'trainees' = 'courses';

  // Data collections
  courses: Course[] = [];
  offerings: CourseOffering[] = [];
  categories: Category[] = [];
  trainers: Trainer[] = [];
  registrations: Registration[] = [];
  trainees: Trainee[] = [];

  loading = false;
  successMessage = '';
  errorMessage = '';

  // Course Form Model
  showCourseModal = false;
  editingCourseId: number | null = null;
  courseForm = {
    categoryID: 1,
    courseName: '',
    description: '',
    learningObjectives: '',
    prerequisites: '',
    price: 500,
    duration: 30,
    deliveryMode: 'Online',
    isFeatured: 0
  };

  // Offering Form Model
  showOfferingModal = false;
  editingOfferingId: number | null = null;
  offeringForm = {
    courseID: 1,
    trainerID: 1,
    startDate: '',
    endDate: '',
    scheduleDetails: '',
    maxCapacity: 20
  };

  // Category Form Model
  showCategoryModal = false;
  editingCategoryId: number | null = null;
  categoryForm = {
    categoryName: '',
    description: ''
  };

  // Trainer Form Model
  showTrainerModal = false;
  editingTrainerId: number | null = null;
  trainerForm = {
    fullName: '',
    specialization: '',
    qualifications: '',
    profileDetails: '',
    email: '',
    phoneNumber: ''
  };

  constructor(private api: ApiService, private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      if (params['tab']) {
        this.activeTab = params['tab'];
      }
      this.refreshCurrentTab();
    });
  }

  setTab(tab: 'courses' | 'offerings' | 'categories' | 'trainers' | 'registrations' | 'trainees'): void {
    this.activeTab = tab;
    this.successMessage = '';
    this.errorMessage = '';
    this.refreshCurrentTab();
  }

  refreshCurrentTab(): void {
    this.loading = true;
    switch (this.activeTab) {
      case 'courses':
        this.api.getCourses().subscribe({
          next: (res) => {
            this.courses = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        this.api.getCategories().subscribe({ next: (c) => (this.categories = c) });
        break;
      case 'offerings':
        this.api.getOfferings().subscribe({
          next: (res) => {
            this.offerings = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        this.api.getCourses().subscribe({ next: (c) => (this.courses = c) });
        this.api.getTrainers().subscribe({ next: (t) => (this.trainers = t) });
        break;
      case 'categories':
        this.api.getCategories().subscribe({
          next: (res) => {
            this.categories = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        break;
      case 'trainers':
        this.api.getTrainers().subscribe({
          next: (res) => {
            this.trainers = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        break;
      case 'registrations':
        this.api.getRegistrations().subscribe({
          next: (res) => {
            this.registrations = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        break;
      case 'trainees':
        this.api.getTrainees().subscribe({
          next: (res) => {
            this.trainees = res;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
        break;
    }
  }

  // --- Course CRUD ---
  openNewCourseModal(): void {
    this.editingCourseId = null;
    this.courseForm = {
      categoryID: this.categories.length > 0 ? this.categories[0].categoryID : 1,
      courseName: '',
      description: '',
      learningObjectives: '',
      prerequisites: '',
      price: 500,
      duration: 30,
      deliveryMode: 'Online',
      isFeatured: 0
    };
    this.showCourseModal = true;
  }

  openEditCourseModal(c: Course): void {
    this.editingCourseId = c.courseID;
    this.courseForm = {
      categoryID: c.categoryID,
      courseName: c.courseName,
      description: c.description || '',
      learningObjectives: c.learningObjectives || '',
      prerequisites: c.prerequisites || '',
      price: c.price,
      duration: c.duration,
      deliveryMode: c.deliveryMode,
      isFeatured: c.isFeatured
    };
    this.showCourseModal = true;
  }

  saveCourse(): void {
    if (this.editingCourseId) {
      this.api.updateCourse(this.editingCourseId, this.courseForm).subscribe({
        next: () => {
          this.successMessage = 'Course updated successfully!';
          this.showCourseModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Update failed.')
      });
    } else {
      this.api.createCourse(this.courseForm).subscribe({
        next: () => {
          this.successMessage = 'Course created successfully!';
          this.showCourseModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Creation failed.')
      });
    }
  }

  deleteCourse(id: number): void {
    if (confirm('Are you sure you want to delete this course? Associated offerings will be affected.')) {
      this.api.deleteCourse(id).subscribe({
        next: () => {
          this.successMessage = 'Course deleted.';
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Delete failed.')
      });
    }
  }

  // --- Offering CRUD ---
  openNewOfferingModal(): void {
    this.editingOfferingId = null;
    this.offeringForm = {
      courseID: this.courses.length > 0 ? this.courses[0].courseID : 1,
      trainerID: this.trainers.length > 0 ? this.trainers[0].trainerID : 1,
      startDate: new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0],
      endDate: new Date(Date.now() + 21 * 86400000).toISOString().split('T')[0],
      scheduleDetails: 'Mon, Wed (18:00 - 21:00)',
      maxCapacity: 20
    };
    this.showOfferingModal = true;
  }

  saveOffering(): void {
    const payload = {
      ...this.offeringForm,
      startDate: new Date(this.offeringForm.startDate).toISOString(),
      endDate: new Date(this.offeringForm.endDate).toISOString()
    };

    if (this.editingOfferingId) {
      this.api.updateOffering(this.editingOfferingId, payload).subscribe({
        next: () => {
          this.successMessage = 'Offering updated successfully!';
          this.showOfferingModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Update failed.')
      });
    } else {
      this.api.createOffering(payload).subscribe({
        next: () => {
          this.successMessage = 'Offering scheduled successfully!';
          this.showOfferingModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Scheduling failed.')
      });
    }
  }

  deleteOffering(id: number): void {
    if (confirm('Delete this course offering?')) {
      this.api.deleteOffering(id).subscribe({
        next: () => {
          this.successMessage = 'Offering deleted.';
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Delete failed.')
      });
    }
  }

  // --- Category CRUD ---
  openNewCategoryModal(): void {
    this.editingCategoryId = null;
    this.categoryForm = { categoryName: '', description: '' };
    this.showCategoryModal = true;
  }

  saveCategory(): void {
    if (this.editingCategoryId) {
      this.api.updateCategory(this.editingCategoryId, this.categoryForm).subscribe({
        next: () => {
          this.successMessage = 'Category updated!';
          this.showCategoryModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Failed.')
      });
    } else {
      this.api.createCategory(this.categoryForm).subscribe({
        next: () => {
          this.successMessage = 'Category created!';
          this.showCategoryModal = false;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Failed.')
      });
    }
  }

  deleteCategory(id: number): void {
    if (confirm('Delete this category?')) {
      this.api.deleteCategory(id).subscribe({
        next: () => {
          this.successMessage = 'Category deleted.';
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Cannot delete category with courses.')
      });
    }
  }

  // --- Registration Management ---
  updateRegistrationStatus(id: number, status: string): void {
    this.api.updateRegistrationStatus(id, status).subscribe({
      next: () => {
        this.successMessage = `Registration #${id} updated to ${status}.`;
        this.refreshCurrentTab();
      },
      error: (err) => (this.errorMessage = err.error?.message || 'Status update failed.')
    });
  }

  cancelRegistrationByAdmin(id: number): void {
    const reason = prompt('Enter cancellation reason:', 'Admin requested cancellation');
    if (reason) {
      this.api.cancelRegistration({ registrationID: id, reason }).subscribe({
        next: () => {
          this.successMessage = `Registration #${id} cancelled and seat restored.`;
          this.refreshCurrentTab();
        },
        error: (err) => (this.errorMessage = err.error?.message || 'Cancellation failed.')
      });
    }
  }
}
