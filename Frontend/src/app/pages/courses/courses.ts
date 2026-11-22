import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Course, Category } from '../../models/models';

@Component({
  selector: 'app-courses',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './courses.html',
  styleUrl: './courses.css'
})
export class CoursesComponent implements OnInit {
  courses: Course[] = [];
  categories: Category[] = [];
  loading = true;

  // Filter models
  searchTerm = '';
  selectedCategory = '';
  selectedDeliveryMode = '';
  minPrice: number | null = null;
  maxPrice: number | null = null;
  sortBy = 'name_asc';

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadCategories();
    this.onFilter();
  }

  loadCategories(): void {
    this.api.getCategories().subscribe({
      next: (cats) => (this.categories = cats)
    });
  }

  onFilter(): void {
    this.loading = true;
    this.api
      .searchCourses({
        search: this.searchTerm || undefined,
        categoryID: this.selectedCategory ? Number(this.selectedCategory) : undefined,
        deliveryMode: this.selectedDeliveryMode || undefined,
        minPrice: this.minPrice ?? undefined,
        maxPrice: this.maxPrice ?? undefined,
        sortBy: this.sortBy
      })
      .subscribe({
        next: (data) => {
          this.courses = data;
          this.loading = false;
        },
        error: () => (this.loading = false)
      });
  }

  resetFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = '';
    this.selectedDeliveryMode = '';
    this.minPrice = null;
    this.maxPrice = null;
    this.sortBy = 'name_asc';
    this.onFilter();
  }
}
