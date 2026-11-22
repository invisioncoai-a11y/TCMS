import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Course, Trainer, DashboardKpis, PopularCourse } from '../../models/models';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './home.html',
  styleUrl: './home.css'
})
export class HomeComponent implements OnInit {
  featuredCourses: Course[] = [];
  popularCourses: PopularCourse[] = [];
  trainers: Trainer[] = [];
  kpis: DashboardKpis | null = null;
  loading = true;

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.api.getFeaturedCourses().subscribe({
      next: (courses) => {
        this.featuredCourses = courses;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });

    this.api.getPopularCourses(4).subscribe({
      next: (pop) => (this.popularCourses = pop)
    });

    this.api.getTrainers().subscribe({
      next: (tr) => (this.trainers = tr.slice(0, 4))
    });

    this.api.getDashboardKpis().subscribe({
      next: (k) => (this.kpis = k)
    });
  }
}
