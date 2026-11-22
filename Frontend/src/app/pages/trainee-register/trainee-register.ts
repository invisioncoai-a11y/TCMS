import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-trainee-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './trainee-register.html',
  styleUrl: './trainee-register.css'
})
export class TraineeRegisterComponent {
  fullName = '';
  email = '';
  phoneNumber = '';
  educationalBackground = '';

  submitting = false;
  successMessage = '';
  errorMessage = '';

  constructor(private api: ApiService, private router: Router) {}

  onSubmit(): void {
    if (!this.fullName || !this.email || !this.phoneNumber || !this.educationalBackground) {
      this.errorMessage = 'Please complete all required fields.';
      return;
    }

    this.submitting = true;
    this.errorMessage = '';
    this.successMessage = '';

    this.api
      .createTrainee({
        fullName: this.fullName,
        email: this.email,
        phoneNumber: this.phoneNumber,
        educationalBackground: this.educationalBackground
      })
      .subscribe({
        next: (res) => {
          this.submitting = false;
          this.successMessage = 'Trainee profile successfully created!';
          setTimeout(() => {
            this.router.navigate(['/courses']);
          }, 1500);
        },
        error: (err) => {
          this.submitting = false;
          this.errorMessage = err.error?.message || 'Registration failed.';
        }
      });
  }
}
