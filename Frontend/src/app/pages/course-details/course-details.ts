import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Course, CourseOffering } from '../../models/models';

@Component({
  selector: 'app-course-details',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './course-details.html',
  styleUrl: './course-details.css'
})
export class CourseDetailsComponent implements OnInit {
  courseId!: number;
  course: Course | null = null;
  offerings: CourseOffering[] = [];
  loading = true;

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      const id = params.get('id');
      if (id) {
        this.courseId = Number(id);
        this.loadDetails();
      }
    });
  }

  loadDetails(): void {
    this.loading = true;
    this.api.getCourse(this.courseId).subscribe({
      next: (c) => {
        this.course = c;
        this.loadOfferings();
      },
      error: () => (this.loading = false)
    });
  }

  loadOfferings(): void {
    this.api.getOfferingsByCourse(this.courseId).subscribe({
      next: (offs) => {
        this.offerings = offs;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }
}
