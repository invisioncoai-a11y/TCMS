import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Trainer, TrainerAssignedCourse } from '../../models/models';

@Component({
  selector: 'app-trainer-details',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './trainer-details.html',
  styleUrl: './trainer-details.css'
})
export class TrainerDetailsComponent implements OnInit {
  trainerId!: number;
  trainer: Trainer | null = null;
  assignedCourses: TrainerAssignedCourse[] = [];
  loading = true;

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      const id = params.get('id');
      if (id) {
        this.trainerId = Number(id);
        this.loadTrainer();
      }
    });
  }

  loadTrainer(): void {
    this.loading = true;
    this.api.getTrainer(this.trainerId).subscribe({
      next: (t) => {
        this.trainer = t;
        this.loadAssignedCourses();
      },
      error: () => (this.loading = false)
    });
  }

  loadAssignedCourses(): void {
    this.api.getTrainerCourses(this.trainerId).subscribe({
      next: (courses) => {
        this.assignedCourses = courses;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }
}
